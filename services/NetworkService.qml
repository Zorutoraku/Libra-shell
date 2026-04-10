pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {

    id: root

    property bool wifiEnabled:  false
    property bool airplaneMode: false
    property var  networks:     []

    readonly property var active: {
        for (let i = 0; i < networks.length; i++)
            if (networks[i].active) return networks[i]
        return null
    }

    function toggleWifi()      { setWifiEnabled(!wifiEnabled) }
    function setWifiEnabled(e) {
        enableProc.command = ["bash", "-c", "LC_ALL=C nmcli radio wifi " + (e ? "on" : "off")]
        enableProc.running = true
    }

    function toggleAirplane() {
        const next = !airplaneMode
        airplaneProc._next   = next
        airplaneProc.command = ["nmcli", "radio", "all", next ? "off" : "on"]
        airplaneProc.running = true
    }

    Process {
        id: airplaneProc
        property bool _next: false
        onExited: (code) => {
            if (code === 0) {
                root.airplaneMode = _next
                if (_next) {
                    root.wifiEnabled = false
                    root.networks    = []
                } else {
                    root.setWifiEnabled(true)
                }
            } else {
                console.warn("NetworkService: nmcli radio all fehlgeschlagen (exit", code + ")")
            }
        }
    }

    Process {
        id: statusProc
        running: true
        command: ["bash", "-c", "LC_ALL=C nmcli radio wifi"]
        stdout: SplitParser {
            onRead: (data) => {
                if (data) {
                    root.wifiEnabled = data.trim() === "enabled"
                    if (root.wifiEnabled && !getNetworksProc.running)
                        getNetworksProc.running = true
                }
            }
        }
    }

    Process {
        id: enableProc
        onExited: (code) => {
            if (!statusProc.running) statusProc.running = true
            if (code === 0 && root.wifiEnabled && !rescanProc.running)
                rescanProc.running = true
        }
    }

    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onExited: { if (!getNetworksProc.running) getNetworksProc.running = true }
    }

    Process {
        id: getNetworksProc
        command: ["bash", "-c", "LC_ALL=C nmcli -g ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY d w"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text) return
                const newNetworks = []
                text.trim().split("\n").forEach(line => {
                    const safe  = line.replace(/\\:/g, "__COLON__")
                    const parts = safe.split(":")
                    if (parts.length >= 4 && parts[3].length > 0) {
                        const ssid = parts[3].replace(/__COLON__/g, ":")
                        newNetworks.push({
                            active:   parts[0] === "yes",
                            strength: parseInt(parts[1]) || 0,
                            ssid:     ssid
                        })
                    }
                })
                root.networks = newNetworks
            }
        }
    }

    // persistent nmcli monitor reacts to connect/disconnect without polling
    Process {
        id: monitorProc
        running: true
        command: ["bash", "-c", "LC_ALL=C nmcli monitor"]
        stdout: SplitParser {
            onRead: (data) => {
                if (!data) return
                const line = data.trim()
                if (line.includes(": connected") || line.includes(": disconnected")) {
                    if (!statusProc.running) statusProc.running = true
                }
            }
        }
        onExited: monitorRestartTimer.restart()
    }

    Timer {
        id: monitorRestartTimer
        interval: 3000
        onTriggered: { if (!monitorProc.running) monitorProc.running = true }
    }

    // 30s safety-net refresh in case nmcli monitor misses an event
    Timer {
        interval: 30000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { if (!statusProc.running) statusProc.running = true }
    }
}
