pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Item {
    id: trayEntry

    required property SystemTrayItem item
    required property var parentWindow
    required property var systray

    property int liftOffset: 2
    property bool hovered: trayMouse.containsMouse

    width: 28
    height: 28

    Rectangle {
        visible: trayEntry.hovered
        x: trayEntry.liftOffset
        y: trayEntry.liftOffset
        width: parent.width
        height: parent.height
        radius: 6
        color: Colors.primary
    }

    Rectangle {
        id: tile
        width: parent.width
        height: parent.height
        radius: 6
        color: trayEntry.hovered ? Colors.surfaceHover : Colors.surface

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
        x: trayEntry.hovered ? 0 : trayEntry.liftOffset
        y: trayEntry.hovered ? 0 : trayEntry.liftOffset

        Behavior on x {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        IconImage {
            source: trayEntry.item.icon
            anchors.centerIn: parent
            width: 20
            height: 20
        }
    }

    MouseArea {
        id: trayMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (trayEntry.item.hasMenu)
                trayEntry.systray.openMenu(contextMenu);
        }
    }

    QsMenuOpener {
        id: menuOpener
        menu: trayEntry.item.menu
    }

    SystrayContextMenu {
        id: contextMenu
        parentWindow: trayEntry.parentWindow
        systray: trayEntry.systray
        model: menuOpener.children
    }
}
