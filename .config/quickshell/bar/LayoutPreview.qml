pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Item {
    id: root
    width: 200
    height: 44

    required property var windowsModel
    required property int focusedWindowId
    required property bool skipAnimation

    // Compute total bounds from model
    property real totalWidth: {
        var maxRight = 100;
        for (var i = 0; i < windowsModel.count; i++) {
            var w = windowsModel.get(i);
            var right = w.pixelX + w.pixelW;
            if (right > maxRight)
                maxRight = right;
        }
        return maxRight;
    }

    property real totalHeight: {
        var maxBottom = 100;
        for (var i = 0; i < windowsModel.count; i++) {
            var w = windowsModel.get(i);
            var bottom = w.pixelY + w.pixelH;
            if (bottom > maxBottom)
                maxBottom = bottom;
        }
        return maxBottom;
    }

    property real targetScaleFactor: Math.min(width / totalWidth, height / totalHeight)
    property real scaleFactor: targetScaleFactor

    Behavior on scaleFactor {
        enabled: !root.skipAnimation
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Item {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.totalWidth * root.scaleFactor
        height: root.totalHeight * root.scaleFactor

        Repeater {
            model: root.windowsModel

            delegate: Rectangle {
                id: rect
                required property int index
                required property int windowId
                required property string appId
                required property string title
                required property bool isFocused
                required property real pixelX
                required property real pixelY
                required property real pixelW
                required property real pixelH

                property bool isFocusedWindow: windowId === root.focusedWindowId

                // Animate pixel positions
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

                x: animX * root.scaleFactor + 1
                y: animY * root.scaleFactor + 1
                width: Math.max(animW * root.scaleFactor - 2, 3)
                height: Math.max(animH * root.scaleFactor - 2, 3)
                radius: 2
                color: isFocusedWindow ? Colors.primary : Qt.lighter(Colors.background, 2.5)

                Image {
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height) - 4
                    height: width
                    source: Quickshell.iconPath(rect.appId, true)
                    visible: source !== ""
                    fillMode: Image.PreserveAspectFit
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                        easing.type: Easing.Linear
                    }
                }
            }
        }
    }
}
