pragma ComponentBehavior: Bound

import Niri 0.1
import QtQuick
import Quickshell
import Quickshell.Io

import "bar" as Bar

PanelWindow {
    id: panel
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        right: 60
        left: 60
        top: 20
    }
    implicitHeight: 60
    color: "transparent"

    Niri {
        id: niri
        Component.onCompleted: connect()
        onRawEventReceived: {
            if (!windowsProcess.running) {
                windowsProcess.running = true;
            } else {
                panel.pendingRefresh = true;
            }
        }
    }

    property int focusedWindowId: -1
    property bool skipAnimation: false
    property int lastWorkspaceId: -1
    property bool pendingRefresh: false

    ListModel {
        id: windowsModel
    }

    function computePixelPositions(windows) {
        var columns = {};

        for (var i = 0; i < windows.length; i++) {
            var win = windows[i];
            var col = win.layout.pos_in_scrolling_layout[0];
            var tile = win.layout.pos_in_scrolling_layout[1];
            if (!columns[col])
                columns[col] = {
                    width: 0,
                    tiles: {}
                };
            columns[col].width = Math.max(columns[col].width, win.layout.tile_size[0]);
            columns[col].tiles[tile] = win.layout.tile_size[1];
        }

        var colX = {};
        var sortedCols = Object.keys(columns).map(Number).sort((a, b) => a - b);
        var x = 0;
        for (var c of sortedCols) {
            colX[c] = x;
            x += columns[c].width;
        }

        var maxColHeight = 0;
        for (var col in columns) {
            var colHeight = 0;
            for (var t in columns[col].tiles)
                colHeight += columns[col].tiles[t];
            maxColHeight = Math.max(maxColHeight, colHeight);
        }

        // normalize
        var tileY = {};
        var tileH = {};
        for (var col in columns) {
            tileY[col] = {};
            tileH[col] = {};
            var colHeight = 0;
            for (var t in columns[col].tiles)
                colHeight += columns[col].tiles[t];
            var scale = colHeight > 0 ? maxColHeight / colHeight : 1;
            var sortedTiles = Object.keys(columns[col].tiles).map(Number).sort((a, b) => a - b);
            var y = 0;
            for (var t of sortedTiles) {
                tileY[col][t] = y;
                tileH[col][t] = columns[col].tiles[t] * scale;
                y += tileH[col][t];
            }
        }

        return {
            colX,
            tileY,
            tileH
        };
    }

    function syncWindowsModel(windows, workspaceId) {
        var workspaceChanged = lastWorkspaceId !== -1 && workspaceId !== lastWorkspaceId;
        var firstLoad = windowsModel.count === 0 && windows.length > 0;
        skipAnimation = firstLoad || workspaceChanged;
        lastWorkspaceId = workspaceId;

        var positions = computePixelPositions(windows);
        var incomingById = {};
        for (var win of windows)
            incomingById[win.id] = win;

        var toRemove = [];
        for (var i = windowsModel.count - 1; i >= 0; i--) {
            var item = windowsModel.get(i);
            var incoming = incomingById[item.windowId];
            if (incoming) {
                var col = incoming.layout.pos_in_scrolling_layout[0];
                var tile = incoming.layout.pos_in_scrolling_layout[1];
                windowsModel.setProperty(i, "title", incoming.title);
                windowsModel.setProperty(i, "isFocused", incoming.is_focused);
                windowsModel.setProperty(i, "pixelX", positions.colX[col] || 0);
                windowsModel.setProperty(i, "pixelY", positions.tileY[col]?.[tile] || 0);
                windowsModel.setProperty(i, "pixelW", incoming.layout.tile_size[0]);
                windowsModel.setProperty(i, "pixelH", positions.tileH[col]?.[tile] || incoming.layout.tile_size[1]);
                delete incomingById[incoming.id];
            } else {
                toRemove.push(i);
            }
        }

        for (var r of toRemove)
            windowsModel.remove(r);

        for (var id in incomingById) {
            var win = incomingById[id];
            var col = win.layout.pos_in_scrolling_layout[0];
            var tile = win.layout.pos_in_scrolling_layout[1];
            windowsModel.append({
                windowId: win.id,
                appId: win.app_id,
                title: win.title,
                isFocused: win.is_focused,
                pixelX: positions.colX[col] || 0,
                pixelY: positions.tileY[col]?.[tile] || 0,
                pixelW: win.layout.tile_size[0],
                pixelH: positions.tileH[col]?.[tile] || win.layout.tile_size[1]
            });
        }

        focusedWindowId = -1;
        for (var win of windows) {
            if (win.is_focused) {
                focusedWindowId = win.id;
                break;
            }
        }
    }

    Process {
        id: windowsProcess
        command: ["niri", "msg", "-j", "windows"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var windows = JSON.parse(data);
                var focusedWorkspaceId = workspaceIndicator.getFocusedWorkspaceId();
                var filtered = windows.filter(w => w.workspace_id === focusedWorkspaceId && w.layout && !w.is_floating);
                panel.syncWindowsModel(filtered, focusedWorkspaceId);
            }
        }
        onRunningChanged: {
            if (!running && panel.pendingRefresh) {
                panel.pendingRefresh = false;
                running = true;
            }
        }
    }

    Rectangle {
        id: barBackground
        anchors.fill: parent
        radius: 8
        color: Bar.Colors.background
    }

    Bar.Time {
        id: clockDisplay
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
    }

    Bar.LayoutPreview {
        id: layoutPreview
        anchors.left: clockDisplay.right
        anchors.leftMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        windowsModel: windowsModel
        focusedWindowId: panel.focusedWindowId
        skipAnimation: panel.skipAnimation
    }

    Bar.WorkspaceIndicator {
        id: workspaceIndicator
        anchors.centerIn: parent
        width: 200
        height: parent.height
        niri: niri
        outputFilter: "DP-1"
    }

    Bar.SystrayContent {
        id: systrayContent
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        parentWindow: panel
    }
}
