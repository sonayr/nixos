Status: resolved
Type: task
Blocked by: 02-widget-layout-hover.md

## Question

What SCSS rules and state toggles should be added to `style.scss` to highlight the battery widget in a warning style when capacity drops below 20% while discharging?

## Answer

Added `.battery-warning` class in `style.scss` that sets text/background color to a warning red/orange when capacity < 20% and status is discharging.
