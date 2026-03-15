pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Row {
    id: systray

    required property var parentWindow

    property var activeMenu: null
    property var pendingMenu: null

    function closeMenu() {
        if (activeMenu) {
            activeMenu.animateOpen = false;
            activeMenu = null;
        }
    }

    function openMenu(menu) {
        if (activeMenu === menu) {
            menu.animateOpen = false;
            activeMenu = null;
            return;
        }
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

    spacing: 8

    Repeater {
        model: SystemTray.items

        Rectangle {
            id: trayEntry
            required property SystemTrayItem modelData
            required property int index
            width: 28
            height: 28
            radius: 6
            color: trayMouse.containsMouse ? Colors.primary : "transparent"
            anchors.verticalCenter: parent?.verticalCenter

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            IconImage {
                source: trayEntry.modelData.icon
                anchors.centerIn: parent
                width: 20
                height: 20
            }

            MouseArea {
                id: trayMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: event => {
                    if (trayEntry.modelData.hasMenu)
                        systray.openMenu(contextMenu);
                }
            }

            QsMenuOpener {
                id: menuOpener
                menu: trayEntry.modelData.menu
            }

            PopupWindow {
                id: contextMenu
                property bool animateOpen: false

                anchor.window: systray.parentWindow
                anchor.edges: Edges.Top
                anchor.rect.x: systray.parentWindow.width - 200 - 16
                anchor.rect.y: systray.parentWindow.height + 6
                color: "transparent"
                implicitWidth: 200
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
                    property real targetHeight: menuCol.height + 16
                    anchors.left: parent.left
                    anchors.right: parent.right
                    y: 0
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
                        anchors.left: parent.left
                        anchors.right: parent.right
                        y: 0
                        height: menuClip.targetHeight
                        color: Colors.background
                        radius: 8
                        border.color: Colors.primary
                        border.width: 1
                    }

                    Column {
                        id: menuCol
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 8
                        width: parent.width - 16
                        spacing: 4

                        Repeater {
                            model: menuOpener.children

                            Rectangle {
                                id: entry
                                required property QsMenuEntry modelData
                                required property int index
                                width: menuCol.width
                                height: modelData.isSeparator ? 2 : 28
                                radius: 4
                                color: entryMouse.containsMouse && !modelData.isSeparator ? Colors.accent : "transparent"

                                x: contextMenu.animateOpen ? 0 : -40
                                opacity: contextMenu.animateOpen ? 1.0 : 0.0

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

                                Text {
                                    visible: !entry.modelData.isSeparator
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    color: Colors.text
                                    text: entry.modelData.text
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 13
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Rectangle {
                                    visible: entry.modelData.isSeparator
                                    anchors.centerIn: parent
                                    width: parent.width - 8
                                    height: 1
                                    color: Colors.accent
                                }

                                MouseArea {
                                    id: entryMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        entry.modelData.triggered();
                                        systray.closeMenu();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
