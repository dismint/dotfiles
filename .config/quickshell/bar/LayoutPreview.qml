pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Item {
    id: root
    width: 200
    height: 36

    required property var windowsModel
    required property int focusedWindowId
    required property bool skipAnimation

    property real totalWidth: {
        var max = 100;
        for (var i = 0; i < windowsModel.count; i++) {
            var w = windowsModel.get(i);
            max = Math.max(max, w.pixelX + w.pixelW);
        }
        return max;
    }

    property real totalHeight: {
        var max = 100;
        for (var i = 0; i < windowsModel.count; i++) {
            var w = windowsModel.get(i);
            max = Math.max(max, w.pixelY + w.pixelH);
        }
        return max;
    }

    property real targetScale: Math.min(width / totalWidth, height / totalHeight)
    property real scale: targetScale
    Behavior on scale {
        enabled: !root.skipAnimation
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    Item {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.totalWidth * root.scale
        height: root.totalHeight * root.scale

        Repeater {
            model: root.windowsModel

            delegate: Rectangle {
                id: rect
                required property int windowId
                required property string appId
                required property bool isFocused
                required property real pixelX
                required property real pixelY
                required property real pixelW
                required property real pixelH

                property real animX: pixelX
                property real animY: pixelY
                property real animW: pixelW
                property real animH: pixelH

                Behavior on animX {
                    enabled: !root.skipAnimation
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on animY {
                    enabled: !root.skipAnimation
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on animW {
                    enabled: !root.skipAnimation
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on animH {
                    enabled: !root.skipAnimation
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                x: animX * root.scale + 1
                y: animY * root.scale + 1
                width: Math.max(animW * root.scale - 2, 3)
                height: Math.max(animH * root.scale - 2, 3)
                radius: 2
                color: windowId === root.focusedWindowId ? Colors.primary : Qt.lighter(Colors.background, 2.5)

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Image {
                    anchors.fill: parent
                    anchors.margins: parent.width + parent.height < 60 ? 1 : 4
                    source: Quickshell.iconPath(IconResolver.resolve(rect.appId), true)
                    visible: source !== ""
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
    }
}
