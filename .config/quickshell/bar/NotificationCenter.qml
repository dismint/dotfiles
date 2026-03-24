pragma ComponentBehavior: Bound

import QtQuick

Rectangle {
    id: notificationCenter

    required property var parentWindow

    property bool expanded: false
    property bool popupOpen: false
    property var activeNotification: null
    property var activeNotificationRef: null
    property int activeGroupKey: -1

    property real collapsedWidth: 54
    property real inlineWidth: 450
    property real expandedWidth: collapsedWidth + inlineWidth + 8

    property real marqueeScrollTo: 0
    property int marqueeScrollDuration: 0

    property alias notificationHistory: notificationHistory
    property alias bellMouse: bellMouse
    property real systrayWidth: 0
    property var activePopup: null

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

    // each entry: { notifId, summary, body, appName, appIcon, image }
    // keyed by notification id
    ListModel {
        id: notificationHistory
    }

    property var notifRefById: ({})

    function findByNotifId(id) {
        for (var i = 0; i < notificationHistory.count; i++) {
            if (notificationHistory.get(i).notifId === id)
                return i;
        }
        return -1;
    }

    function clearNotifTracking(notifId) {
        delete notifRefById[notifId];
    }

    function clearInlinePreview() {
        expanded = false;
        activeNotification = null;
        activeNotificationRef = null;
        activeGroupKey = -1;
        autoDismissTimer.stop();
        marqueeAnimation.stop();
        marqueeText.x = 0;
    }

    function pushNotification(notification) {
        var notifId = notification.id;
        var summary = notification.summary ?? "";
        var body = notification.body ?? "";
        var appName = notification.appName ?? "";
        var appIcon = notification.appIcon ?? "";
        var image = notification.image ?? "";

        notifRefById[notifId] = notification;

        notificationHistory.insert(0, {
            notifId: notifId,
            summary: summary,
            body: body,
            appName: appName,
            appIcon: appIcon,
            image: image
        });

        activeNotification = {
            summary: summary,
            body: body,
            image: image,
            appIcon: appIcon
        };
        activeNotificationRef = notification;
        activeGroupKey = notifId;
        expanded = true;
        marqueeAnimation.stop();
        marqueeText.x = 0;
    }

    function handleRemoteClose(notifId) {
        var idx = findByNotifId(notifId);
        if (idx < 0)
            return;
        clearNotifTracking(notifId);
        notificationHistory.remove(idx);
        if (activeGroupKey === notifId)
            clearInlinePreview();
    }

    function handleCardAction(index) {
        var item = notificationHistory.get(index);
        if (!item)
            return;
        var ref = notifRefById[item.notifId];
        clearNotifTracking(item.notifId);
        notificationHistory.remove(index);
        if (ref && ref.actions && ref.actions.length > 0)
            ref.actions[0].invoke();
    }

    function dismissNotification(index) {
        var item = notificationHistory.get(index);
        if (item)
            clearNotifTracking(item.notifId);
        notificationHistory.remove(index);
    }

    function handlePreviewClick() {
        if (activeGroupKey !== -1) {
            var idx = findByNotifId(activeGroupKey);
            if (idx >= 0)
                handleCardAction(idx);
        }
        clearInlinePreview();
    }

    function computeMarquee() {
        var textWidth = inlineWidth - (inlineImage.visible ? inlineImage.width + 8 : 0);
        var overflow = marqueeText.implicitWidth - textWidth;
        if (overflow > 0) {
            marqueeScrollTo = -overflow - 16;
            marqueeScrollDuration = overflow * 8;
        } else {
            marqueeScrollTo = 0;
            marqueeScrollDuration = 0;
        }
        var scrollTime = overflow > 0 ? 2000 + overflow * 8 + 1000 + 300 : 0;
        autoDismissTimer.interval = Math.max(5000, scrollTime + 1000);
        autoDismissTimer.restart();
        marqueeAnimation.restart();
    }

    function closePopup() {
        if (!popupOpen || !activePopup)
            return;
        popupOpen = false;
        activePopup.animateOpen = false;
        popupCloseTimer.popup = activePopup;
        popupCloseTimer.restart();
        activePopup = null;
    }

    function togglePopup(popup, overrideSystrayWidth) {
        if (popupOpen) {
            closePopup();
        } else {
            var sw = (overrideSystrayWidth !== undefined) ? overrideSystrayWidth : systrayWidth;
            popup.popupX = parentWindow.width - expandedWidth - 8 - sw;
            activePopup = popup;
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
        onTriggered: notificationCenter.clearInlinePreview()
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
                    return notificationCenter.activeNotification.image || notificationCenter.activeNotification.appIcon || "";
                }
                width: 24
                height: 24
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: notificationCenter.inlineWidth - (inlineImage.visible ? inlineImage.width + 8 : 0) - 8
                height: marqueeContainer.height
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: marqueeText
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (!notificationCenter.activeNotification)
                            return "";
                        var summary = notificationCenter.activeNotification.summary;
                        var body = notificationCenter.activeNotification.body;
                        var full = body !== "" ? summary + ": " + body : summary;
                        return full.replace(/\n/g, " ↵ ");
                    }
                    color: Colors.text
                    font.family: "Maple Mono NF"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideNone
                    onTextChanged: function () {
                        if (marqueeText.text !== "")
                            Qt.callLater(notificationCenter.computeMarquee);
                    }
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
