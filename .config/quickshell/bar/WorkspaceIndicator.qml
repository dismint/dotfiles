pragma ComponentBehavior: Bound

import Niri 0.1
import QtQuick

Item {
    id: root

    required property var niri
    required property string outputFilter

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 16

        onWidthChanged: {
            // Recalculate indicator position when layout changes (workspaces added/removed)
            for (var i = 0; i < repeater.count; i++) {
                var item = repeater.itemAt(i);
                if (item?.visible && item.isFocused) {
                    root.goTo(item, !indicator.initialized);
                    return;
                }
            }
        }

        Repeater {
            id: repeater
            model: root.niri.workspaces

            delegate: Item {
                id: workspace
                required property int id
                required property bool isFocused
                required property string output

                Component.onCompleted: console.log("Workspace created:", id, "output:", output, "focused:", isFocused)

                visible: output === root.outputFilter
                width: visible ? 12 : 0
                height: 12

                onIsFocusedChanged: {
                    console.log("Workspace", id, "focus changed to:", isFocused);
                    if (isFocused && visible && width > 0) {
                        root.goTo(this, false);
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
                        onClicked: root.niri.focusWorkspaceById(workspace.id)
                    }
                }
            }
        }
    }

    Rectangle {
        id: indicator
        z: 10
        height: 12
        radius: 6
        color: Colors.primary
        visible: initialized
        anchors.verticalCenter: row.verticalCenter

        property bool initialized: false
        property real centerX: 0
        property real stretchWidth: 12

        x: centerX - stretchWidth / 2
        width: stretchWidth
    }

    SequentialAnimation {
        id: stretchAnimation
        property real fromX: 0
        property real toX: 0

        ParallelAnimation {
            NumberAnimation {
                target: indicator
                property: "stretchWidth"
                to: Math.abs(stretchAnimation.toX - stretchAnimation.fromX) + 12
                duration: 120
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: indicator
                property: "centerX"
                to: (stretchAnimation.fromX + stretchAnimation.toX) / 2
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
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
                to: stretchAnimation.toX
                duration: 120
                easing.type: Easing.InOutQuad
            }
        }
    }

    function goTo(item, skipAnimation) {
        var targetX = row.x + item.x + item.width / 2;
        if (row.width <= 0)
            return;

        if (!indicator.initialized) {
            indicator.centerX = targetX;
            indicator.initialized = true;
            return;
        }

        // Skip animation if requested (e.g., when layout changes due to new workspace)
        if (skipAnimation) {
            indicator.centerX = targetX;
            return;
        }

        if (Math.abs(targetX - indicator.centerX) > 5) {
            stretchAnimation.fromX = indicator.centerX;
            stretchAnimation.toX = targetX;
            stretchAnimation.restart();
        } else {
            indicator.centerX = targetX;
        }
    }

    function getFocusedWorkspaceId() {
        for (var i = 0; i < repeater.count; i++) {
            var workspace = repeater.itemAt(i);
            if (workspace?.isFocused)
                return workspace.id;
        }
        return -1;
    }
}
