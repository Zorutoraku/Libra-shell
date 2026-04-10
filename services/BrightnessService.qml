pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {

    id: root
    property real brightness:    0
    property bool ready:         false
    property bool _hasBacklight: false

    function _parse(data) {
        if (!data) return
        var parts = data.trim().split(",")
        for (var i = 0; i < parts.length; i++) {
            if (parts[i].endsWith("%")) {
                root._hasBacklight = true
                root.brightness    = parseFloat(parts[i]) / 100
                root.ready         = true
                return
            }
        }
    }

    function setBrightness(v) {
        brightness = Math.max(0, Math.min(1, v))
        setProc.command = ["brightnessctl", "s", Math.round(brightness * 100) + "%"]
        setProc.running = true
    }

    Process { id: setProc }

    Process {
        id: readProc
        command: ["brightnessctl", "-m"]
        running: true
        stdout: SplitParser { onRead: (data) => root._parse(data) }
    }

    // inotifywait watches sysfs so hardware brightness keys update instantly without polling
    Process {
        id: watchProc
        running: true
        command: ["bash", "-c",
            "BACKLIGHT=$(ls /sys/class/backlight/ 2>/dev/null | head -1); " +
            "[ -z \"$BACKLIGHT\" ] && exit 0; " +
            "inotifywait -q -m -e modify " +
            "  \"/sys/class/backlight/$BACKLIGHT/actual_brightness\" 2>/dev/null " +
            "| while read -r _ _ _; do brightnessctl -m; done"
        ]
        stdout: SplitParser { onRead: (data) => root._parse(data) }
        onExited: { if (root._hasBacklight) watchRestartTimer.restart() } // restart if watcher crashes
    }

    Timer {
        id: watchRestartTimer
        interval: 3000
        onTriggered: { if (!watchProc.running) watchProc.running = true }
    }

    // 10s safety-net poll in case inotifywait misses an event
    Timer {
        interval: 10000
        running:  true
        repeat:   true
        onTriggered: {
            if (!watchProc.running && !readProc.running && root._hasBacklight)
                readProc.running = true
        }
    }
}
