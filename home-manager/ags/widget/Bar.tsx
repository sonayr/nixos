import app from "ags/gtk3/app"
import { Astal, Gtk, Gdk } from "ags/gtk3"
import { execAsync } from "ags/process"
import { createPoll } from "ags/time"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const time = createPoll("", 1000, "date")
  const volume = createPoll(
    "Vol",
    1000,
    `wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{vol=int($2*100); if ($3=="[MUTED]") print vol "% (M)"; else print vol "%"}'`
  )
  const battery = createPoll(
    "Bat",
    5000,
    `sh -c 'cap=$(cat /sys/class/power_supply/*/capacity 2>/dev/null | head -n 1); if [ -n "$cap" ]; then echo "\${cap}%"; else bat=$(upower -e 2>/dev/null | grep -m 1 battery); if [ -n "$bat" ]; then upower -i "$bat" 2>/dev/null | grep percentage | awk "{print \\$2}"; else echo "Bat"; fi; fi'`
  )
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox>
        <button
          $type="start"
          onClicked={() => execAsync("echo hello").then(console.log)}
          halign={Gtk.Align.CENTER}
        >
          <label label="Welcome to AGS!" />
        </button>
        <box $type="center" />
        <box $type="end" spacing={8} halign={Gtk.Align.CENTER}>
          <button
            onClicked={() => execAsync("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")}
            halign={Gtk.Align.CENTER}
          >
            <label label={volume} />
          </button>
          <button
            class="battery"
            onClicked={() => execAsync("upower -d").catch(() => {})}
            halign={Gtk.Align.CENTER}
          >
            <box spacing={4}>
              <label label="🔋" />
              <label class="percent" label={battery} />
            </box>
          </button>
          <button
            onClicked={() => print("hello")}
            halign={Gtk.Align.CENTER}
          >
            <label label={time} />
          </button>
        </box>
      </centerbox>
    </window>
  )
}
