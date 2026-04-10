pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {

    // --- Funktion ---

    id: root

    property string osVal:     "..."
    property string hostVal:   "..."
    property string kernelVal: "..."
    property string shellVal:  "..."
    property string wmVal:     "..."
    property string uptimeVal: "..."

    Process {
        running: true
        command: ["bash", "-c", [
            "source /etc/os-release 2>/dev/null && printf 'os:%s\\n' \"$PRETTY_NAME\"",
            "printf 'host:%s\\n' \"$(cat /proc/sys/kernel/hostname)\"",
            "printf 'kernel:%s\\n' \"$(uname -r)\"",
            "printf 'shell:%s\\n' \"$(basename \"${SHELL}\")\"",
            "printf 'wm:%s\\n' \"${XDG_CURRENT_DESKTOP:-$WAYLAND_DISPLAY}\"",
            "printf 'uptime:%s\\n' \"$(uptime -p | sed 's/up //')\"",
        ].join("; ")]
        stdout: SplitParser {
            onRead: (line) => {
                const sep = line.indexOf(":")
                if (sep === -1) return
                const key = line.substring(0, sep)
                const val = line.substring(sep + 1).trim()
                switch (key) {
                    case "os":     root.osVal     = val; break
                    case "host":   root.hostVal   = val; break
                    case "kernel": root.kernelVal = val; break
                    case "shell":  root.shellVal  = val; break
                    case "wm":     root.wmVal     = val; break
                    case "uptime": root.uptimeVal = val; break
                }
            }
        }
    }

    Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: uptimeProc.running = true
    }
    Process {
        id: uptimeProc
        command: ["bash", "-c", "uptime -p | sed 's/up //'"]
        stdout: SplitParser { onRead: line => root.uptimeVal = line.trim() }
    }
}
