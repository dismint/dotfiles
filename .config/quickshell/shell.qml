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
        right: 6
        left: 6
        top: 6
    }
    implicitHeight: 60
    color: "transparent"

    Niri {
        id: niri
        Component.onCompleted: connect()
        onRawEventReceived: event => {
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

    function syncWindowsModel(incomingWindows, incomingWorkspaceId) {
        var workspaceChanged = (panel.lastWorkspaceId !== -1 && panel.lastWorkspaceId !== incomingWorkspaceId);
        panel.lastWorkspaceId = incomingWorkspaceId;
        panel.skipAnimation = (windowsModel.count === 0 && incomingWindows.length > 0) || workspaceChanged;

        // Build column structure to compute pixel positions
        var columns = {};
        for (var i = 0; i < incomingWindows.length; i++) {
            var win = incomingWindows[i];
            if (win.is_floating) continue;
            var col = win.layout.pos_in_scrolling_layout[0];
            var tile = win.layout.pos_in_scrolling_layout[1];
            if (!columns[col]) {
                columns[col] = { width: 0, tiles: {} };
            }
            if (win.layout.tile_size[0] > columns[col].width) {
                columns[col].width = win.layout.tile_size[0];
            }
            columns[col].tiles[tile] = win.layout.tile_size[1];
        }

        // Compute pixel X for each column
        var colPixelX = {};
        var sortedCols = Object.keys(columns).map(Number).sort(function(a,b) { return a-b; });
        var xAccum = 0;
        for (var c = 0; c < sortedCols.length; c++) {
            colPixelX[sortedCols[c]] = xAccum;
            xAccum += columns[sortedCols[c]].width;
        }

        // Compute pixel Y for each tile in each column
        var tilePixelY = {};
        for (var col in columns) {
            tilePixelY[col] = {};
            var sortedTiles = Object.keys(columns[col].tiles).map(Number).sort(function(a,b) { return a-b; });
            var yAccum = 0;
            for (var t = 0; t < sortedTiles.length; t++) {
                tilePixelY[col][sortedTiles[t]] = yAccum;
                yAccum += columns[col].tiles[sortedTiles[t]];
            }
        }

        var incomingById = {};
        for (var i = 0; i < incomingWindows.length; i++) {
            incomingById[incomingWindows[i].id] = incomingWindows[i];
        }

        var windowsToRemove = [];
        for (var i = windowsModel.count - 1; i >= 0; i--) {
            var modelItem = windowsModel.get(i);
            var incoming = incomingById[modelItem.windowId];
            if (incoming && !incoming.is_floating) {
                var col = incoming.layout.pos_in_scrolling_layout[0];
                var tile = incoming.layout.pos_in_scrolling_layout[1];
                windowsModel.setProperty(i, "title", incoming.title);
                windowsModel.setProperty(i, "isFocused", incoming.is_focused);
                windowsModel.setProperty(i, "pixelX", colPixelX[col] || 0);
                windowsModel.setProperty(i, "pixelY", tilePixelY[col] ? (tilePixelY[col][tile] || 0) : 0);
                windowsModel.setProperty(i, "pixelW", incoming.layout.tile_size[0]);
                windowsModel.setProperty(i, "pixelH", incoming.layout.tile_size[1]);
                delete incomingById[modelItem.windowId];
            } else {
                windowsToRemove.push(i);
            }
        }
        for (var r = 0; r < windowsToRemove.length; r++) {
            windowsModel.remove(windowsToRemove[r]);
        }

        for (var id in incomingById) {
            var win = incomingById[id];
            if (win.is_floating) continue;
            var col = win.layout.pos_in_scrolling_layout[0];
            var tile = win.layout.pos_in_scrolling_layout[1];
            windowsModel.append({
                windowId: win.id,
                appId: win.app_id,
                title: win.title,
                isFocused: win.is_focused,
                pixelX: colPixelX[col] || 0,
                pixelY: tilePixelY[col] ? (tilePixelY[col][tile] || 0) : 0,
                pixelW: win.layout.tile_size[0],
                pixelH: win.layout.tile_size[1]
            });
        }

        panel.focusedWindowId = -1;
        for (var f = 0; f < incomingWindows.length; f++) {
            if (incomingWindows[f].is_focused) {
                panel.focusedWindowId = incomingWindows[f].id;
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
                var incomingWorkspaceId = workspaceIndicator.getFocusedWorkspaceId();
                var incomingWindows = windows.filter(function (window) {
                    return window.workspace_id === incomingWorkspaceId && window.layout;
                });
                panel.syncWindowsModel(incomingWindows, incomingWorkspaceId);
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

    Bar.LayoutPreview {
        anchors.left: parent.left
        anchors.leftMargin: 8
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
        targetParent: barBackground
        outputFilter: "DP-1"
        onWorkspaceFocused: {
            if (!windowsProcess.running) {
                windowsProcess.running = true;
            }
        }
    }

    Bar.Time {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 16
    }
}
