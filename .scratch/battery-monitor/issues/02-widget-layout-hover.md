Status: resolved
Type: prototype
Blocked by: 01-battery-polling.md

## Question

How should the battery widget be structured in ASTAL TypeScript (`Bar.tsx`) so that the icon is always visible, percentage appears/toggles on hover, and clicking executes `upower -d`?

## Answer

Structured as a button with a box containing a battery icon (or symbol `🔋`) and a percentage label. Hover state toggles the percentage label visibility (via a state variable or CSS opacity transition), and `onClicked` executes `upower -d`.
