const hyprland = await Service.import("hyprland");
await new Promise((r) => setTimeout(r, 100));

const time = Variable("", {
  poll: [1000, 'date "+%r"', (date) => `<b>${date}</b>`],
});

const day = Variable("", {
  poll: [1000, 'date "+%A"', (date) => `<b>${date}</b>`],
});

const date = Variable("", {
  poll: [1000, 'date "+%B %d, %Y"', (date) => `<b>${date}</b>`],
});

function timeBox() {
  return Widget.Box({
    className: "timeBox",
    children: [
      Widget.Label({
        className: "time",
        hpack: "start",
        useMarkup: true,
        label: time.bind(),
      }),
      Widget.Box({
        vexpand: true,
        vpack: "center",
        hexpand: true,
        hpack: "end",
        vertical: true,
        children: [
          Widget.Label({
            className: "day",
            vexpand: true,
            vpack: "center",
            hexpand: true,
            hpack: "end",
            useMarkup: true,
            label: day.bind(),
          }),
          Widget.Label({
            className: "date",
            vexpand: true,
            vpack: "center",
            hexpand: true,
            hpack: "end",
            useMarkup: true,
            label: date.bind(),
          }),
        ],
      }),
    ],
  });
}

function monitorNumber() {
  return Widget.Box({
    className: "monitorNumber",
    hexpand: true,
    hpack: "start",
  });
}

export function WindowBar(monitor = 0) {
  const wind = Widget.Window({
    monitor,
    name: `bar${monitor}`,
    anchor: ["top"],
    exclusivity: "exclusive",
    child: Widget.Box({
      children: [monitorNumber(), timeBox()],
    }),
  });

  return wind;
}
