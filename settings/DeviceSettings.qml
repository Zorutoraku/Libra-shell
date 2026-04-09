import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../themes"
import "../widgets"

Item {

    // --- Funktion ---

    id: root

    property string cpuModel:  "…"
    property string cpuCores:  ""
    property string ramTotal:  "…"
    property string gpuModel:  "…"
    property string osName:    "…"
    property string kernel:    "…"
    property string screenRes: "…"
    property string screenHz:  ""
    property string diskInfo:  "…"
    property string hostname:  "…"

    // Single process instead of 9 — one shell fork, key=value output
    Process {
        command: ["bash", "-c",
            "printf 'HOSTNAME=%s\\n' \"$(cat /etc/hostname 2>/dev/null)\";" +
            "printf 'OS=%s\\n' \"$(grep '^PRETTY_NAME' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '\"')\";" +
            "printf 'KERNEL=%s\\n' \"$(uname -r)\";" +
            "printf 'CPU=%s\\n' \"$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //;s/(R)//g;s/(TM)//g;s/  */ /g')\";" +
            "printf 'CORES=%s Cores\\n' \"$(nproc)\";" +
            "printf 'RAM=%s\\n' \"$(awk '/MemTotal/{printf \"%.1f GB\", $2/1048576}' /proc/meminfo)\";" +
            "gpu=$(lspci 2>/dev/null | grep -iE 'vga|3d|display' | head -1 | sed 's/.*: //;s/ (rev [0-9a-f]*)//g');" +
            "printf 'GPU=%s\\n' \"${gpu:-Not found (install pciutils)}\";" +
            "printf 'DISK=%s\\n' \"$(df -h / | awk 'NR==2{print $4\" free / \"$2}')\";" +
            "if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then" +
            "  read -r res hz < <(hyprctl monitors -j 2>/dev/null | jq -r '.[0] | \"\\(.width)x\\(.height) \\(.refreshRate | floor)\"' 2>/dev/null);" +
            "else" +
            "  res=$(xrandr 2>/dev/null | grep ' connected' | grep -oP '[0-9]+x[0-9]+' | head -1);" +
            "  hz=$(xrandr 2>/dev/null | grep '[*]' | grep -oP '[0-9]+(?=\\.[0-9]+[*])' | head -1);" +
            "fi;" +
            "printf 'SCREEN_RES=%s\\n' \"${res}\";" +
            "printf 'SCREEN_HZ=%s\\n' \"${hz}\""
        ]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const eq  = line.indexOf("=")
                if (eq < 0) return
                const key = line.slice(0, eq)
                const val = line.slice(eq + 1).trim()
                switch (key) {
                    case "HOSTNAME":   root.hostname  = val; break
                    case "OS":         root.osName    = val; break
                    case "KERNEL":     root.kernel    = val; break
                    case "CPU":        root.cpuModel  = val; break
                    case "CORES":      root.cpuCores  = val; break
                    case "RAM":        root.ramTotal  = val; break
                    case "GPU":        root.gpuModel  = val; break
                    case "DISK":       root.diskInfo  = val; break
                    case "SCREEN_RES": if (val) root.screenRes = val; break
                    case "SCREEN_HZ":  if (val) root.screenHz  = val + " Hz"; break
                }
            }
        }
    }

    // --- Design ---

    ColumnLayout {
        anchors { fill: parent; leftMargin: 20; rightMargin: 20; topMargin: 20 }
        spacing: 0

        Text {
            text: "SYSTEM"
            Layout.bottomMargin: 8
            leftPadding: 4
            font.pixelSize: ThemeWidgets.sectionLabel.fontSize
            font.weight:    Font.Medium
            font.family:    ThemeGlobal.fontSans
            color:          ThemeSettings.subColor
        }

        Repeater {
            model: [
                { icon: "󰇄", label: "Hostname", value: root.hostname,  sub: "" },
                { icon: "󰣇", label: "OS",       value: root.osName,    sub: root.kernel },
                { icon: "󰍹", label: "Display",  value: root.screenRes, sub: root.screenHz },
                { icon: "󰻠", label: "CPU",       value: root.cpuModel,  sub: root.cpuCores },
                { icon: "󰍛", label: "RAM",       value: root.ramTotal,  sub: "" },
                { icon: "󰢮", label: "GPU",       value: root.gpuModel,  sub: "" },
                { icon: "󰋊", label: "Storage",   value: root.diskInfo,  sub: "/ partition" },
            ]

            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    visible: index > 0
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: ThemeSettings.separatorColor
                }

                RowLayout {
                    Layout.fillWidth:    true
                    Layout.topMargin:    index === 0 ? 0 : 10
                    Layout.bottomMargin: 10
                    spacing: 12

                    Text {
                        text: modelData.icon
                        font.family: ThemeGlobal.fontIcons; font.pixelSize: 16
                        color: ThemeSettings.accentColor
                        Layout.preferredWidth: 20
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: modelData.label
                        font.pixelSize: 13; font.weight: Font.Medium
                        font.family: ThemeGlobal.fontSans; color: ThemeSettings.textColor
                        Layout.preferredWidth: 72
                    }

                    Column {
                        Layout.fillWidth: true; spacing: 2
                        Text {
                            text: modelData.value
                            font.pixelSize: 12; font.family: ThemeGlobal.fontMono
                            color: ThemeSettings.subColor
                            elide: Text.ElideRight; width: parent.width
                        }
                        Text {
                            visible: modelData.sub !== ""
                            text: modelData.sub
                            font.pixelSize: 11; font.family: ThemeGlobal.fontMono
                            color: ThemeSettings.hintColor
                            elide: Text.ElideRight; width: parent.width
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
