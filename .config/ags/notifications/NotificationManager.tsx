// | 🙑  dismint
// | YW5uaWUgPDM=

import { Astal, Gtk, Gdk, Widget } from "astal/gtk3";
import Notifd from "gi://AstalNotifd";
import { timeout } from "astal";
import Cairo from "gi://cairo?version=1.0";

const TIMEOUT = 3000;
const GRACE = 1000;

// @ts-ignore
function updateInputRegion(values, wind) {
  let totalHeight = 0;
  for (const child of values.children) {
    totalHeight += child.get_allocation().height;
  }
  const rect = new Gdk.Rectangle({
    x: 45,
    y: 1400 - totalHeight,
    width: 510,
    height: totalHeight,
  });
  let blankRegion = new Cairo.Region();
  // @ts-ignore
  blankRegion.unionRectangle(rect);
  wind.input_shape_combine_region(blankRegion);
}

export default function NotificationManager(gdkmonitor: Gdk.Monitor) {
  const values = new Widget.Box({
    className: "notif-all",
    children: [],
    vertical: true,
  });
  const notifd = Notifd.get_default();
  const notifManager = new Widget.Window({
    gdkmonitor: gdkmonitor,
    exclusivity: Astal.Exclusivity.EXCLUSIVE,
    anchor:
      Astal.WindowAnchor.TOP |
      Astal.WindowAnchor.LEFT |
      Astal.WindowAnchor.RIGHT |
      Astal.WindowAnchor.BOTTOM,
    child: values,
  });

  notifd.connect("notified", (_, id) => {
    const n = notifd.get_notification(id);
    // 0: open to delete
    // 1: being deleted
    // 2: prevent delete
    var deleting = 0;
    // whether default timeout has expired
    var due = false;
    // if the notification should timeout but if we hover or click on it, the
    // deletion should reattempt once we move off - however if this happens
    // multiple times, a previous attempt could maliciously early delete before
    // the GRACE time is up
    // THEREFORE, only delete if the current attempt is the most recent one
    var attemptCounter = 0;

    const contentBox = new Widget.Box({
      className: "notif-inner-box transparent classic-color",
      children: [],
      hexpand: false,
      halign: 1,
    });
    if (n.image) {
      const image = new Widget.Box({
        className: "image-container",
        child: new Widget.Box({
          className: "image",
          css: `background-image: url("${n.image}");`,
        }),
      });
      contentBox.children = [image];
    }
    const content = new Widget.Box({
      vertical: true,
      valign: 3,
      children: [
        new Widget.Label({
          maxWidthChars: 1,
          hexpand: true,
          vexpand: true,
          xalign: 0,
          wrap: true,
          wrapMode: 2,
          ellipsize: 3,
          lines: 2,
          useMarkup: true,
          className: n.image ? "summary" : "summary solo",
          label: `<b>${n.summary}</b>`,
        }),
        new Widget.Label({
          maxWidthChars: 1,
          hexpand: true,
          vexpand: true,
          xalign: 0,
          wrap: true,
          wrapMode: 2,
          ellipsize: 3,
          lines: 2,
          useMarkup: true,
          className: n.image ? "body" : "body solo",
          label: `${n.body}`,
        }),
      ],
    });
    contentBox.children = [...contentBox.children, content];
    const hider = new Widget.Box({
      className: "hider",
      halign: 1,
    });
    const overlay = new Widget.Overlay({
      child: contentBox,
      overlays: [hider],
    });
    const eventBox = new Widget.EventBox({
      child: overlay,
      name: `${id}`,
      valign: Gtk.Align.START,
      vexpand: false,
    });

    function deleteNotif(invoke: boolean, seq: number = -1) {
      if (seq !== -1 && attemptCounter !== seq) {
        return;
      }
      attemptCounter += 1;

      if (deleting !== 0) {
        return;
      }
      deleting = 1;

      contentBox.toggleClassName("hover-color", false);
      contentBox.toggleClassName("classic-color", true);
      timeout(500, () => {
        contentBox.toggleClassName("hover-color", false);
        contentBox.toggleClassName("classic-color", false);
        contentBox.toggleClassName("shrink-color", true);
      });

      if (invoke) {
        for (const action of n.get_actions()) {
          n.invoke(action.id);
        }
      }

      hider.toggleClassName("hide", true);
      timeout(500, () => {
        hider.destroy();
        contentBox.toggleClassName("setup-shrink", true);
        // remove border and shrink from that state so border does not hang at end
        timeout(0, () => {
          contentBox.toggleClassName("setup-shrink", false);
          contentBox.toggleClassName("shrink", true);
        });
        for (const element of contentBox.get_children()) {
          element.destroy();
        }
        timeout(500, () => {
          values.remove(eventBox);
          eventBox.destroy();
        });
      });
    }

    function deleteIfDue() {
      if (due) {
        attemptCounter += 1;
        const snapshot = attemptCounter;
        timeout(GRACE, () => {
          deleteNotif(false, snapshot);
        });
      }
    }

    function setIfNotOne(status: number) {
      if (deleting !== 1) {
        deleting = status;
      }
    }

    eventBox.connect("click", (_, __) => {
      setIfNotOne(2);
    });
    eventBox.connect("hover", (_, __) => {
      if (deleting === 1) {
        return;
      }
      contentBox.toggleClassName("hover-color", true);
      contentBox.toggleClassName("classic-color", false);
      setIfNotOne(2);
    });
    eventBox.connect("hover-lost", (_, __) => {
      if (deleting === 1) {
        return;
      }
      contentBox.toggleClassName("hover-color", false);
      contentBox.toggleClassName("classic-color", true);
      setIfNotOne(0);
      deleteIfDue();
    });
    eventBox.connect("click-release", (_, event) => {
      setIfNotOne(0);
      const x = event.x;
      const y = event.y;
      const allocation = eventBox.get_allocation();
      const inside =
        x >= 0 && y >= 0 && x <= allocation.width && y <= allocation.height;

      if (!inside) {
        deleteIfDue();
        return;
      }
      deleteNotif(true);
    });

    // use hook so subscription dies on object destruction
    eventBox.hook(n, "resolved", (_, __) => {
      deleteNotif(false);
    });

    timeout(TIMEOUT, () => {
      // indicate the notification should be deleted at first chance
      due = true;
      deleteIfDue();
    });

    values.pack_end(eventBox, false, false, 0);
    values.show_all();
    contentBox.toggleClassName("transparent", false);
    contentBox.toggleClassName("visible", true);
  });

  values.connect("size-allocate", () => {
    updateInputRegion(values, notifManager);
  });

  updateInputRegion(values, notifManager);
  return notifManager;
}
