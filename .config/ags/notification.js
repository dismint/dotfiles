import Cairo from "gi://cairo?version=1.0";
import Gdk from "gi://Gdk";

const notifications = await Service.import("notifications");
await new Promise((r) => setTimeout(r, 100));

notifications.popupTimeout = 5000;
notifications.forceTimeout = false;
notifications.cacheActions = false;
notifications.clearDelay = 0;
notifications.clear();

function updateInputRegion(popupList, wind) {
  let totalHeight = 0;
  for (const child of popupList.children) {
    totalHeight += child.get_allocation().height;
  }
  const rect = new Gdk.Rectangle({
    x: 0,
    y: 0,
    width: 550,
    height: totalHeight,
  });
  let blankRegion = new Cairo.Region();
  blankRegion.unionRectangle(rect);
  wind.input_shape_combine_region(blankRegion);
}

function removeNotification(overlay, close = false) {
  if (!close && overlay.attribute.editing != 0) {
    overlay.attribute.editing = 2;
    return;
  }

  if (overlay.attribute.removing) {
    return;
  }

  overlay.attribute.removing = true;
  let holder = overlay.child;
  let hider = overlay.overlays[0];

  let height = holder.get_allocation().height;
  holder.child.css = `min-height: ${height}px;`;
  hider.className = "hider in";
  Utils.timeout(500, () => {
    holder.css = "opacity: 0;";
    holder.child.children = [];
    hider.className = "hider out";
    Utils.timeout(300, () => {
      holder.child.css =
        "min-height: 0px; transition: min-height 0.2s cubic-bezier(0.33, 1, 0.68, 1);";
    });
    Utils.timeout(500, () => {
      hider.className = "hider exit";
      overlay.destroy();
    });
  });
}

function DecoratedNotification(notification) {
  let summary = Widget.Label({
    label: `<b>${notification.summary}</b>`,
    className: "summary",

    // needed to force label to scale properly
    maxWidthChars: 1,
    hexpand: true,
    vexpand: true,

    xalign: 0, // left align
    wrap: true,
    wrapMode: 2,
    ellipsize: 3,
    lines: 1,
    useMarkup: true,
  });
  let body = Widget.Label({
    label: `${notification.body}`,
    className: "body",

    // needed to force label to scale properly
    maxWidthChars: 1,
    hexpand: true,
    vexpand: true,

    xalign: 0, // left align
    wrap: true,
    wrapMode: 2,
    ellipsize: 3,
    lines: 2,
    useMarkup: true,
  });

  let card = Widget.Box({
    className: "card",
    child: Widget.Box({
      vertical: true,
      vexpand: false,
      children: [],
    }),
  });
  if (notification.summary) {
    if (!notification.body) {
      summary.className = "summary solo";
    }
    card.child.children = [summary];
  }
  if (notification.body) {
    if (!notification.summary) {
      body.className = "body solo";
    }
    card.child.children = [...card.child.children, body];
  }
  if (notification.image) {
    let imgbox = Widget.Box({
      className: "image",
      css: `background-image: url("${notification.image}");`,
    });
    card.children = [imgbox, ...card.children];
  }
  let accent = Widget.Box({
    className: "accent",
  });

  const holder = Widget.EventBox({
    halign: 1,
    css: "opacity: 0;",
    child: Widget.Box({
      halign: 1,
      children: [accent, card],
    }),
  });
  let hider = Widget.Box({
    halign: 1,
    className: "hider enter",
  });
  Utils.timeout(0, () => {
    hider.className = "hider in";
    Utils.timeout(500, () => {
      holder.css = "opacity: 1;";
      hider.className = "hider out";
      Utils.timeout(500, () => {
        hider.className = "hider exit";
      });
    });
  });
  let overlay = Widget.Overlay({
    hexpand: true,
    attribute: { id: notification.id, removing: false, editing: 0 },
    child: holder,
    overlays: [hider],
    passThrough: true,
  });

  let xDiff = 0;
  let curWidth = 15;

  holder.connect("button-press-event", (self, event) => {
    if (overlay.attribute.removing) {
      return;
    }

    [, xDiff] = event.get_coords();
    overlay.attribute.editing = 1;
  });
  holder.connect("button-release-event", (self, event) => {
    if (overlay.attribute.removing) {
      return;
    }

    accent.className = "accent returning";
    accent.css = "min-width: 15px;";

    if (curWidth > 60) {
      overlay.attribute.editing = 0;

      if (notification.actions.length) {
        notification.actions.forEach((action) => {
          notification.invoke(action["id"]);
        });
      } else {
        notification.close();
      }

      removeNotification(overlay);
    } else if (overlay.attribute.editing == 2) {
      overlay.attribute.editing = 0;

      Utils.timeout(1000, () => {
        removeNotification(overlay);
      });
      return;
    }
  });
  holder.connect("motion-notify-event", (self, event) => {
    if (overlay.attribute.removing) {
      return;
    }

    let [, x] = event.get_coords();
    let curDiff = x - xDiff;
    if (curDiff >= 0) {
      curWidth = 15 + curDiff / (1 + 0.01 * curDiff);
      accent.css = `min-width: ${curWidth}px;`;
      if (curWidth > 60) {
        accent.className = "accent pulled";
      } else {
        accent.className = "accent";
      }
    }
  });

  return overlay;
}

export function WindowNotification(monitor = 2) {
  const popupList = Widget.Box({
    children: [],
    vertical: true,
  });

  popupList.set_size_request(1, 1);
  const wind = Widget.Window({
    monitor,
    name: `notifications${monitor}`,
    anchor: ["top", "left", "right", "bottom"],
    child: popupList,
  });

  popupList.hook(
    notifications,
    (_, id) => {
      const n = notifications.getNotification(id);
      if (n) {
        const bn = DecoratedNotification(n);
        popupList.pack_start(bn, false, false, 0);
        popupList.show_all();
        Utils.timeout(100, () => {
          updateInputRegion(popupList, wind);
        });
      }
    },
    "notified",
  );

  popupList.hook(
    notifications,
    (_, id) => {
      let notif = popupList.children.find((n) => n.attribute.id === id);
      if (notif) {
        removeNotification(notif);
        Utils.timeout(1000, () => {
          updateInputRegion(popupList, wind);
        });
      }
    },
    "dismissed",
  );

  popupList.hook(
    notifications,
    (_, id) => {
      let notif = popupList.children.find((n) => n.attribute.id === id);
      if (notif) {
        removeNotification(notif, true);
        Utils.timeout(1000, () => {
          updateInputRegion(popupList, wind);
        });
      }
    },
    "closed",
  );

  updateInputRegion(popupList, wind);

  return wind;
}
