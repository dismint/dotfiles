pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Rectangle {
    id: entry

    required property QsMenuEntry modelData
    required property bool animateOpen
    required property var systray

    height: modelData?.isSeparator ? 2 : 28
    radius: 4
    color: modelData?.isSeparator ? "transparent" : entryMouse.containsMouse ? Colors.surfaceHover : Colors.surface

    x: animateOpen ? 0 : -40
    opacity: animateOpen ? 1.0 : 0.0

    Behavior on x {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Text {
        visible: !entry.modelData?.isSeparator
        anchors.fill: parent
        anchors.leftMargin: 8
        color: Colors.text
        text: entry.modelData?.text ?? ""
        font.family: "Maple Mono NF"
        font.pixelSize: 13
        font.weight: Font.Medium
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        visible: entry.modelData?.isSeparator ?? false
        anchors.centerIn: parent
        width: parent.width - 8
        height: 2
        color: Colors.accent
    }

    MouseArea {
        id: entryMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: entry.modelData?.isSeparator ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: {
            entry.modelData.triggered();
            entry.systray.closeMenu();
        }
    }
}
