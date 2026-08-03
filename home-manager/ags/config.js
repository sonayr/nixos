const hyprland = await Service.import('hyprland')
const battery = await Service.import('battery')

// Widget: Workspaces
const Workspaces = () => Widget.Box({
    class_name: 'workspaces',
    children: Array.from({ length: 5 }, (_, i) => i + 1).map(i => Widget.Button({
        attribute: i,
        vpack: 'center',
        label: `${i}`,
        on_clicked: () => hyprland.messageAsync(`dispatch workspace ${i}`),
        setup: self => self.hook(hyprland, () => {
            self.toggleClassName('active', hyprland.active.workspace.id === i)
            self.toggleClassName('occupied', (hyprland.getWorkspace(i)?.windows || 0) > 0)
        }),
    })),
})

// Widget: Client Title
const ClientTitle = () => Widget.Label({
    class_name: 'client-title',
    label: hyprland.active.client.bind('title'),
})

// Widget: Clock
const Clock = () => Widget.Label({
    class_name: 'clock',
    setup: self => self.poll(1000, self => {
        const date = new Date()
        self.label = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })
    }),
})

// Widget: Battery
const BatteryLabel = () => Widget.Box({
    class_name: 'battery',
    visible: battery.bind('available'),
    children: [
        Widget.Icon({
            icon: battery.bind('icon_name'),
        }),
        Widget.Label({
            label: battery.bind('percent').as(p => ` ${p}%`),
        }),
    ],
})

// Layout: Left, Center, Right
const Left = () => Widget.Box({
    spacing: 8,
    children: [
        Workspaces(),
    ],
})

const Center = () => Widget.Box({
    spacing: 8,
    children: [
        ClientTitle(),
    ],
})

const Right = () => Widget.Box({
    hpack: 'end',
    spacing: 8,
    children: [
        BatteryLabel(),
        Clock(),
    ],
})

// The Bar Window
const Bar = (monitor = 0) => Widget.Window({
    name: `bar-${monitor}`,
    class_name: 'bar',
    monitor,
    anchor: ['top', 'left', 'right'],
    exclusivity: 'exclusive',
    child: Widget.CenterBox({
        start_widget: Left(),
        center_widget: Center(),
        end_widget: Right(),
    }),
})

// Export the configuration
App.config({
    style: './style.css',
    windows: [
        Bar(),
    ],
})
