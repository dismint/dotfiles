import QtQuick

Item {
    id: root

    property string value: ""
    property string _oldValue: ""
    property bool _animating: false

    width: 18
    height: 28

    clip: true

    onValueChanged: {
        if (_oldValue !== "" && _oldValue !== value) {
            _animating = true;
            oldTile.y = 0;
            newTile.y = -root.height;
            slideAnim.start();
        } else {
            _oldValue = value;
        }
    }

    // old digit tile (slides out downward)
    Rectangle {
        id: oldTile
        width: parent.width
        height: parent.height
        y: 0
        radius: 4
        color: Qt.lighter(Colors.background, 2.0)
        visible: _animating

        Text {
            anchors.centerIn: parent
            text: root._oldValue
            color: Colors.text
            font.family: "Maple Mono NF"
            font.pixelSize: 20
        }
    }

    // new digit tile (slides in from top)
    Rectangle {
        id: newTile
        width: parent.width
        height: parent.height
        y: _animating ? -root.height : 0
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

    ParallelAnimation {
        id: slideAnim

        NumberAnimation {
            target: oldTile
            property: "y"
            from: 0
            to: root.height
            duration: 1000
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: newTile
            property: "y"
            from: -root.height
            to: 0
            duration: 1000
            easing.type: Easing.InOutQuad
        }

        onFinished: {
            root._oldValue = root.value;
            root._animating = false;
        }
    }
}
