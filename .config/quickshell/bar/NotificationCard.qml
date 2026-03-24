pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: card

    property string notifSummary: ""
    property string notifBody: ""
    property string notifAppIcon: ""
    property string notifImage: ""
    signal dismissed()
    signal activated()

    property real slideOffset: 32
    property bool hovered: rootHover.hovered
    property bool removing: false
    property var pendingSignal: null

    height: cardFace.height
    clip: true

    function startRemoveAnimation(signal) {
        pendingSignal = signal;
        slideCard.from = cardFace.x;
        slideTrash.from = trashArea.x;
        removing = true;
        removeAnimation.start();
    }

    HoverHandler {
        id: rootHover
    }

    Rectangle {
        id: trashArea
        width: card.slideOffset
        height: cardFace.height
        radius: 6
        color: trashMouse.containsMouse ? Qt.lighter(Colors.danger, 1.2) : Colors.danger

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Text {
            anchors.centerIn: parent
            text: "󰩹"
            font.family: "Maple Mono NF"
            font.pixelSize: 16
            color: Colors.text
        }

        MouseArea {
            id: trashMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: card.startRemoveAnimation(card.dismissed)
        }
    }

    Rectangle {
        id: cardFace
        width: card.width
        height: cardContent.height + 16
        radius: 6
        color: card.hovered && !trashMouse.containsMouse ? Colors.surfaceHover : Colors.surface
        x: card.hovered && !card.removing ? card.slideOffset : 0

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Behavior on x {
            enabled: !card.removing
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            id: cardMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: card.startRemoveAnimation(card.activated)
        }

        Column {
            id: cardContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Row {
                width: parent.width
                spacing: 8

                Image {
                    id: notifImage
                    visible: status === Image.Ready
                    source: card.notifImage || card.notifAppIcon || ""
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
                        wrapMode: Text.Wrap
                    }

                    Text {
                        visible: card.notifBody !== ""
                        width: parent.width
                        text: card.notifBody
                        color: Colors.text
                        font.family: "Maple Mono NF"
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        opacity: 0.7
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: removeAnimation

        ParallelAnimation {
            NumberAnimation {
                id: slideCard
                target: cardFace
                property: "x"
                to: card.width + card.slideOffset
                duration: 750
                easing.type: Easing.InOutCubic
            }
            NumberAnimation {
                id: slideTrash
                target: trashArea
                property: "x"
                to: -card.slideOffset
                duration: 750
                easing.type: Easing.InOutCubic
            }
        }

        ScriptAction {
            script: {
                if (card.pendingSignal)
                    card.pendingSignal();
            }
        }
    }
}
