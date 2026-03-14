import QtQuick

Item {
    id: root

    property string value: ""
    property string _oldValue: ""

    width: 21
    height: 31

    onValueChanged: {
        if (_oldValue !== "") {
            liftAnimation.restart();
        }
        _oldValue = value;
    }

    // offset shadow
    Rectangle {
        x: 3
        y: 3
        width: 18
        height: 28
        radius: 4
        color: Colors.primary
    }

    Rectangle {
        id: tile
        x: 3
        y: 3
        width: 18
        height: 28
        radius: 4
        color: Qt.lighter(Colors.background, 2.0)

        Text {
            anchors.centerIn: parent
            text: root.value
            color: Colors.text
            font.family: "Maple Mono NF"
            font.pixelSize: 20
        }
    }

    SequentialAnimation {
        id: liftAnimation

        ParallelAnimation {
            NumberAnimation {
                target: tile
                property: "x"
                to: 0
                duration: 350
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: tile
                property: "y"
                to: 0
                duration: 350
                easing.type: Easing.OutCubic
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: tile
                property: "x"
                to: 3
                duration: 350
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: tile
                property: "y"
                to: 3
                duration: 350
                easing.type: Easing.InCubic
            }
        }
    }
}
