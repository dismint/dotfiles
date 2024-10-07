const hyprland = await Service.import("hyprland");
const systemtray = await Service.import("systemtray");
await new Promise((r) => setTimeout(r, 100));

const monitorMap = {
  0: "3",
  1: "1",
  2: "2",
  3: "4",
};

const workspaceMap = new Map([
  ["1", "1"],
  ["2", "2"],
  ["3", "3"],
  ["4", "4"],
  ["5", "5"],
  ["6", "6"],
  ["7", "7"],
  ["8", "8"],
  ["9", "9"],
  ["DISCORD", "D"],
  ["MUSIC", "M"],
  ["INFO", "N"],
]);

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

function workspaceName() {
  const box = Widget.Box({
    className: "workspaceName",
    hexpand: true,
    hpack: "start",
    children: [
      Widget.Label({
        css: hyprland.active.workspace.bind("name").as((name) => {
          const size = 145 - 11 * name.length;
          return `font-size: ${size}px;`;
        }),
        useMarkup: true,
        vexpand: true,
        vpack: "center",
        hexpand: true,
        hpack: "center",
        label: hyprland.active.workspace
          .bind("name")
          .as((name) => `<b>${name}</b>`),
      }),
    ],
  });

  return box;
}

function display() {
  const sysTray = Widget.Box({
    className: "display",
    hexpand: true,
    vexpand: true,
    vpack: "center",
    hpack: "center",
    child: Widget.Label({
      label: "<b>armimarmi</b>",
      hexpand: true,
      vexpand: true,
      vpack: "center",
      hpack: "center",
      useMarkup: true,
    }),
  });

  const labels = ["<b>armimarmi</b>", "<b>ujubaba</b>"];
  var current = 0;
  Utils.interval(2500, () => {
    current = (current + 1) % labels.length;
    sysTray.child.label = labels[current];
  });

  return sysTray;
}

function workspaces(workspaceList) {
  return Widget.Box({
    child: Utils.merge(
      [hyprland.bind("workspaces"), hyprland.active.workspace.bind("name")],
      (ws, active) => {
        const workspaces = Widget.Box();
        workspaceList.forEach((w) => {
          const box = Widget.Box({
            children: [
              Widget.Label({
                className:
                  active.toString() === w
                    ? "workspaceTile active"
                    : ws.find((x) => x.name === w)
                      ? "workspaceTile alive"
                      : "workspaceTile",
                useMarkup: true,
                label: `<b>${workspaceMap.get(w)}</b>`,
              }),
            ],
          });
          workspaces.pack_start(box, true, true, true);
        });
        return workspaces;
      },
    ),
  });
}

function clientClass() {
  return Widget.Box({
    children: [
      Widget.Label({
        css: hyprland.active.client.bind("class").as((name) => {
          const size = Math.max(95 - 3 * name.length, 40);
          return `font-size: ${size}px;`;
        }),
        maxWidthChars: 1,
        ellipsize: 3,
        wrap: true,
        wrapMode: 2,
        lines: 1,
        className: "clientClass",
        hexpand: true,
        hpack: "start",
        useMarkup: true,
        label: hyprland.active.client
          .bind("class")
          .as((name) => `<b>${name}</b>`),
      }),
    ],
  });
}

function clientTitle() {
  return Widget.Box({
    children: [
      Widget.Label({
        css: hyprland.active.client.bind("title").as((name) => {
          return `font-size: ${30}px;`;
        }),
        maxWidthChars: 1,
        ellipsize: 3,
        wrap: true,
        wrapMode: 2,
        lines: 1,
        className: "clientTitle",
        hexpand: true,
        hpack: "start",
        useMarkup: true,
        label: hyprland.active.client
          .bind("title")
          .as((name) => `<b>${name}</b>`),
      }),
    ],
  });
}

export function WindowBar(monitor = 0) {
  const fb = Widget.Box({
    vexpand: true,
    vpack: "center",
    vertical: true,
    children: [
      Widget.Box({
        children: [workspaceName(), timeBox(), display()],
      }),
      Widget.Box({
        className: "workspaces",
        vertical: true,
        children: [
          workspaces(["1", "2", "3", "4", "5", "6", "7", "8", "9"]),
          workspaces(["DISCORD", "MUSIC", "INFO"]),
        ],
      }),
      Widget.Box({
        children: [clientClass()],
      }),
      Widget.Box({
        children: [clientTitle()],
      }),
    ],
  });

  const wind = Widget.Window({
    monitor,
    name: `bar${monitor}`,
    anchor: ["top"],
    exclusivity: "exclusive",
    child: fb,
  });

  return wind;
}
