pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Rectangle {
    id: entry

    required property var app
    required property bool isSelected
    required property color bgColor
    required property color primaryColor
    required property color textColor
    required property color surfaceHoverColor

    signal clicked
    signal hovered

    height: 34
    radius: 4
    color: isSelected ? primaryColor : entryMouse.containsMouse ? surfaceHoverColor : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        Item {
            width: 22
            height: 22
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: iconImage
                anchors.fill: parent
                source: {
                    if (!entry.app || !entry.app.icon)
                        return "";
                    return Quickshell.iconPath(entry.app.icon, "");
                }
                fillMode: Image.PreserveAspectFit
                visible: status === Image.Ready
                sourceSize.width: 22
                sourceSize.height: 22
            }

            Text {
                anchors.centerIn: parent
                text: "󰣆"
                color: entry.isSelected ? entry.bgColor : entry.textColor
                font.family: "Maple Mono NF"
                font.pixelSize: 14
                opacity: 0.5
                visible: !iconImage.visible
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 30
            text: {
                if (!entry.app)
                    return "";
                var desc = entry.app.genericName || entry.app.comment || "";
                return desc ? entry.app.name + "  <font color='" + (entry.isSelected ? Qt.darker(entry.bgColor, 0.6) : Qt.darker(entry.textColor, 2.0)) + "'>" + desc + "</font>" : entry.app.name;
            }
            color: entry.isSelected ? entry.bgColor : entry.textColor
            font.family: "Maple Mono NF"
            font.pixelSize: 12
            font.weight: Font.Medium
            elide: Text.ElideRight
            textFormat: Text.RichText
        }
    }

    MouseArea {
        id: entryMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: entry.clicked()
        onContainsMouseChanged: {
            if (containsMouse)
                entry.hovered();
        }
    }
}
