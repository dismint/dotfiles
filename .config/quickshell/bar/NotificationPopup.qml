pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell

PopupWindow {
    id: popup

    property bool animateOpen: false
    property real menuWidth: 350
    property real maxHeight: 560
    property real minHeight: 60

    required property var parentWindow
    required property var notificationModel
    property real popupX: 0

    signal dismissRequested(int index)
    signal actionRequested(int index)
    signal clearAllRequested()

    anchor.window: parentWindow
    anchor.edges: Edges.Top
    anchor.rect.x: popupX
    anchor.rect.y: parentWindow.height + 6
    color: "transparent"
    implicitWidth: menuWidth
    implicitHeight: maxHeight

    Item {
        id: popupClip

        property real panelHeight: Math.min(Math.max(minHeight, notifColumn.height + 16), maxHeight)
        property bool openCloseAnimating: false

        anchors.left: parent.left
        anchors.right: parent.right
        height: popup.animateOpen ? panelHeight : 0
        opacity: popup.animateOpen ? 1.0 : 0.0
        clip: true

        Connections {
            target: popup
            function onAnimateOpenChanged() { popupClip.openCloseAnimating = true }
        }

        Behavior on height {
            enabled: popupClip.openCloseAnimating
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
                onRunningChanged: if (!running) popupClip.openCloseAnimating = false
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            id: panel

            property real displayHeight: popupClip.panelHeight

            width: popup.menuWidth
            height: displayHeight
            radius: 4
            color: Colors.surface
            border.color: Colors.primary
            border.width: 2

            Connections {
                target: popupClip
                function onPanelHeightChanged() {
                    if (popupClip.panelHeight < panel.displayHeight) {
                        shrinkAnimation.from = panel.displayHeight;
                        shrinkAnimation.to = popupClip.panelHeight;
                        shrinkAnimation.start();
                    } else {
                        shrinkAnimation.stop();
                        panel.displayHeight = popupClip.panelHeight;
                    }
                }
            }

            NumberAnimation {
                id: shrinkAnimation
                target: panel
                property: "displayHeight"
                duration: 300
                easing.type: Easing.OutCubic
            }

            Flickable {
                id: notifFlickable
                anchors.fill: parent
                anchors.margins: 8
                contentHeight: notifColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    policy: notifFlickable.contentHeight > notifFlickable.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: Colors.primary
                        opacity: 0.6
                    }
                }

                Column {
                    id: notifColumn
                    width: parent.width
                    spacing: 6

                    Rectangle {
                        id: clearAllButton
                        width: notifColumn.width
                        height: visible ? 28 : 0
                        radius: 6
                        visible: popup.notificationModel.count > 0
                        opacity: visible ? 1.0 : 0.0
                        color: clearAllMouse.containsMouse ? Qt.lighter(Colors.accent, 1.3) : Colors.accent

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
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
                            anchors.centerIn: parent
                            text: "clear all"
                            color: Colors.text
                            font.family: "Maple Mono NF"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: clearAllMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.clearAllRequested()
                        }
                    }

                    Repeater {
                        model: popup.notificationModel

                        NotificationCard {
                            required property int index
                            required property string summary
                            required property string body
                            required property string appIcon
                            required property string image
                            notifSummary: summary
                            notifBody: body
                            notifAppIcon: appIcon
                            notifImage: image
                            width: notifColumn.width
                            onDismissed: popup.dismissRequested(index)
                            onActivated: popup.actionRequested(index)
                        }
                    }
                }
            }

            Text {
                visible: popup.notificationModel.count === 0
                anchors.centerIn: parent
                text: "no notifications"
                color: Colors.text
                font.family: "Maple Mono NF"
                font.pixelSize: 13
                opacity: 0.5
            }
        }
    }
}
