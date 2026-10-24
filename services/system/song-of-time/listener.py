#!/usr/bin/env python3
"""
Song of Time Audio Unlock Listener for Hyprlock.
Listens to the microphone for the iconic Song of Time motif on piano (or ocarina):
A -> D -> F -> A -> D -> F
Updates a subtle indicator status file for hyprlock widgets and sends SIGUSR1
to hyprlock on successful recognition to unlock the screen.
"""

import os
import sys
import time
import signal
import shutil
import subprocess
import numpy as np

TARGET_PATTERN = [9, 2, 5, 9, 2, 5]  # A, D, F, A, D, F
NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

SR = 16000
N_FFT = 2048
HOP = 512
CHUNK_BYTES = HOP * 2  # 16-bit mono = 2 bytes per sample -> 1024 bytes

MAX_LISTEN_TIME = 60.0  # 1 minute listening window
MIN_NOTE_DUR = 0.12     # Note must be held >= 120ms to count
MAX_NOTE_GAP = 3.5      # Max seconds between notes before resetting sequence

RUNTIME_DIR = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
STATUS_FILE = os.path.join(RUNTIME_DIR, "song-of-time.status")
DONE_FILE = os.path.join(RUNTIME_DIR, "song-of-time.done")

audio_proc = None

def cleanup(*args):
    global audio_proc
    if audio_proc and audio_proc.poll() is None:
        try:
            audio_proc.terminate()
            audio_proc.wait(timeout=1.0)
        except Exception:
            try:
                audio_proc.kill()
            except Exception:
                pass
    try:
        if os.path.exists(STATUS_FILE):
            os.remove(STATUS_FILE)
    except Exception:
        pass
    sys.exit(0)

signal.signal(signal.SIGINT, cleanup)
signal.signal(signal.SIGTERM, cleanup)

def update_status(text):
    try:
        tmp_file = STATUS_FILE + ".tmp"
        with open(tmp_file, "w") as f:
            f.write(text)
        os.replace(tmp_file, STATUS_FILE)
    except Exception:
        pass

def is_hyprlock_running():
    try:
        res = subprocess.run(
            ["pgrep", "-u", str(os.getuid()), "-x", "hyprlock"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        return res.returncode == 0
    except Exception:
        return True

def start_audio_capture():
    global audio_proc
    # Try arecord first (standard ALSA / PipeWire ALSA bridge)
    if shutil.which("arecord"):
        try:
            cmd = ["arecord", "-q", "-r", str(SR), "-c", "1", "-f", "S16_LE", "-t", "raw"]
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
            time.sleep(0.1)
            if proc.poll() is None:
                audio_proc = proc
                return proc
        except Exception:
            pass

    # Fallback to pw-record (native PipeWire)
    if shutil.which("pw-record"):
        try:
            cmd = ["pw-record", "--format", "s16", "--rate", str(SR), "--channels", "1", "-"]
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
            time.sleep(0.1)
            if proc.poll() is None:
                audio_proc = proc
                return proc
        except Exception:
            pass

    sys.stderr.write("song-of-time: No supported audio capture tool found (arecord/pw-record).\n")
    return None

def main():
    update_status("♪ listening...")

    proc = start_audio_capture()
    if not proc or not proc.stdout:
        cleanup()
        return

    # Precompute FFT filters
    window = np.hanning(N_FFT)
    freqs = np.fft.rfftfreq(N_FFT, 1.0 / SR)
    valid = (freqs >= 100) & (freqs <= 3500)
    v_freqs = freqs[valid]
    midi = np.round(69 + 12 * np.log2(v_freqs / 440.0)).astype(int)
    pitch_classes = midi % 12
    weights = 1.0 / (1.0 + (v_freqs / 1200.0) ** 2)

    buf = np.zeros(N_FFT, dtype=np.float32)

    matched_idx = 0
    matched_names = []
    last_note = None
    last_note_start = 0.0
    last_note_registered = False
    last_transition_time = 0.0

    start_time = time.time()
    last_hyprlock_check = start_time

    while True:
        now = time.time()
        elapsed = now - start_time
        if elapsed >= MAX_LISTEN_TIME:
            sys.stderr.write("song-of-time: 60s timeout reached.\n")
            try:
                with open(DONE_FILE, "w") as f:
                    f.write("timeout\n")
            except Exception:
                pass
            cleanup()
            return

        # Check if hyprlock was unlocked or closed
        if now - last_hyprlock_check > 0.5:
            last_hyprlock_check = now
            if not is_hyprlock_running():
                sys.stderr.write("song-of-time: hyprlock is no longer running. Exiting.\n")
                cleanup()
                return

        # Read audio chunk
        try:
            chunk_bytes = proc.stdout.read(CHUNK_BYTES)
        except Exception:
            break

        if not chunk_bytes or len(chunk_bytes) < CHUNK_BYTES:
            break

        chunk = np.frombuffer(chunk_bytes, dtype=np.int16).astype(np.float32) / 32768.0
        buf[:-HOP] = buf[HOP:]
        buf[-HOP:] = chunk

        frame = buf * window
        energy = np.sqrt(np.mean(frame ** 2))

        # Audio threshold gate
        if energy < 0.012:
            last_note = None
            last_note_registered = False
            if matched_idx > 0 and (elapsed - last_transition_time) > MAX_NOTE_GAP:
                matched_idx = 0
                matched_names = []
                update_status("♪ listening...")
            continue

        mag = np.abs(np.fft.rfft(frame))[valid] * weights
        chroma = np.bincount(pitch_classes, weights=mag, minlength=12)
        norm = np.linalg.norm(chroma)
        if norm > 1e-4:
            chroma /= norm

        top_pc = np.argmax(chroma)
        conf = chroma[top_pc]

        if conf < 0.40:
            last_note = None
            last_note_registered = False
            if matched_idx > 0 and (elapsed - last_transition_time) > MAX_NOTE_GAP:
                matched_idx = 0
                matched_names = []
                update_status("♪ listening...")
            continue

        # Note tracking
        if top_pc != last_note:
            last_note = top_pc
            last_note_start = elapsed
            last_note_registered = False
        else:
            if not last_note_registered and (elapsed - last_note_start) >= MIN_NOTE_DUR:
                last_note_registered = True

                if matched_idx > 0 and (elapsed - last_transition_time) > MAX_NOTE_GAP:
                    matched_idx = 0
                    matched_names = []

                expected = TARGET_PATTERN[matched_idx]
                if last_note == expected:
                    matched_idx += 1
                    last_transition_time = elapsed
                    matched_names.append(NOTE_NAMES[last_note])
                    sys.stderr.write(f"song-of-time: matched note {matched_idx}/6: {NOTE_NAMES[last_note]}\n")

                    if matched_idx == len(TARGET_PATTERN):
                        update_status("♪ Time flows again...")
                        sys.stderr.write("song-of-time: Song of Time recognized! Unlocking hyprlock...\n")
                        subprocess.run(
                            ["pkill", "-SIGUSR1", "-u", str(os.getuid()), "hyprlock"],
                            check=False
                        )
                        time.sleep(0.5)
                        cleanup()
                        return
                    else:
                        update_status("♪ " + "  ".join(matched_names))

                elif last_note == TARGET_PATTERN[0]:
                    matched_idx = 1
                    last_transition_time = elapsed
                    matched_names = [NOTE_NAMES[last_note]]
                    update_status("♪ " + "  ".join(matched_names))
                else:
                    matched_idx = 0
                    matched_names = []
                    update_status("♪ listening...")

    cleanup()

if __name__ == "__main__":
    main()
