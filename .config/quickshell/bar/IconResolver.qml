pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var iconMap: ({})

    function resolve(appId) {
        if (!appId)
            return "";

        var lowerAppId = appId.toLowerCase();

        for (var name in iconMap) {
            if (lowerAppId.indexOf(name) !== -1) {
                return iconMap[name];
            }
        }

        return appId;
    }

    Process {
        id: parseDesktopFiles
        command: ["sh", "-c", "for f in ~/.local/share/applications/*.desktop; do " + "[ -f \"$f\" ] || continue; " + "name=$(grep '^Name=' \"$f\" 2>/dev/null | head -1 | cut -d= -f2); " + "icon=$(grep '^Icon=' \"$f\" 2>/dev/null | head -1 | cut -d= -f2); " + "[ -n \"$name\" ] && [ -n \"$icon\" ] && echo \"$name|$icon\"; " + "done"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                var map = {};
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("|");
                    if (parts.length === 2) {
                        var name = parts[0].toLowerCase();
                        var icon = parts[1];
                        map[name] = icon;
                    }
                }
                root.iconMap = map;
            }
        }
    }
}
