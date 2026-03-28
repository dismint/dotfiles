pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris

PopupWindow {
    id: popup

    property bool animateOpen: false
    property real menuWidth: 340
    property real maxHeight: 600

    required property var parentWindow
    property real popupX: 0

    anchor.window: parentWindow
    anchor.edges: Edges.Top
    anchor.rect.x: popupX
    anchor.rect.y: parentWindow.height + 6
    color: "transparent"
    implicitWidth: menuWidth
    implicitHeight: maxHeight

    // track the default sink and source for volume control
    PwObjectTracker {
        id: deviceTracker
        objects: {
            var result = [];
            if (Pipewire.defaultAudioSink)
                result.push(Pipewire.defaultAudioSink);
            if (Pipewire.defaultAudioSource)
                result.push(Pipewire.defaultAudioSource);
            return result;
        }
    }

    // track all stream nodes so we can read their audio properties
    PwObjectTracker {
        id: streamTracker
        objects: {
            var result = [];
            for (var i = 0; i < Pipewire.nodes.values.length; i++) {
                var node = Pipewire.nodes.values[i];
                if (node.isStream && node.audio)
                    result.push(node);
            }
            return result;
        }
    }

    // track link groups to find which streams connect to the default sink
    PwNodeLinkTracker {
        id: sinkLinkTracker
        node: Pipewire.defaultAudioSink
    }

    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource

    // active mpris player: prefer playing, otherwise first
    property var activePlayer: {
        var players = Mpris.players.values;
        if (!players || players.length === 0)
            return null;
        for (var i = 0; i < players.length; i++) {
            if (players[i].isPlaying)
                return players[i];
        }
        return players[0];
    }

    // collect sink nodes for output selector
    function getSinkNodes() {
        var result = [];
        for (var i = 0; i < Pipewire.nodes.values.length; i++) {
            var node = Pipewire.nodes.values[i];
            if (node.isSink && node.audio && !node.isStream)
                result.push(node);
        }
        return result;
    }

    // collect source nodes for input selector
    function getSourceNodes() {
        var result = [];
        for (var i = 0; i < Pipewire.nodes.values.length; i++) {
            var node = Pipewire.nodes.values[i];
            if (!node.isSink && node.audio && !node.isStream)
                result.push(node);
        }
        return result;
    }

    Item {
        id: popupClip

        property real panelHeight: Math.min(Math.max(120, contentColumn.height + 16), popup.maxHeight)
        property real displayHeight: panelHeight
        property bool openCloseAnimating: false

        anchors.left: parent.left
        anchors.right: parent.right
        height: popup.animateOpen ? displayHeight : 0
        opacity: popup.animateOpen ? 1.0 : 0.0
        clip: true

        onPanelHeightChanged: {
            if (!popup.animateOpen)
                return;
            if (panelHeight >= displayHeight) {
                shrinkAnimation.stop();
                displayHeight = panelHeight;
            } else {
                if (shrinkAnimation.running) {
                    shrinkAnimation.to = panelHeight;
                } else {
                    shrinkAnimation.from = displayHeight;
                    shrinkAnimation.to = panelHeight;
                    shrinkAnimation.start();
                }
            }
        }

        Connections {
            target: popup
            function onAnimateOpenChanged() {
                if (popup.animateOpen)
                    popupClip.displayHeight = popupClip.panelHeight;
                popupClip.openCloseAnimating = true;
            }
        }

        NumberAnimation {
            id: shrinkAnimation
            target: popupClip
            property: "displayHeight"
            duration: 300
            easing.type: Easing.OutCubic
        }

        Behavior on height {
            enabled: popupClip.openCloseAnimating
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
                onRunningChanged: if (!running)
                    popupClip.openCloseAnimating = false
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            id: panel

            width: popup.menuWidth
            height: popupClip.height
            radius: 4
            color: Colors.surface
            border.color: Colors.primary
            border.width: 2

            Flickable {
                id: contentFlickable
                anchors.fill: parent
                anchors.margins: 8
                contentHeight: contentColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    policy: contentFlickable.contentHeight > contentFlickable.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: Colors.primary
                        opacity: 0.6
                    }
                }

                Column {
                    id: contentColumn
                    width: parent.width
                    spacing: 12

                    // --- output device selector ---
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "output"
                            color: Colors.text
                            font.family: "Maple Mono NF"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            opacity: 0.5
                        }

                        // device selector buttons
                        Column {
                            width: parent.width
                            spacing: 3

                            Repeater {
                                id: sinkRepeater
                                model: popup.getSinkNodes()

                                Rectangle {
                                    id: sinkDelegate
                                    required property var modelData
                                    width: parent.width
                                    height: 26
                                    radius: 4
                                    color: {
                                        var isDefault = popup.sink && modelData.id === popup.sink.id;
                                        if (isDefault)
                                            return Colors.primary;
                                        return sinkMouse.containsMouse ? Colors.surfaceHover : "transparent";
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 8
                                        anchors.right: parent.right
                                        anchors.rightMargin: 8
                                        text: sinkDelegate.modelData.description || sinkDelegate.modelData.name
                                        color: {
                                            var isDefault = popup.sink && sinkDelegate.modelData.id === popup.sink.id;
                                            return isDefault ? Colors.background : Colors.text;
                                        }
                                        font.family: "Maple Mono NF"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        id: sinkMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Pipewire.preferredDefaultAudioSink = sinkDelegate.modelData
                                    }
                                }
                            }
                        }

                        // volume row
                        Row {
                            width: parent.width
                            spacing: 8

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 4
                                color: {
                                    if (!popup.sink || !popup.sink.audio)
                                        return "transparent";
                                    return popup.sink.audio.muted ? Colors.danger : Colors.primary;
                                }
                                anchors.verticalCenter: parent.verticalCenter

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: {
                                        if (!popup.sink || !popup.sink.audio || popup.sink.audio.muted)
                                            return "󰝟";
                                        var vol = popup.sink.audio.volume;
                                        if (vol < 0.33)
                                            return "󰕿";
                                        if (vol < 0.66)
                                            return "󰖀";
                                        return "󰕾";
                                    }
                                    color: Colors.background
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (popup.sink && popup.sink.audio)
                                            popup.sink.audio.muted = !popup.sink.audio.muted;
                                    }
                                }
                            }

                            Item {
                                width: parent.width - 28 - 50 - 16
                                height: 28
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 4
                                    radius: 2
                                    color: Colors.background

                                    Rectangle {
                                        width: parent.width * (popup.sink && popup.sink.audio ? popup.sink.audio.volume : 0)
                                        height: parent.height
                                        radius: 2
                                        color: popup.sink && popup.sink.audio && popup.sink.audio.muted ? Colors.danger : Colors.primary

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 50
                                            }
                                        }

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 150
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: event => {
                                        if (popup.sink && popup.sink.audio)
                                            popup.sink.audio.volume = Math.max(0, Math.min(1, event.x / width));
                                    }
                                    onPositionChanged: event => {
                                        if (pressed && popup.sink && popup.sink.audio)
                                            popup.sink.audio.volume = Math.max(0, Math.min(1, event.x / width));
                                    }
                                }
                            }

                            Text {
                                width: 50
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                text: (popup.sink && popup.sink.audio ? Math.round(popup.sink.audio.volume * 100) : 0) + "%"
                                color: Colors.text
                                font.family: "Maple Mono NF"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                        }
                    }

                    // --- separator ---
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Colors.text
                        opacity: 0.1
                    }

                    // --- input device selector ---
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "input"
                            color: Colors.text
                            font.family: "Maple Mono NF"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            opacity: 0.5
                        }

                        Column {
                            width: parent.width
                            spacing: 3

                            Repeater {
                                id: sourceRepeater
                                model: popup.getSourceNodes()

                                Rectangle {
                                    id: sourceDelegate
                                    required property var modelData
                                    width: parent.width
                                    height: 26
                                    radius: 4
                                    color: {
                                        var isDefault = popup.source && modelData.id === popup.source.id;
                                        if (isDefault)
                                            return Colors.accent;
                                        return sourceMouse.containsMouse ? Colors.surfaceHover : "transparent";
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                            easing.type: Easing.OutCubic
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.leftMargin: 8
                                        anchors.right: parent.right
                                        anchors.rightMargin: 8
                                        text: sourceDelegate.modelData.description || sourceDelegate.modelData.name
                                        color: {
                                            var isDefault = popup.source && sourceDelegate.modelData.id === popup.source.id;
                                            return isDefault ? Colors.text : Colors.text;
                                        }
                                        font.family: "Maple Mono NF"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        id: sourceMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Pipewire.preferredDefaultAudioSource = sourceDelegate.modelData
                                    }
                                }
                            }
                        }

                        // input volume row
                        Row {
                            width: parent.width
                            spacing: 8

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 4
                                color: {
                                    if (!popup.source || !popup.source.audio)
                                        return "transparent";
                                    return popup.source.audio.muted ? Colors.danger : Colors.accent;
                                }
                                anchors.verticalCenter: parent.verticalCenter

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: popup.source && popup.source.audio && popup.source.audio.muted ? "󰍭" : "󰍬"
                                    color: Colors.background
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (popup.source && popup.source.audio)
                                            popup.source.audio.muted = !popup.source.audio.muted;
                                    }
                                }
                            }

                            Item {
                                width: parent.width - 28 - 50 - 16
                                height: 28
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 4
                                    radius: 2
                                    color: Colors.background

                                    Rectangle {
                                        width: parent.width * (popup.source && popup.source.audio ? popup.source.audio.volume : 0)
                                        height: parent.height
                                        radius: 2
                                        color: popup.source && popup.source.audio && popup.source.audio.muted ? Colors.danger : Colors.accent

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 50
                                            }
                                        }

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 150
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: event => {
                                        if (popup.source && popup.source.audio)
                                            popup.source.audio.volume = Math.max(0, Math.min(1, event.x / width));
                                    }
                                    onPositionChanged: event => {
                                        if (pressed && popup.source && popup.source.audio)
                                            popup.source.audio.volume = Math.max(0, Math.min(1, event.x / width));
                                    }
                                }
                            }

                            Text {
                                width: 50
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignRight
                                text: (popup.source && popup.source.audio ? Math.round(popup.source.audio.volume * 100) : 0) + "%"
                                color: Colors.text
                                font.family: "Maple Mono NF"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                        }
                    }

                    // --- separator ---
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Colors.text
                        opacity: 0.1
                        visible: streamRepeater.count > 0
                    }

                    // --- streams section ---
                    Column {
                        width: parent.width
                        spacing: 6
                        visible: streamRepeater.count > 0

                        Text {
                            text: "streams"
                            color: Colors.text
                            font.family: "Maple Mono NF"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            opacity: 0.5
                        }

                        Repeater {
                            id: streamRepeater
                            model: sinkLinkTracker.linkGroups

                            Column {
                                id: streamDelegate
                                required property PwLinkGroup modelData
                                property PwNode streamNode: modelData.source
                                width: parent.width
                                spacing: 4

                                Row {
                                    width: parent.width
                                    spacing: 8

                                    Rectangle {
                                        width: 22
                                        height: 22
                                        radius: 4
                                        color: streamDelegate.streamNode.audio && streamDelegate.streamNode.audio.muted ? Colors.danger : Colors.accent
                                        anchors.verticalCenter: parent.verticalCenter

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 150
                                                easing.type: Easing.OutCubic
                                            }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: streamDelegate.streamNode.audio && streamDelegate.streamNode.audio.muted ? "󰝟" : "󰕾"
                                            color: Colors.background
                                            font.family: "Maple Mono NF"
                                            font.pixelSize: 11
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (streamDelegate.streamNode.audio)
                                                    streamDelegate.streamNode.audio.muted = !streamDelegate.streamNode.audio.muted;
                                            }
                                        }
                                    }

                                    Text {
                                        width: parent.width - 22 - 44 - 16
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: streamDelegate.streamNode.description || streamDelegate.streamNode.name
                                        color: Colors.text
                                        font.family: "Maple Mono NF"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: 44
                                        anchors.verticalCenter: parent.verticalCenter
                                        horizontalAlignment: Text.AlignRight
                                        text: (streamDelegate.streamNode.audio ? Math.round(streamDelegate.streamNode.audio.volume * 100) : 0) + "%"
                                        color: Colors.text
                                        font.family: "Maple Mono NF"
                                        font.pixelSize: 11
                                        opacity: 0.7
                                    }
                                }

                                Item {
                                    width: parent.width
                                    height: 4

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width
                                        height: 4
                                        radius: 2
                                        color: Colors.background

                                        Rectangle {
                                            width: parent.width * (streamDelegate.streamNode.audio ? streamDelegate.streamNode.audio.volume : 0)
                                            height: parent.height
                                            radius: 2
                                            color: streamDelegate.streamNode.audio && streamDelegate.streamNode.audio.muted ? Colors.danger : Colors.accent

                                            Behavior on width {
                                                NumberAnimation {
                                                    duration: 50
                                                }
                                            }

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 150
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.topMargin: -6
                                        anchors.bottomMargin: -6
                                        cursorShape: Qt.PointingHandCursor
                                        onPressed: event => {
                                            if (streamDelegate.streamNode.audio)
                                                streamDelegate.streamNode.audio.volume = Math.max(0, Math.min(1, event.x / width));
                                        }
                                        onPositionChanged: event => {
                                            if (pressed && streamDelegate.streamNode.audio)
                                                streamDelegate.streamNode.audio.volume = Math.max(0, Math.min(1, event.x / width));
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // --- separator before player ---
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Colors.text
                        opacity: 0.1
                        visible: popup.activePlayer !== null
                    }

                    // --- media player section ---
                    Column {
                        width: parent.width
                        spacing: 8
                        visible: popup.activePlayer !== null

                        Text {
                            text: "now playing"
                            color: Colors.text
                            font.family: "Maple Mono NF"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            opacity: 0.5
                        }

                        // album art + track info
                        Row {
                            width: parent.width
                            spacing: 10

                            Rectangle {
                                width: 72
                                height: 72
                                radius: 6
                                color: Colors.background
                                clip: true

                                Image {
                                    id: albumArt
                                    anchors.fill: parent
                                    source: popup.activePlayer ? popup.activePlayer.trackArtUrl : ""
                                    fillMode: Image.PreserveAspectCrop
                                    visible: status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰎆"
                                    color: Colors.text
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 28
                                    opacity: 0.3
                                    visible: !albumArt.visible
                                }
                            }

                            Column {
                                width: parent.width - 82
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    width: parent.width
                                    text: popup.activePlayer ? popup.activePlayer.trackTitle : ""
                                    color: Colors.text
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width
                                    text: popup.activePlayer ? popup.activePlayer.trackArtist : ""
                                    color: Colors.text
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    opacity: 0.6
                                }

                                Text {
                                    width: parent.width
                                    text: popup.activePlayer ? popup.activePlayer.trackAlbum : ""
                                    color: Colors.text
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    opacity: 0.4
                                    visible: text !== ""
                                }
                            }
                        }

                        // progress bar + time labels below
                        Column {
                            width: parent.width
                            spacing: 4
                            visible: popup.activePlayer !== null && popup.activePlayer.lengthSupported && popup.activePlayer.positionSupported

                            // progress bar
                            Item {
                                width: parent.width
                                height: 6

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 3
                                    radius: 2
                                    color: Colors.background

                                    Rectangle {
                                        property real progress: {
                                            if (!popup.activePlayer || !popup.activePlayer.lengthSupported || popup.activePlayer.length <= 0)
                                                return 0;
                                            return Math.min(1, popup.activePlayer.position / popup.activePlayer.length);
                                        }
                                        width: parent.width * progress
                                        height: parent.height
                                        radius: 2
                                        color: Colors.primary

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 500
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.topMargin: -4
                                    anchors.bottomMargin: -4
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: event => {
                                        if (popup.activePlayer && popup.activePlayer.canSeek && popup.activePlayer.lengthSupported) {
                                            var ratio = event.x / width;
                                            popup.activePlayer.position = ratio * popup.activePlayer.length;
                                        }
                                    }
                                }
                            }

                            // time labels underneath
                            Item {
                                width: parent.width
                                height: 14

                                Text {
                                    id: posLabel
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: {
                                        if (!popup.activePlayer || !popup.activePlayer.positionSupported)
                                            return "";
                                        var s = Math.floor(popup.activePlayer.position);
                                        var m = Math.floor(s / 60);
                                        s = s % 60;
                                        return m + ":" + (s < 10 ? "0" : "") + s;
                                    }
                                    color: Colors.text
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 10
                                    opacity: 0.4
                                }

                                Text {
                                    id: durLabel
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: {
                                        if (!popup.activePlayer || !popup.activePlayer.lengthSupported)
                                            return "";
                                        var s = Math.floor(popup.activePlayer.length);
                                        var m = Math.floor(s / 60);
                                        s = s % 60;
                                        return m + ":" + (s < 10 ? "0" : "") + s;
                                    }
                                    color: Colors.text
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 10
                                    opacity: 0.4
                                }
                            }
                        }

                        // playback controls
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 16

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: prevMouse.containsMouse ? Colors.surfaceHover : "transparent"

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰒮"
                                    color: popup.activePlayer && popup.activePlayer.canGoPrevious ? Colors.text : Qt.darker(Colors.text, 2)
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 18
                                }

                                MouseArea {
                                    id: prevMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (popup.activePlayer && popup.activePlayer.canGoPrevious)
                                            popup.activePlayer.previous();
                                    }
                                }
                            }

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: Colors.primary
                                anchors.verticalCenter: parent.verticalCenter

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: popup.activePlayer && popup.activePlayer.isPlaying ? "󰏤" : "󰐊"
                                    color: Colors.background
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 22
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (popup.activePlayer && popup.activePlayer.canTogglePlaying)
                                            popup.activePlayer.togglePlaying();
                                    }
                                }
                            }

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: nextMouse.containsMouse ? Colors.surfaceHover : "transparent"

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰒭"
                                    color: popup.activePlayer && popup.activePlayer.canGoNext ? Colors.text : Qt.darker(Colors.text, 2)
                                    font.family: "Maple Mono NF"
                                    font.pixelSize: 18
                                }

                                MouseArea {
                                    id: nextMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (popup.activePlayer && popup.activePlayer.canGoNext)
                                            popup.activePlayer.next();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
