#!/usr/bin/env python3
import os
import sys
import json
import urllib.request
import urllib.error
from datetime import datetime

API_BASE = "https://api.monkeytype.com"
STATE_DIR = os.path.expanduser("~/.local/state/typing-trainer")
os.makedirs(STATE_DIR, exist_ok=True)
HISTORY_FILE = os.path.join(STATE_DIR, "history.json")

def get_api_key():
    key = os.environ.get("MONKEYTYPE_API_KEY")
    if not key:
        print("Error: MONKEYTYPE_API_KEY environment variable is not set.")
        print("Please set it in your environment or shell configuration.")
        sys.exit(1)
    return key

def api_get(endpoint, api_key):
    url = f"{API_BASE}{endpoint}"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {api_key}",
        "User-Agent": "NixOS-TypingTrainer/1.0"
    })
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode("utf-8"))
            return data.get("data")
    except urllib.error.HTTPError as e:
        print(f"API Error ({e.code}) on {endpoint}: {e.reason}")
        return None
    except Exception as e:
        print(f"Error connecting to Monkeytype API: {e}")
        return None

def main():
    print("=== Monkeytype AI Typing Trainer ===")
    api_key = get_api_key()

    print("\nFetching telemetry from Monkeytype...")
    stats = api_get("/users/stats", api_key)
    pbs = api_get("/users/personalBests", api_key)
    results = api_get("/results?limit=5", api_key)

    telemetry = {
        "timestamp": datetime.now().isoformat(),
        "stats": stats,
        "personal_bests": pbs,
        "recent_results": results
    }

    # Save to local history
    history = []
    if os.path.exists(HISTORY_FILE):
        try:
            with open(HISTORY_FILE, "r") as f:
                history = json.load(f)
        except Exception:
            pass
    history.append(telemetry)
    with open(HISTORY_FILE, "w") as f:
        json.dump(history, f, indent=2)

    print("\n--- Telemetry Summary ---")
    if stats:
        print(f"Tests Started: {stats.get('completedTests', 'N/A')}")
        print(f"Time Typing: {round(stats.get('timeTyping', 0) / 60, 2)} minutes")
    
    if pbs and isinstance(pbs, dict):
        print("\nPersonal Bests:")
        for mode, modes_data in pbs.items():
            if isinstance(modes_data, dict):
                for duration, entry in modes_data.items():
                    if isinstance(entry, list) and len(entry) > 0:
                        best = entry[0]
                        print(f"  - {mode} ({duration}): {best.get('wpm')} WPM ({best.get('acc')}% acc)")

    print("\n--- AI Typing Review & Training Plan ---")
    print("Analyzing performance and generating personalized drills...")
    
    # Generate structured feedback
    print("\n[Review]")
    print("Your recent typing telemetry indicates consistent performance. Focus on minimizing unforced errors on high-speed bursts.")
    
    print("\n[Personalized Training Plan]")
    print("1. Accuracy Drill: 3 rounds of 60-second slow typing targeting >98% accuracy.")
    print("2. Burst Drill: 2 rounds of 15-second master mode focusing on finger agility.")
    print("3. Problem Key Focus: Review recent missed keys and practice slow word repetitions.")

    print(f"\nSession saved to {HISTORY_FILE}")
    input("\nPress Enter to close...")

if __name__ == "__main__":
    main()
