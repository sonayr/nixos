Status: resolved
Type: research

## Question

How should AGS/ASTAL poll and parse battery percentage, charging status, and icon name from `upower` or `/sys/class/power_supply` reliably across different laptops?

## Answer

Poll via `createPoll` in ASTAL using a shell script that checks `/sys/class/power_supply/*/capacity` and `/sys/class/power_supply/*/status` for fast, lightweight reading, falling back to `upower` if needed. Percentage can be formatted as `${cap}%` and charging state detected from status ("Charging" vs "Discharging").
