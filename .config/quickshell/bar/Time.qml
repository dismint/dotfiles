import QtQuick
import Quickshell.Io

Text {
    id: clock
    color: Colors.text
    font.family: "Maple Mono NF"
    font.pixelSize: 14

    Process {
        id: dateProc
        command: ["date"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: clock.text = this.text
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
