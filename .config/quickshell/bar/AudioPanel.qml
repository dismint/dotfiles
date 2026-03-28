pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Pipewire

Rectangle {
    id: audioPanel

    required property var parentWindow

    property bool popupOpen: false
    property var activePopup: null

    property real collapsedWidth: 54
    property real inlineWidth: 278
    property real expandedWidth: collapsedWidth + inlineWidth + 8
    property real systrayWidth: 0
    property real notifWidth: 0

    property alias buttonMouse: buttonMouse
    property alias audioPopup: audioPopup

    width: popupOpen ? expandedWidth : collapsedWidth
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

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    property PwNode sink: Pipewire.defaultAudioSink
    property real sinkVolume: sink && sink.audio ? sink.audio.volume : 0
    property bool sinkMuted: sink && sink.audio ? sink.audio.muted : false

    function volumeIcon() {
        if (sinkMuted || sinkVolume === 0)
            return "󰝟";
        if (sinkVolume < 0.33)
            return "󰕿";
        if (sinkVolume < 0.66)
            return "󰖀";
        return "󰕾";
    }

    function volumePercent() {
        return Math.round(sinkVolume * 100);
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

    function togglePopup(popup, rightOffset) {
        if (popupOpen) {
            closePopup();
        } else {
            popup.popupX = parentWindow.width - popup.menuWidth - rightOffset;
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

    Rectangle {
        id: buttonBackground
        anchors.left: parent.left
        width: audioPanel.collapsedWidth
        height: parent.height
        radius: 4
        color: audioPanel.popupOpen ? Colors.primary : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Text {
            anchors.centerIn: parent
            text: audioPanel.volumeIcon() + " " + audioPanel.volumePercent()
            color: audioPanel.popupOpen ? Colors.background : Colors.text
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

    // inline device name shown when expanded
    Rectangle {
        id: inlineInfo
        anchors.left: buttonBackground.right
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: audioPanel.inlineWidth
        height: parent.height
        radius: 4
        clip: true
        visible: audioPanel.popupOpen
        color: "transparent"

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: 4
            text: audioPanel.sink ? audioPanel.sink.description : "no output"
            color: Colors.text
            font.family: "Maple Mono NF"
            font.pixelSize: 13
            font.weight: Font.Medium
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: buttonMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onWheel: event => {
            if (!audioPanel.sink || !audioPanel.sink.audio)
                return;
            var delta = event.angleDelta.y > 0 ? 0.02 : -0.02;
            audioPanel.sink.audio.volume = Math.max(0, Math.min(1, audioPanel.sink.audio.volume + delta));
        }
    }

    AudioPopup {
        id: audioPopup
        parentWindow: audioPanel.parentWindow
        visible: false
    }
}
