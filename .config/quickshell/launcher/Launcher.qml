pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: launcher

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    focusable: true
    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-launcher"

    property string query: ""
    property int selectedIndex: 0
    property var filteredApps: []
    property bool animating: false

    readonly property color bgColor: "#0f0e12"
    readonly property color primaryColor: "#84ab89"
    readonly property color accentColor: "#3e5587"
    readonly property color textColor: "#d3d9b2"
    readonly property color surfaceColor: Qt.lighter(bgColor, 2.0)
    readonly property color surfaceHoverColor: Qt.lighter(bgColor, 3.0)

    function toggle() {
        if (visible) {
            close();
        } else {
            open();
        }
    }

    function open() {
        query = "";
        selectedIndex = 0;
        updateFilter();
        visible = true;
        animating = true;
        searchField.text = "";
        openAnimation.restart();
    }

    function close() {
        animating = true;
        closeAnimation.restart();
    }

    function finishClose() {
        visible = false;
        query = "";
        animating = false;
    }

    function launchSelected() {
        if (selectedIndex >= 0 && selectedIndex < filteredApps.length) {
            filteredApps[selectedIndex].execute();
            close();
        }
    }

    function updateFilter() {
        var apps = DesktopEntries.applications.values;
        if (!query) {
            filteredApps = apps.slice(0, 50);
            return;
        }

        var q = query.toLowerCase();
        var scored = [];

        for (var i = 0; i < apps.length; i++) {
            var app = apps[i];
            var name = (app.name || "").toLowerCase();
            var generic = (app.genericName || "").toLowerCase();
            var comment = (app.comment || "").toLowerCase();
            var keywords = (app.keywords || []).join(" ").toLowerCase();

            var score = 0;

            if (name.indexOf(q) === 0)
                score = 100;
            else if (name.indexOf(q) !== -1)
                score = 80;
            else if (generic.indexOf(q) !== -1)
                score = 60;
            else if (keywords.indexOf(q) !== -1)
                score = 40;
            else if (comment.indexOf(q) !== -1)
                score = 20;
            else if (fuzzyMatch(q, name))
                score = 10;
            else
                continue;

            score += Math.max(0, 50 - name.length) / 50;
            scored.push({
                app: app,
                score: score
            });
        }

        scored.sort(function (a, b) {
            return b.score - a.score;
        });

        var result = [];
        var limit = Math.min(scored.length, 50);
        for (var i = 0; i < limit; i++)
            result.push(scored[i].app);

        filteredApps = result;
        selectedIndex = 0;
    }

    function fuzzyMatch(pattern, str) {
        var pi = 0;
        for (var si = 0; si < str.length && pi < pattern.length; si++) {
            if (str[si] === pattern[pi])
                pi++;
        }
        return pi === pattern.length;
    }

    function deleteWordBackward() {
        var t = searchField.text;
        var pos = searchField.cursorPosition;
        if (pos === 0)
            return;
        var i = pos - 1;
        while (i > 0 && t[i - 1] === ' ')
            i--;
        while (i > 0 && t[i - 1] !== ' ')
            i--;
        searchField.text = t.substring(0, i) + t.substring(pos);
        searchField.cursorPosition = i;
    }

    function deleteToBeginning() {
        var t = searchField.text;
        var pos = searchField.cursorPosition;
        searchField.text = t.substring(pos);
        searchField.cursorPosition = 0;
    }

    // --- animations ---
    ParallelAnimation {
        id: openAnimation
        onStarted: launcher.animating = true
        onFinished: {
            launcher.animating = false;
            searchField.forceActiveFocus();
        }

        NumberAnimation {
            target: backdrop
            property: "opacity"
            from: 0
            to: 1
            duration: 250
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: container
            property: "opacity"
            from: 0
            to: 1
            duration: 300
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: container
            property: "scale"
            from: 0.92
            to: 1.0
            duration: 300
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: container
            property: "anchors.verticalCenterOffset"
            from: 30
            to: 0
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: closeAnimation
        onFinished: launcher.finishClose()

        NumberAnimation {
            target: backdrop
            property: "opacity"
            from: 1
            to: 0
            duration: 200
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: container
            property: "opacity"
            from: 1
            to: 0
            duration: 180
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: container
            property: "scale"
            from: 1.0
            to: 0.95
            duration: 180
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: container
            property: "anchors.verticalCenterOffset"
            from: 0
            to: 15
            duration: 180
            easing.type: Easing.InCubic
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            launcher.toggle();
        }
    }

    // dimmed backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#000000"
        opacity: 0

        MouseArea {
            anchors.fill: parent
            onClicked: launcher.close()
        }
    }

    // centered container
    Item {
        id: container
        width: 440
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 0
        height: searchBox.height + 4 + resultsPanelHeight
        opacity: 0
        scale: 0.92

        property real resultsPanelHeight: {
            if (launcher.filteredApps.length === 0 && launcher.query !== "")
                return 34;
            if (launcher.filteredApps.length > 0)
                return Math.min(resultsColumn.height + 8, 320);
            return 0;
        }

        // search box
        Rectangle {
            id: searchBox
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 38
            radius: 6
            color: launcher.surfaceColor
            border.color: launcher.primaryColor
            border.width: 2

            Row {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                Text {
                    text: ""
                    color: launcher.primaryColor
                    font.family: "Maple Mono NF"
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: parent.width - 22
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter
                    clip: true

                    TextInput {
                        id: searchField
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        color: launcher.textColor
                        font.family: "Maple Mono NF"
                        font.pixelSize: 13
                        clip: true
                        selectionColor: launcher.primaryColor
                        selectedTextColor: launcher.bgColor
                        cursorVisible: true
                        overwriteMode: false

                        cursorDelegate: Rectangle {
                            width: 8
                            height: 15
                            color: launcher.primaryColor
                            opacity: 0.8
                            visible: searchField.activeFocus

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: searchField.activeFocus
                                NumberAnimation {
                                    to: 0.8
                                    duration: 0
                                }
                                PauseAnimation {
                                    duration: 530
                                }
                                NumberAnimation {
                                    to: 0.0
                                    duration: 0
                                }
                                PauseAnimation {
                                    duration: 530
                                }
                            }
                        }

                        onTextChanged: {
                            launcher.query = text;
                            launcher.updateFilter();
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                launcher.close();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                launcher.launchSelected();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down || (event.key === Qt.Key_J && event.modifiers & Qt.ControlModifier)) {
                                launcher.selectedIndex = Math.min(launcher.selectedIndex + 1, launcher.filteredApps.length - 1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_K && event.modifiers & Qt.ControlModifier)) {
                                launcher.selectedIndex = Math.max(launcher.selectedIndex - 1, 0);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Tab) {
                                launcher.selectedIndex = Math.min(launcher.selectedIndex + 1, launcher.filteredApps.length - 1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_W && event.modifiers & Qt.ControlModifier) {
                                launcher.deleteWordBackward();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_U && event.modifiers & Qt.ControlModifier) {
                                launcher.deleteToBeginning();
                                event.accepted = true;
                            } else if (event.key === Qt.Key_A && event.modifiers & Qt.ControlModifier) {
                                searchField.cursorPosition = 0;
                                event.accepted = true;
                            } else if (event.key === Qt.Key_E && event.modifiers & Qt.ControlModifier) {
                                searchField.cursorPosition = searchField.text.length;
                                event.accepted = true;
                            } else if (event.key === Qt.Key_H && event.modifiers & Qt.ControlModifier) {
                                if (searchField.cursorPosition > 0) {
                                    var p = searchField.cursorPosition;
                                    searchField.text = searchField.text.substring(0, p - 1) + searchField.text.substring(p);
                                    searchField.cursorPosition = p - 1;
                                }
                                event.accepted = true;
                            }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "launch..."
                        color: launcher.textColor
                        font.family: "Maple Mono NF"
                        font.pixelSize: 13
                        opacity: 0.3
                        visible: searchField.text === ""
                    }
                }
            }
        }

        // results list
        Rectangle {
            id: resultsPanel
            anchors.top: searchBox.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.min(resultsColumn.height + 8, 320)
            radius: 6
            color: launcher.surfaceColor
            border.color: launcher.primaryColor
            border.width: 2
            clip: true
            visible: launcher.filteredApps.length > 0

            Flickable {
                id: resultsFlickable
                anchors.fill: parent
                anchors.margins: 4
                contentHeight: resultsColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                onContentHeightChanged: ensureVisible()

                function ensureVisible() {
                    var itemY = launcher.selectedIndex * 34;
                    var itemBottom = itemY + 34;
                    if (itemY < contentY)
                        contentY = itemY;
                    else if (itemBottom > contentY + height)
                        contentY = itemBottom - height;
                }

                Column {
                    id: resultsColumn
                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: launcher.filteredApps.length

                        AppEntry {
                            required property int index
                            width: resultsColumn.width
                            app: launcher.filteredApps[index]
                            isSelected: index === launcher.selectedIndex
                            bgColor: launcher.bgColor
                            primaryColor: launcher.primaryColor
                            textColor: launcher.textColor
                            surfaceHoverColor: launcher.surfaceHoverColor

                            onClicked: {
                                launcher.selectedIndex = index;
                                launcher.launchSelected();
                            }
                            onHovered: {
                                launcher.selectedIndex = index;
                            }
                        }
                    }
                }
            }
        }

        // empty state
        Rectangle {
            anchors.top: searchBox.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.right: parent.right
            height: 34
            radius: 6
            color: launcher.surfaceColor
            border.color: launcher.primaryColor
            border.width: 2
            visible: launcher.filteredApps.length === 0 && launcher.query !== ""

            Text {
                anchors.centerIn: parent
                text: "no results"
                color: launcher.textColor
                font.family: "Maple Mono NF"
                font.pixelSize: 12
                opacity: 0.4
            }
        }
    }

    Connections {
        target: launcher
        function onSelectedIndexChanged() {
            resultsFlickable.ensureVisible();
        }
    }

    onVisibleChanged: {
        if (visible)
            searchField.forceActiveFocus();
    }
}
