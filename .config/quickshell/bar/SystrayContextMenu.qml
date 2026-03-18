pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

PopupWindow {
    id: contextMenu

    property bool animateOpen: false
    property int shadowOffset: 5
    property int menuWidth: 200

    required property var parentWindow
    required property var systray
    required property var model

    anchor.window: parentWindow
    anchor.edges: Edges.Top
    anchor.rect.x: parentWindow.width - menuWidth - shadowOffset - 16
    anchor.rect.y: parentWindow.height + 6
    color: "transparent"
    implicitWidth: menuWidth + shadowOffset
    implicitHeight: menuClip.targetHeight

    onVisibleChanged: {
        if (!visible) {
            animateOpen = false;
            if (systray.activeMenu === contextMenu)
                systray.activeMenu = null;
        }
    }

    Item {
        id: menuClip
        property real targetHeight: menuCol.height + 16 + contextMenu.shadowOffset
        anchors.left: parent.left
        anchors.right: parent.right
        height: contextMenu.animateOpen ? targetHeight : 0
        opacity: contextMenu.animateOpen ? 1.0 : 0.0
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            x: contextMenu.shadowOffset
            y: contextMenu.shadowOffset
            width: contextMenu.menuWidth
            height: menuClip.targetHeight - contextMenu.shadowOffset
            radius: 4
            color: Colors.primary
        }

        Rectangle {
            x: 0
            y: 0
            width: contextMenu.menuWidth
            height: menuClip.targetHeight - contextMenu.shadowOffset
            radius: 4
            color: Colors.surface
            border.color: Colors.primary
            border.width: 2
        }

        Column {
            id: menuCol
            anchors.horizontalCenter: parent.horizontalCenter
            y: 8
            width: parent.width - 16
            spacing: 4

            Repeater {
                model: contextMenu.model

                SystrayContextMenuItem {
                    width: menuCol.width
                    animateOpen: contextMenu.animateOpen
                    systray: contextMenu.systray
                }
            }
        }
    }
}
