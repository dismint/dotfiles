pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    function resolve(appId) {
        if (!appId)
            return "";

        var entry = DesktopEntries.byId(appId);
        if (!entry)
            entry = DesktopEntries.heuristicLookup(appId);

        if (entry && entry.icon)
            return entry.icon;

        return appId;
    }
}
