import QtQuick
import Quickshell.Io

Item {
    id: clock

    property string timeString: "00:00:00"

    implicitWidth: timeRow.implicitWidth
    implicitHeight: timeRow.implicitHeight

    Process {
        id: dateProc
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
        onTriggered: dateProc.running = true
    }

    Row {
        id: timeRow
        spacing: 2

        // HH
        FlipDigit {
            value: timeString.length >= 1 ? timeString[0] : "0"
        }
        FlipDigit {
            value: timeString.length >= 2 ? timeString[1] : "0"
        }

        // :
        Text {
            text: ":"
            color: Colors.text
            font.family: "Maple Mono NF"
            font.pixelSize: 20
            width: 10
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        // MM
        FlipDigit {
            value: timeString.length >= 4 ? timeString[3] : "0"
        }
        FlipDigit {
            value: timeString.length >= 5 ? timeString[4] : "0"
        }

        // :
        Text {
            text: ":"
            color: Colors.text
            font.family: "Maple Mono NF"
            font.pixelSize: 20
            width: 10
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        // SS
        FlipDigit {
            value: timeString.length >= 7 ? timeString[6] : "0"
        }
        FlipDigit {
            value: timeString.length >= 8 ? timeString[7] : "0"
        }
    }
}
