pragma Singleton
import QtQuick

QtObject {
    readonly property color primary: "#84ab89"
    readonly property color accent: "#3e5587"
    readonly property color background: "#0f0e12"
    readonly property color text: "#d3d9b2"
    readonly property color surface: Qt.lighter(background, 2.0)
    readonly property color surfaceHover: Qt.lighter(background, 3.0)
    readonly property color danger: "#c45050"
}
