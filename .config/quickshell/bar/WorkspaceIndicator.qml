pragma ComponentBehavior: Bound

import Niri 0.1
import QtQuick

Item {
    id: root

    required property var niri
    required property Item targetParent
    required property string outputFilter

    signal workspaceFocused

    // Workspace dots
    Row {
        id: workspacesRow
        anchors.centerIn: parent
        spacing: 16

        Repeater {
            id: workspacesRepeater
            model: root.niri.workspaces

            delegate: Item {
                id: workspaceItem
                required property int index
                required property int id
                required property bool isFocused
                required property bool isActive
                required property string output

                visible: output === root.outputFilter
                width: visible ? 12 : 0
                height: 12

                onIsFocusedChanged: {
                    if (isFocused) {
                        root.animateToWorkspace(this);
                        root.workspaceFocused();
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 12
                    height: 12
                    radius: 6
                    color: workspaceItem.isActive ? Colors.primary : Qt.lighter(Colors.background, 2.0)
                    opacity: workspaceItem.isActive ? 1.0 : 0.6

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.niri.focusWorkspaceById(workspaceItem.id)
                    }
                }
            }
        }
    }

    // The stretchy focus indicator
    Rectangle {
        id: indicator
        parent: root.targetParent
        z: 10
        height: 6
        radius: 3
        color: Colors.accent
        visible: initialized  // Hide until positioned

        property bool initialized: false
        property real centerX: 0
        property real centerY: 0
        property real stretchWidth: 6  // 6 = circle, larger = stretched oval

        x: centerX - stretchWidth / 2
        y: centerY - height / 2
        width: stretchWidth
    }

    // Animation for the stretch effect
    SequentialAnimation {
        id: stretchAnim

        property real fromX: 0
        property real toX: 0
        property real posY: 0

        // Phase 1: Stretch toward target
        ParallelAnimation {
            NumberAnimation {
                target: indicator
                property: "stretchWidth"
                to: Math.abs(stretchAnim.toX - stretchAnim.fromX) + 6
                duration: 120
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: indicator
                property: "centerX"
                to: (stretchAnim.fromX + stretchAnim.toX) / 2
                duration: 120
                easing.type: Easing.OutQuad
            }
        }

        // Phase 2: Shrink to target
        ParallelAnimation {
            NumberAnimation {
                target: indicator
                property: "stretchWidth"
                to: 6
                duration: 120
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: indicator
                property: "centerX"
                to: stretchAnim.toX
                duration: 120
                easing.type: Easing.InOutQuad
            }
        }
    }

    function animateToWorkspace(item) {
        var globalPos = item.mapToItem(root.targetParent, item.width / 2, item.height / 2);
        var distance = Math.abs(globalPos.x - indicator.centerX);

        // Skip animation if not initialized yet
        if (!indicator.initialized) {
            indicator.centerX = globalPos.x;
            indicator.centerY = globalPos.y;
            indicator.initialized = true;
            return;
        }

        if (distance > 5) {
            stretchAnim.fromX = indicator.centerX;
            stretchAnim.toX = globalPos.x;
            stretchAnim.posY = globalPos.y;
            indicator.centerY = globalPos.y;
            stretchAnim.restart();
        } else {
            indicator.centerX = globalPos.x;
            indicator.centerY = globalPos.y;
        }
    }

    function getFocusedWorkspaceId() {
        for (var i = 0; i < workspacesRepeater.count; i++) {
            var workspace = workspacesRepeater.itemAt(i);
            if (workspace && workspace.isFocused)
                return workspace.id;
        }
        return -1;
    }

    Component.onCompleted: {
        // Initialize position to first focused workspace
        Qt.callLater(() => {
            for (var i = 0; i < workspacesRepeater.count; i++) {
                var item = workspacesRepeater.itemAt(i);
                if (item && item.visible && item.isFocused) {
                    var pos = item.mapToItem(root.targetParent, item.width / 2, item.height / 2);
                    indicator.centerX = pos.x;
                    indicator.centerY = pos.y;
                    indicator.initialized = true;
                    return;
                }
            }
        });
    }
}
