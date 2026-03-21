pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

PopupWindow {
    id: popup

    property bool animateOpen: false
    property real shadowOffset: 5
    property real menuWidth: 350
    property real maxHeight: 400
    property real minHeight: 80

    required property var parentWindow
    required property var notificationModel
    property real popupX: 0

    signal dismissRequested(int index)
    signal actionRequested(int index)

    anchor.window: parentWindow
    anchor.edges: Edges.Top
    anchor.rect.x: popupX
    anchor.rect.y: parentWindow.height + 6
    color: "transparent"
    implicitWidth: menuWidth + shadowOffset
    implicitHeight: maxHeight + shadowOffset

    Item {
        id: popupClip
        property real rawContentHeight: notifColumn.height + 16
        property real contentHeight: Math.max(minHeight, rawContentHeight)
        property real panelHeight: Math.min(contentHeight, maxHeight)
        property real targetHeight: panelHeight + popup.shadowOffset
        anchors.left: parent.left
        anchors.right: parent.right
        height: popup.animateOpen ? targetHeight : 0
        opacity: popup.animateOpen ? 1.0 : 0.0
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            x: popup.shadowOffset
            y: popup.shadowOffset
            width: popup.menuWidth
            height: popupClip.panelHeight
            radius: 4
            color: Colors.primary
        }

        Rectangle {
            id: mainRect
            x: 0
            y: 0
            width: popup.menuWidth
            height: popupClip.panelHeight
            radius: 4
            color: Colors.surface
            border.color: Colors.primary
            border.width: 2

            Flickable {
                id: notifFlickable
                anchors.fill: parent
                anchors.margins: 8
                contentHeight: notifColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: notifColumn
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: popup.notificationModel

                        NotificationCard {
                            required property int index
                            required property string summary
                            required property string body
                            required property string appName
                            required property string appIcon
                            required property string image
                            required property string history
                            notifSummary: summary
                            notifBody: body
                            notifAppName: appName
                            notifAppIcon: appIcon
                            notifImage: image
                            notifHistory: history
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
