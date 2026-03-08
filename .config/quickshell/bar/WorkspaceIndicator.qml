pragma ComponentBehavior: Bound

import Niri 0.1
import QtQuick

Item {
    id: root

    required property var niri
    required property string outputFilter

    signal workspaceFocused

    // Workspace dots
    Row {
        id: workspacesRow
        anchors.centerIn: parent
        spacing: 16

        onWidthChanged: {
            if (!indicator.initialized) {
                for (var i = 0; i < workspacesRepeater.count; i++) {
                    var item = workspacesRepeater.itemAt(i);
                    if (item && item.visible && item.isFocused) {
                        root.animateToWorkspace(item);
                        return;
                    }
                }
            }
        }

        Repeater {
            id: workspacesRepeater
            model: root.niri.workspaces

            delegate: Item {
                id: workspaceItem
                required property int index
                required property int id
                required property bool isFocused
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
                    color: Qt.lighter(Colors.background, 1.8)
                    opacity: 0.8

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.niri.focusWorkspaceById(workspaceItem.id)
                    }
                }
            }
        }
    }

    // The stretchy focus indicator (same size as dots, stretches between them)
    Rectangle {
        id: indicator
        z: 10
        height: 12
        radius: 6
        color: Colors.primary
        visible: initialized
        anchors.verticalCenter: workspacesRow.verticalCenter

        property bool initialized: false
        property real centerX: 0
        property real stretchWidth: 12  // 12 = circle (same as dots), larger = stretched oval

        x: centerX - stretchWidth / 2
        width: stretchWidth
    }

    // Animation for the stretch effect
    SequentialAnimation {
        id: stretchAnim

        property real fromX: 0
        property real toX: 0

        // Phase 1: Stretch toward target
        ParallelAnimation {
            NumberAnimation {
                target: indicator
                property: "stretchWidth"
                to: Math.abs(stretchAnim.toX - stretchAnim.fromX) + 12
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
                to: 12
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
        // Calculate center X: Row's position + item's position within Row + half item width
        var centerX = workspacesRow.x + item.x + item.width / 2;

        // Skip if layout not ready
        if (workspacesRow.width <= 0) return;

        // First initialization - no animation
        if (!indicator.initialized) {
            indicator.centerX = centerX;
            indicator.initialized = true;
            return;
        }

        var distance = Math.abs(centerX - indicator.centerX);
        if (distance > 5) {
            stretchAnim.fromX = indicator.centerX;
            stretchAnim.toX = centerX;
            stretchAnim.restart();
        } else {
            indicator.centerX = centerX;
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
        // Initial positioning handled by onIsFocusedChanged
    }
}
