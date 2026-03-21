pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Notifications

Rectangle {
    id: notificationCenter

    required property var parentWindow

    property bool expanded: false
    property bool popupOpen: false
    property var activeNotification: null
    property var activeNotificationRef: null
    property string activeGroupKey: ""

    property real collapsedWidth: 54
    property real inlineWidth: 300
    property real expandedWidth: collapsedWidth + inlineWidth + 8

    property real marqueeScrollTo: 0
    property int marqueeScrollDuration: 0

    property alias notificationHistory: notificationHistory
    property alias bellMouse: bellMouse
    property real systrayWidth: 0

    width: (expanded || popupOpen) ? expandedWidth : collapsedWidth
    height: 36
    radius: 4
    color: Colors.surface
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: 350
            easing.type: Easing.OutCubic
        }
    }

    // grouped notification model
    // each entry: { groupKey, summary, body, appName, appIcon, image, history }
    // grouped by appName + summary (e.g. same discord conversation)
    // history is a JSON string of previous versions: [{"body":"..."}, ...]
    ListModel {
        id: notificationHistory
    }

    // tracks which notification id is the latest for each group
    property var latestNotifIdByGroup: ({})
    // stores notification object refs for invoking actions from the popup
    property var notifRefsByGroup: ({})

    function findByGroupKey(key) {
        for (var i = 0; i < notificationHistory.count; i++) {
            if (notificationHistory.get(i).groupKey === key)
                return i;
        }
        return -1;
    }

    function pushNotification(notification) {
        var summary = notification.summary ?? "";
        var body = notification.body ?? "";
        var appName = notification.appName ?? "";
        var appIcon = notification.appIcon ?? "";
        var image = notification.image ?? "";
        var groupKey = appName + ":" + summary;
        var notifId = notification.id;

        latestNotifIdByGroup[groupKey] = notifId;
        notifRefsByGroup[groupKey] = notification;

        var existingIndex = findByGroupKey(groupKey);
        if (existingIndex >= 0) {
            var existing = notificationHistory.get(existingIndex);
            var oldHistory = JSON.parse(existing.history || "[]");
            oldHistory.unshift({ body: existing.body });
            notificationHistory.setProperty(existingIndex, "body", body);
            notificationHistory.setProperty(existingIndex, "appIcon", appIcon);
            notificationHistory.setProperty(existingIndex, "image", image);
            notificationHistory.setProperty(existingIndex, "history", JSON.stringify(oldHistory));
            if (existingIndex > 0)
                notificationHistory.move(existingIndex, 0, 1);
        } else {
            notificationHistory.insert(0, {
                groupKey: groupKey,
                summary: summary,
                body: body,
                appName: appName,
                appIcon: appIcon,
                image: image,
                history: "[]"
            });
        }

        activeNotification = { summary: summary, body: body, image: image, appIcon: appIcon };
        activeNotificationRef = notification;
        activeGroupKey = groupKey;
        expanded = true;
        marqueeAnimation.stop();
        marqueeText.x = 0;
        computeMarqueeTimer.restart();
    }

    // called when a notification is closed by the remote app
    // keeps history intact, only collapses the inline preview
    function handleRemoteClose(notifId, groupKey) {
        if (latestNotifIdByGroup[groupKey] !== notifId)
            return;
        delete latestNotifIdByGroup[groupKey];
        delete notifRefsByGroup[groupKey];
        if (activeGroupKey === groupKey) {
            expanded = false;
            activeNotification = null;
            activeNotificationRef = null;
            activeGroupKey = "";
            autoDismissTimer.stop();
            marqueeAnimation.stop();
            marqueeText.x = 0;
        }
    }

    // called when a card in the popup is clicked
    function handleCardAction(index) {
        var item = notificationHistory.get(index);
        if (!item)
            return;
        var ref = notifRefsByGroup[item.groupKey];
        if (ref && ref.actions && ref.actions.length > 0)
            ref.actions[0].invoke();
        delete latestNotifIdByGroup[item.groupKey];
        delete notifRefsByGroup[item.groupKey];
        notificationHistory.remove(index);
    }

    function dismissNotification(index) {
        var item = notificationHistory.get(index);
        if (item) {
            delete latestNotifIdByGroup[item.groupKey];
            delete notifRefsByGroup[item.groupKey];
        }
        notificationHistory.remove(index);
    }

    function handlePreviewClick() {
        var ref = activeNotificationRef;
        if (ref && ref.actions && ref.actions.length > 0)
            ref.actions[0].invoke();
        if (activeGroupKey !== "") {
            delete latestNotifIdByGroup[activeGroupKey];
            delete notifRefsByGroup[activeGroupKey];
            var idx = findByGroupKey(activeGroupKey);
            if (idx >= 0)
                notificationHistory.remove(idx);
        }
        expanded = false;
        activeNotification = null;
        activeNotificationRef = null;
        activeGroupKey = "";
        autoDismissTimer.stop();
        marqueeAnimation.stop();
        marqueeText.x = 0;
    }

    Timer {
        id: computeMarqueeTimer
        interval: 50
        onTriggered: {
            var textWidth = notificationCenter.inlineWidth - (inlineImage.visible ? inlineImage.width + 8 : 0);
            var overflow = marqueeText.implicitWidth - textWidth;
            if (overflow > 0) {
                notificationCenter.marqueeScrollTo = -overflow - 16;
                notificationCenter.marqueeScrollDuration = overflow * 8;
            } else {
                notificationCenter.marqueeScrollTo = 0;
                notificationCenter.marqueeScrollDuration = 0;
            }
            var scrollTime = overflow > 0 ? 2000 + overflow * 8 + 1000 + 300 : 0;
            autoDismissTimer.interval = Math.max(5000, scrollTime + 1000);
            autoDismissTimer.restart();
            marqueeAnimation.restart();
        }
    }

    function togglePopup(popup) {
        if (popupOpen) {
            popupOpen = false;
            popup.animateOpen = false;
            popupCloseTimer.popup = popup;
            popupCloseTimer.restart();
        } else {
            var finalX = parentWindow.width - expandedWidth - 8 - systrayWidth;
            popup.popupX = finalX;
            popupOpen = true;
            popup.visible = true;
            popup.animateOpen = true;
        }
    }

    Timer {
        id: popupCloseTimer
        property var popup: null
        interval: 350
        onTriggered: {
            if (popup)
                popup.visible = false;
        }
    }

    Timer {
        id: autoDismissTimer
        interval: 5000
        onTriggered: {
            notificationCenter.expanded = false;
            notificationCenter.activeNotification = null;
            notificationCenter.activeNotificationRef = null;
            notificationCenter.activeGroupKey = "";
            marqueeAnimation.stop();
            marqueeText.x = 0;
        }
    }

    Rectangle {
        id: bellButton
        anchors.left: parent.left
        width: notificationCenter.collapsedWidth
        height: parent.height
        radius: 4
        color: notificationCenter.popupOpen ? Colors.primary : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Text {
            anchors.centerIn: parent
            text: "󰂚 " + notificationHistory.count
            color: notificationCenter.popupOpen ? Colors.background : Colors.text
            font.family: "Maple Mono NF"
            font.pixelSize: 14
            font.weight: Font.Medium

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    MouseArea {
        id: bellMouse
        anchors.left: parent.left
        width: notificationCenter.collapsedWidth
        height: parent.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    Rectangle {
        id: marqueeContainer
        anchors.left: bellButton.right
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: notificationCenter.inlineWidth
        height: parent.height
        radius: 4
        clip: true
        visible: (notificationCenter.expanded && notificationCenter.activeNotification !== null) || notificationCenter.popupOpen
        color: marqueeMouse.containsMouse && notificationCenter.activeNotificationRef ? Colors.surfaceHover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            id: marqueeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: notificationCenter.activeNotificationRef ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: notificationCenter.handlePreviewClick()
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 4
            spacing: 8

            Image {
                id: inlineImage
                visible: status === Image.Ready
                source: {
                    if (!notificationCenter.activeNotification)
                        return "";
                    if (notificationCenter.activeNotification.image !== "")
                        return notificationCenter.activeNotification.image;
                    if (notificationCenter.activeNotification.appIcon !== "")
                        return notificationCenter.activeNotification.appIcon;
                    return "";
                }
                width: 24
                height: 24
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: notificationCenter.inlineWidth - (inlineImage.visible ? inlineImage.width + 8 : 0) - 8
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: marqueeText
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (!notificationCenter.activeNotification)
                            return "";
                        var summary = notificationCenter.activeNotification.summary;
                        var body = notificationCenter.activeNotification.body;
                        if (body !== "")
                            return summary + ": " + body;
                        return summary;
                    }
                    color: Colors.text
                    font.family: "Maple Mono NF"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideNone
                }
            }
        }
    }

    SequentialAnimation {
        id: marqueeAnimation
        loops: Animation.Infinite

        PauseAnimation {
            duration: 2000
        }

        NumberAnimation {
            target: marqueeText
            property: "x"
            from: 0
            to: notificationCenter.marqueeScrollTo
            duration: notificationCenter.marqueeScrollDuration
            easing.type: Easing.Linear
        }

        PauseAnimation {
            duration: 1000
        }

        NumberAnimation {
            target: marqueeText
            property: "x"
            to: 0
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
}
