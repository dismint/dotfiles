import QtQuick

Item {
    id: root

    property string value: ""
    property string _oldValue: ""
    property bool _animating: false

    width: 18
    height: 28

    onValueChanged: {
        if (_oldValue !== "" && _oldValue !== value) {
            _animating = true;
            flipDownAnim.start();
        } else {
            _oldValue = value;
        }
    }

    // Background: new digit (full, static) - visible beneath the flaps
    Rectangle {
        anchors.fill: parent
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

    // Static top half showing new digit (revealed as old top flap rotates away)
    Item {
        width: parent.width
        height: parent.height / 2
        clip: true

        Rectangle {
            width: root.width
            height: root.height
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
    }

    // Flipping top half: old digit rotating down
    Item {
        id: topFlap
        width: parent.width
        height: parent.height / 2
        clip: true
        visible: _animating

        Rectangle {
            width: root.width
            height: root.height
            radius: 4
            color: Qt.lighter(Colors.background, 2.0)

            Text {
                anchors.centerIn: parent
                text: root._oldValue
                color: Colors.text
                font.family: "Maple Mono NF"
                font.pixelSize: 20
            }
        }

        transform: Rotation {
            id: topRotation
            axis { x: 1; y: 0; z: 0 }
            origin.x: root.width / 2
            origin.y: root.height / 2
            angle: 0
        }
    }

    // Flipping bottom half: new digit rotating up
    Item {
        id: bottomFlap
        y: parent.height / 2
        width: parent.width
        height: parent.height / 2
        clip: true
        visible: _animating

        Rectangle {
            width: root.width
            height: root.height
            y: -root.height / 2
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

        transform: Rotation {
            id: bottomRotation
            axis { x: 1; y: 0; z: 0 }
            origin.x: root.width / 2
            origin.y: 0
            angle: -90
        }
    }

    // Divider line at the split
    Rectangle {
        y: parent.height / 2 - 0.5
        width: parent.width
        height: 1
        color: Qt.darker(Colors.background, 1.2)
        z: 10
    }

    SequentialAnimation {
        id: flipDownAnim

        NumberAnimation {
            target: topRotation
            property: "angle"
            from: 0
            to: 90
            duration: 150
            easing.type: Easing.InQuad
        }

        NumberAnimation {
            target: bottomRotation
            property: "angle"
            from: -90
            to: 0
            duration: 150
            easing.type: Easing.OutQuad
        }

        onFinished: {
            root._oldValue = root.value;
            root._animating = false;
            topRotation.angle = 0;
            bottomRotation.angle = -90;
        }
    }
}
