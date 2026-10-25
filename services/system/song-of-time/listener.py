#!/usr/bin/env python3
"""
Song of Time Audio Unlock Listener for Hyprlock.
Listens to the microphone and displays every note heard (up to the last 6 notes).
Unlocks hyprlock via SIGUSR1 as soon as the last 6 notes match the Song of Time motif:
A -> D -> F -> A -> D -> F
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
MIN_NOTE_DUR = 0.10     # Note candidate must sustain >= 100ms to confirm
MAX_NOTE_GAP = 10.0     # Reset display back to 'listening...' after 10s of silence

RUNTIME_DIR = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
STATUS_FILE = os.path.join(RUNTIME_DIR, "song-of-time.status")
DONE_FILE = os.path.join(RUNTIME_DIR, "song-of-time.done")

audio_proc = None

def cleanup(clean_status=True):
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
    if clean_status:
        try:
            if os.path.exists(STATUS_FILE):
                os.remove(STATUS_FILE)
        except Exception:
            pass
    sys.exit(0)

def signal_handler(*args):
    cleanup(clean_status=True)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

def update_status(text):
    try:
        tmp_file = STATUS_FILE + ".tmp"
        with open(tmp_file, "w") as f:
            f.write(text)
        os.replace(tmp_file, STATUS_FILE)
    except Exception:
        pass

def fade_in_message(message="♪ Time flows again...", duration_s=2.0, steps=20):
    step_time = duration_s / steps
    for i in range(steps + 1):
        alpha = int((i / steps) * 100)
        markup = f'<span alpha="{alpha}%">{message}</span>'
        update_status(markup)
        time.sleep(step_time)

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
        cleanup(clean_status=True)
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
    chroma_smooth = np.zeros(12)

    recent_pitch_classes = []
    recent_note_names = []
    active_note = None          # Currently registered note
    candidate_note = None       # Candidate new pitch class
    candidate_start_time = 0.0
    last_note_time = 0.0

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
            update_status("(click fairy to listen)")
            cleanup(clean_status=False)
            return

        # Check if hyprlock was unlocked or closed
        if now - last_hyprlock_check > 0.5:
            last_hyprlock_check = now
            if not is_hyprlock_running():
                sys.stderr.write("song-of-time: hyprlock is no longer running. Exiting.\n")
                cleanup(clean_status=True)
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
        if energy < 0.008:
            candidate_note = None
            if recent_pitch_classes and (elapsed - last_note_time) > MAX_NOTE_GAP:
                recent_pitch_classes = []
                recent_note_names = []
                active_note = None
                update_status("♪ listening...")
            continue

        mag = np.abs(np.fft.rfft(frame))[valid] * weights
        c = np.bincount(pitch_classes, weights=mag, minlength=12)
        norm = np.linalg.norm(c)
        if norm > 1e-4:
            c /= norm

        # Smooth chroma over time to avoid single-frame overtone flutter
        chroma_smooth = 0.5 * chroma_smooth + 0.5 * c
        top_pc = np.argmax(chroma_smooth)
        conf = chroma_smooth[top_pc]

        if conf < 0.35:
            candidate_note = None
            if recent_pitch_classes and (elapsed - last_note_time) > MAX_NOTE_GAP:
                recent_pitch_classes = []
                recent_note_names = []
                active_note = None
                update_status("♪ listening...")
            continue

        # Check gap timeout between notes
        if recent_pitch_classes and (elapsed - last_note_time) > MAX_NOTE_GAP:
            recent_pitch_classes = []
            recent_note_names = []
            active_note = None
            update_status("♪ listening...")

        # If it's still the active note ringing out, keep last_note_time refreshed!
        # Holding a note will NEVER duplicate it or reset the display.
        if top_pc == active_note:
            candidate_note = None
            last_note_time = elapsed
            continue

        # Detected a candidate new note
        if top_pc != candidate_note:
            candidate_note = top_pc
            candidate_start_time = elapsed
        else:
            # Candidate note sustained for >= MIN_NOTE_DUR
            if (elapsed - candidate_start_time) >= MIN_NOTE_DUR:
                new_note = candidate_note
                candidate_note = None
                active_note = new_note
                last_note_time = elapsed

                recent_pitch_classes.append(new_note)
                recent_note_names.append(NOTE_NAMES[new_note])
                if len(recent_pitch_classes) > 6:
                    recent_pitch_classes.pop(0)
                    recent_note_names.pop(0)

                sys.stderr.write(f"song-of-time: heard note {NOTE_NAMES[new_note]} -> notes: {' '.join(recent_note_names)}\n")

                if recent_pitch_classes == TARGET_PATTERN:
                    sys.stderr.write("song-of-time: Song of Time recognized! Fading in message over 2s...\n")
                    # Stop recording audio immediately
                    if audio_proc and audio_proc.poll() is None:
                        try:
                            audio_proc.terminate()
                        except Exception:
                            pass
                    # Fade in message over 2 seconds
                    fade_in_message("♪ Time flows again...", duration_s=2.0, steps=20)
                    # Hold at full opacity for 1.5 seconds
                    time.sleep(1.5)
                    sys.stderr.write("song-of-time: Unlocking hyprlock...\n")
                    subprocess.run(
                        ["pkill", "-SIGUSR1", "-u", str(os.getuid()), "hyprlock"],
                        check=False
                    )
                    time.sleep(0.5)
                    cleanup(clean_status=True)
                    return
                else:
                    update_status("♪ " + "  ".join(recent_note_names))

    cleanup(clean_status=True)

if __name__ == "__main__":
    main()
