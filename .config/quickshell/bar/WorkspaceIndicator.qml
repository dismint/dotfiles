pragma ComponentBehavior: Bound

import Niri 0.1
import QtQuick

import "." as Bar

Item {
    id: root

    required property var niri
    required property Item targetParent
    required property string outputFilter

    signal workspaceFocused

    Row {
        id: workspacesRow
        anchors.centerIn: parent
        spacing: 16
        onWidthChanged: Qt.callLater(root.updateFocusIndicator)

        Repeater {
            id: workspacesRepeater
            model: root.niri.workspaces

            delegate: Item {
                id: workspaceItem
                required property int index
                required property int id
                required property string name
                required property string output
                required property bool isFocused
                required property bool isActive

                visible: workspaceItem.output === root.outputFilter
                width: visible ? 12 : 0
                height: 12

                onIsFocusedChanged: {
                    if (isFocused) {
                        Qt.callLater(root.updateFocusIndicator);
                        root.workspaceFocused();
                    }
                }

                Rectangle {
                    id: outerDot
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

    Rectangle {
        id: focusIndicator
        width: 6
        height: 6
        radius: 3
        color: "blue"
        visible: true
        parent: root.targetParent
        z: 10

        property real targetX: 0
        property real targetY: 0

        x: targetX - width / 2
        y: targetY - height / 2

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        id: smearTrail
        parent: root.targetParent
        z: 5
        height: 6
        radius: 3
        color: Colors.accent
        opacity: 0.5
        visible: smearAnimation.running

        property real startX: 0
        property real endX: 0
        property real centerY: 0

        x: Math.min(startX, endX)
        y: centerY - height / 2
        width: Math.abs(endX - startX) + 6

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    Rectangle {
        id: ghostTrail1
        parent: root.targetParent
        z: 4
        width: 6
        height: 6
        radius: 3
        color: Colors.accent
        opacity: 0
        visible: true

        property real targetX: 0
        property real targetY: 0

        x: targetX - width / 2
        y: targetY - height / 2

        Behavior on x {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        id: ghostTrail2
        parent: root.targetParent
        z: 3
        width: 6
        height: 6
        radius: 3
        color: Colors.accent
        opacity: 0
        visible: true

        property real targetX: 0
        property real targetY: 0

        x: targetX - width / 2
        y: targetY - height / 2

        Behavior on x {
            NumberAnimation {
                duration: 380
                easing.type: Easing.OutCubic
            }
        }
    }

    SequentialAnimation {
        id: smearAnimation

        ParallelAnimation {
            NumberAnimation {
                target: smearTrail
                property: "opacity"
                from: 0.6
                to: 0.3
                duration: 200
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: ghostTrail1
                property: "opacity"
                from: 0.4
                to: 0
                duration: 300
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: ghostTrail2
                property: "opacity"
                from: 0.25
                to: 0
                duration: 350
                easing.type: Easing.OutQuad
            }
        }

        NumberAnimation {
            target: smearTrail
            property: "opacity"
            to: 0
            duration: 100
        }
    }

    function updateFocusIndicator() {
        for (var i = 0; i < workspacesRepeater.count; i++) {
            var item = workspacesRepeater.itemAt(i);
            if (item && item.visible && item.isFocused) {
                var globalPos = item.mapToItem(root.targetParent, item.width / 2, item.height / 2);
                var prevX = focusIndicator.targetX;
                var distance = Math.abs(globalPos.x - prevX);

                if (distance > 5) {
                    smearTrail.startX = prevX;
                    smearTrail.endX = globalPos.x;
                    smearTrail.centerY = globalPos.y;

                    ghostTrail1.targetX = prevX;
                    ghostTrail1.targetY = globalPos.y;
                    ghostTrail2.targetX = prevX;
                    ghostTrail2.targetY = globalPos.y;

                    Qt.callLater(function () {
                        ghostTrail1.targetX = globalPos.x;
                        ghostTrail2.targetX = globalPos.x;
                    });

                    smearAnimation.restart();
                }

                focusIndicator.targetX = globalPos.x;
                focusIndicator.targetY = globalPos.y;
                focusIndicator.visible = true;
                return;
            }
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
        Qt.callLater(updateFocusIndicator);
    }
}
