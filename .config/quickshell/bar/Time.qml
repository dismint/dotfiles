import QtQuick
import Quickshell.Io

Item {
    id: clock

    property string timeString: "00:00:00"

    implicitWidth: timeRow.implicitWidth
    implicitHeight: timeRow.implicitHeight

    Process {
        id: dateProcess
        command: ["date", "+%H:%M:%S"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: clock.timeString = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProcess.running = true
    }

    Row {
        id: timeRow
        spacing: 2

        // hours
        FlipDigit {
            value: clock.timeString.length >= 1 ? clock.timeString[0] : "0"
        }
        FlipDigit {
            value: clock.timeString.length >= 2 ? clock.timeString[1] : "0"
        }

        Text {
            text: ":"
            color: Colors.text
            font.family: "Maple Mono NF"
            font.pixelSize: 20
            width: 10
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        // minutes
        FlipDigit {
            value: clock.timeString.length >= 4 ? clock.timeString[3] : "0"
        }
        FlipDigit {
            value: clock.timeString.length >= 5 ? clock.timeString[4] : "0"
        }

        Text {
            text: ":"
            color: Colors.text
            font.family: "Maple Mono NF"
            font.pixelSize: 20
            width: 10
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        // seconds
        FlipDigit {
            value: clock.timeString.length >= 7 ? clock.timeString[6] : "0"
        }
        FlipDigit {
            value: clock.timeString.length >= 8 ? clock.timeString[7] : "0"
        }
    }
}
