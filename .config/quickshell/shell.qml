import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    implicitWidth: 300
    implicitHeight: 120
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Tell the compositor: only this rectangle receives input
    mask: Region {
        item: pill
    }

    Rectangle {
        id: pill
        anchors.centerIn: parent

        width: area.containsMouse ? 260 : 80
        height: area.containsMouse ? 80 : 12
        radius: 8
        color: area.containsMouse ? "#3b82f6" : "#d1d5db"

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 300
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
