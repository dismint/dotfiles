pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.SystemTray

Rectangle {
    id: systray

    required property var parentWindow

    property bool expanded: false
    property var activeMenu: null
    property var pendingMenu: null

    property real collapsedWidth: 54
    property real expandedWidth: collapsedWidth + iconRow.width + 12

    width: expanded ? expandedWidth : collapsedWidth
    height: 36
    radius: 4
    color: Colors.surface
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    function closeMenu() {
        if (activeMenu) {
            activeMenu.animateOpen = false;
            activeMenu = null;
        }
    }

    function openMenu(menu) {
        if (activeMenu === menu)
            return closeMenu();
        if (activeMenu) {
            activeMenu.animateOpen = false;
            pendingMenu = menu;
            switchTimer.restart();
        } else {
            activeMenu = menu;
            menu.visible = true;
            menu.animateOpen = true;
        }
    }

    Timer {
        id: switchTimer
        interval: 220
        onTriggered: {
            if (systray.activeMenu)
                systray.activeMenu.visible = false;
            systray.activeMenu = systray.pendingMenu;
            if (systray.pendingMenu) {
                systray.pendingMenu.visible = true;
                systray.pendingMenu.animateOpen = true;
                systray.pendingMenu = null;
            }
        }
    }

    Rectangle {
        id: toggleBackground
        anchors.left: parent.left
        width: systray.collapsedWidth
        height: parent.height
        radius: 4
        color: systray.expanded ? Colors.primary : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Text {
            anchors.centerIn: parent
            text: "⣿ " + SystemTray.items.values.length.toString()
            color: systray.expanded ? Colors.background : Colors.text
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
        id: toggleMouse
        anchors.left: parent.left
        width: systray.collapsedWidth
        height: parent.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            systray.closeMenu();
            systray.expanded = !systray.expanded;
        }
    }

    Row {
        id: iconRow
        anchors.left: parent.left
        anchors.leftMargin: systray.collapsedWidth + 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: SystemTray.items

            SystrayIcon {
                required property SystemTrayItem modelData
                item: modelData
                parentWindow: systray.parentWindow
                systray: systray
                anchors.verticalCenter: parent?.verticalCenter
            }
        }
    }
}
