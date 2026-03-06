pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root
    width: 100
    height: 24

    required property var windowsModel
    required property int focusedWindowId
    required property bool skipAnimation

    property var columnData: computeColumnData()

    function computeColumnData() {
        var cols = {};
        for (var i = 0; i < windowsModel.count; i++) {
            var w = windowsModel.get(i);
            var col = w.posX;
            var tile = w.posY;
            var tileWidth = w.tileSizeX;
            var tileHeight = w.tileSizeY;
            if (!cols[col]) {
                cols[col] = {
                    width: 0,
                    tiles: {}
                };
            }
            if (tileWidth > cols[col].width) {
                cols[col].width = tileWidth;
            }
            cols[col].tiles[tile] = tileHeight;
        }
        return cols;
    }

    Connections {
        target: root.windowsModel
        function onCountChanged() {
            root.columnData = root.computeColumnData();
        }
        function onDataChanged() {
            root.columnData = root.computeColumnData();
        }
    }

    property real totalWidth: {
        var total = 0;
        for (var col in columnData) {
            total += columnData[col].width;
        }
        return Math.max(total, 100);
    }

    property real maxColumnHeight: {
        var maxH = 0;
        for (var col in columnData) {
            var colHeight = 0;
            for (var tile in columnData[col].tiles) {
                colHeight += columnData[col].tiles[tile];
            }
            if (colHeight > maxH) {
                maxH = colHeight;
            }
        }
        return Math.max(maxH, 100);
    }

    property real scaleFactor: Math.min(width / totalWidth, height / maxColumnHeight)

    function getColumnX(targetCol) {
        var x = 0;
        var sortedCols = Object.keys(columnData).map(Number).sort(function (a, b) {
            return a - b;
        });
        for (var i = 0; i < sortedCols.length; i++) {
            if (sortedCols[i] < targetCol) {
                x += columnData[sortedCols[i]].width * scaleFactor;
            }
        }
        return x;
    }

    function getTileY(col, targetTile) {
        var y = 0;
        if (!columnData[col])
            return 0;
        var sortedTiles = Object.keys(columnData[col].tiles).map(Number).sort(function (a, b) {
            return a - b;
        });
        for (var i = 0; i < sortedTiles.length; i++) {
            if (sortedTiles[i] < targetTile) {
                y += columnData[col].tiles[sortedTiles[i]] * scaleFactor;
            }
        }
        return y;
    }

    Item {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.totalWidth * root.scaleFactor
        height: root.maxColumnHeight * root.scaleFactor

        Repeater {
            model: root.windowsModel

            delegate: Rectangle {
                required property int index
                required property int windowId
                required property string title
                required property bool isFocused
                required property int posX
                required property int posY
                required property real tileSizeX
                required property real tileSizeY

                property bool isFocusedWindow: windowId === root.focusedWindowId

                property real targetX: root.getColumnX(posX) + 1
                property real targetY: root.getTileY(posX, posY) + 1
                property real targetWidth: Math.max(tileSizeX * root.scaleFactor - 2, 3)
                property real targetHeight: Math.max(tileSizeY * root.scaleFactor - 2, 3)

                x: targetX
                y: targetY
                width: targetWidth
                height: targetHeight
                radius: 2
                color: isFocusedWindow ? Colors.primary : Qt.lighter(Colors.background, 2.5)

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
                Behavior on width {
                    enabled: !root.skipAnimation
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on height {
                    enabled: !root.skipAnimation
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
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
