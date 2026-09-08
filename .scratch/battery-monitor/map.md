## Destination

A robust battery monitor widget in the AGS top nav bar (`Bar.tsx`) featuring an always-visible battery icon, percentage displayed on hover, click action to open power stats (`upower -d`), and a visual style alert when discharging below 20%.

## Notes

- Domain: NixOS, Home Manager, AGS (Aylur's GTK Shell), GTK3, TypeScript, UPower, sysfs.
- Skills every session should consult: `grilling`, `domain-modeling`, `research`, `prototype`.
- Standing preferences: Declarative NixOS configuration, clean TypeScript ASTAL components, SCSS styling.

## Decisions so far

- [Battery Polling and State Retrieval](issues/01-battery-polling.md): Polling via `/sys/class/power_supply` and `upower` fallback using ASTAL `createPoll`.
- [Widget Layout and Hover Interaction](issues/02-widget-layout-hover.md): Button with icon and hover-toggled percentage label, clicking opens `upower -d`.
- [Low Battery Warning Styling](issues/03-low-battery-styling.md): SCSS warning class for discharging state below 20%.

## Not yet specified

- None (all initial frontier decisions resolved; route to destination is clear).

## Out of scope

- Full standalone battery management graphical application or popup menu dashboard.
