pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: card

    property string notifSummary: ""
    property string notifBody: ""
    property string notifAppName: ""
    property string notifAppIcon: ""
    property string notifImage: ""
    property string notifHistory: "[]"

    signal dismissed()
    signal activated()

    property int liftOffset: 2
    property bool hovered: cardMouse.containsMouse && !cardMouse.drag.active
    property bool dragging: cardMouse.drag.active
    property var parsedHistory: {
        try { return JSON.parse(notifHistory); }
        catch(e) { return []; }
    }

    height: cardFace.height + liftOffset

    Rectangle {
        visible: card.hovered && !card.dragging
        x: card.liftOffset
        y: card.liftOffset
        width: cardFace.width
        height: cardFace.height
        radius: 6
        color: Colors.primary
    }

    Rectangle {
        id: cardFace
        width: card.width
        height: cardContent.height + 16
        radius: 6
        color: card.hovered ? Colors.surfaceHover : Colors.surface

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        x: card.liftOffset
        y: card.hovered && !card.dragging ? 0 : card.liftOffset

        Behavior on y {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            id: cardMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            drag.target: cardFace
            drag.axis: Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: card.width

            onPressed: {
                snapBackAnimation.stop();
                dismissAnimation.stop();
            }

            onClicked: card.activated()

            onReleased: {
                if (cardFace.x > card.width * 0.3) {
                    dismissAnimation.start();
                } else {
                    snapBackAnimation.start();
                }
            }
        }

        Column {
            id: cardContent
            anchors.left: parent.left
            anchors.right: dismissButton.left
            anchors.leftMargin: 8
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            // current (latest) notification
            Row {
                width: parent.width
                spacing: 8

                Image {
                    id: notifImage
                    visible: status === Image.Ready
                    source: {
                        if (card.notifImage !== "")
                            return card.notifImage;
                        if (card.notifAppIcon !== "")
                            return card.notifAppIcon;
                        return "";
                    }
                    width: 32
                    height: 32
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: parent.width - (notifImage.visible ? notifImage.width + parent.spacing : 0)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        width: parent.width
                        text: card.notifSummary
                        color: Colors.text
                        font.family: "Maple Mono NF"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: card.notifBody !== ""
                        width: parent.width
                        text: card.notifBody
                        color: Colors.text
                        font.family: "Maple Mono NF"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.WordWrap
                        opacity: 0.7
                    }
                }
            }

            // previous messages in this group
            Repeater {
                model: card.parsedHistory

                Text {
                    required property var modelData
                    required property int index
                    width: parent.width
                    text: modelData.body ?? ""
                    color: Colors.text
                    font.family: "Maple Mono NF"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    opacity: 0.5
                    leftPadding: notifImage.visible ? notifImage.width + 8 : 0
                }
            }
        }

        Rectangle {
            id: dismissButton
            z: 1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 4
            anchors.rightMargin: 4
            width: 20
            height: 20
            radius: 4
            color: dismissMouse.containsMouse ? Colors.surfaceHover : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                anchors.centerIn: parent
                text: "󰅖"
                font.family: "Maple Mono NF"
                font.pixelSize: 12
                color: Colors.text
            }

            MouseArea {
                id: dismissMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: card.dismissed()
            }
        }
    }

    NumberAnimation {
        id: snapBackAnimation
        target: cardFace
        property: "x"
        to: card.liftOffset
        duration: 200
        easing.type: Easing.OutCubic
    }

    SequentialAnimation {
        id: dismissAnimation

        ParallelAnimation {
            NumberAnimation {
                target: cardFace
                property: "x"
                to: card.width
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: cardFace
                property: "opacity"
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        ScriptAction {
            script: card.dismissed()
        }
    }
}
