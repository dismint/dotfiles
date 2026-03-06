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
    implicitHeight: 40
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
        // skip width / height animation when:
        // 1. opening the first window on a workspace
        // 2. switching workspaces
        panel.skipAnimation = (windowsModel.count === 0 && incomingWindows.length > 0) || workspaceChanged;

        var incomingById = {};
        for (var i = 0; i < incomingWindows.length; i++) {
            console.log(incomingWindows[i].keys());
            incomingById[incomingWindows[i].id] = incomingWindows[i];
        }

        var existingById = {};
        for (var i = 0; i < windowsModel.count; i++) {
            existingById[windowsModel.get(i).windowId] = i;
        }

        var windowsToRemove = [];
        // goes backwards so when we remove it is stable
        for (var i = windowsModel.count - 1; i >= 0; i--) {
            var modelItem = windowsModel.get(i);
            var incoming = incomingById[modelItem.windowId];
            if (incoming) {
                windowsModel.setProperty(i, "title", incoming.title);
                windowsModel.setProperty(i, "isFocused", incoming.is_focused);
                windowsModel.setProperty(i, "posX", incoming.layout.pos_in_scrolling_layout[0]);
                windowsModel.setProperty(i, "posY", incoming.layout.pos_in_scrolling_layout[1]);
                windowsModel.setProperty(i, "tileSizeX", incoming.layout.tile_size[0]);
                windowsModel.setProperty(i, "tileSizeY", incoming.layout.tile_size[1]);
                delete incomingById[modelItem.windowId];
            }

            if (!incoming || incoming.is_floating) {
                windowsToRemove.push(i);
            }
        }
        for (var r = 0; r < windowsToRemove.length; r++) {
            windowsModel.remove(windowsToRemove[r]);
        }

        for (var id in incomingById) {
            var win = incomingById[id];

            if (win.is_floating) {
                continue;
            }

            windowsModel.append({
                windowId: win.id,
                title: win.title,
                isFocused: win.is_focused,
                posX: win.layout.pos_in_scrolling_layout[0],
                posY: win.layout.pos_in_scrolling_layout[1],
                tileSizeX: win.layout.tile_size[0],
                tileSizeY: win.layout.tile_size[1]
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
