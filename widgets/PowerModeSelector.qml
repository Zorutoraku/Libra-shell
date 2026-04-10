import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../themes"

Rectangle {

    id: root

    property int  activeMode: 1
    property bool available:  false

    readonly property var modes: [
        { label: "\uf06c", profile: "power-saver"  },
        { label: "\uf0e7", profile: "balanced"      },
        { label: "\uf135", profile: "performance"   }
    ]

    radius:       ThemeWidgets.powerMode.radius
    color:        ThemeWidgets.powerMode.bgColor
    border.color: ThemeWidgets.powerMode.borderColor
    border.width: 1

    opacity: available ? 1.0 : 0.4

    Process {
        id: getProc
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                var p = line.trim()
                if      (p === "power-saver") root.activeMode = 0
                else if (p === "balanced")    root.activeMode = 1
                else if (p === "performance") root.activeMode = 2
            }
        }
        onExited: (code) => {
            // exit =/ 0 means power-profiles-daemon missing/inactive
            if (code !== 0) {
                root.available = false
                console.warn("PowerModeSelector: powerprofilesctl exited with code", code,
                             "– power-profiles-daemon nicht installiert oder nicht aktiv.")
            } else {
                root.available = true
            }
        }
    }

    Process {
        id: setProc
        property string profile: ""
        command: ["powerprofilesctl", "set", profile]
        onExited: (code) => {
            if (code !== 0)
                console.warn("PowerModeSelector: Konnte Profil nicht setzen (exit", code + ")")
        }
    }

    RowLayout {
        anchors { fill: parent; margins: ThemeWidgets.powerMode.innerMargin }
        spacing: ThemeWidgets.powerMode.segmentSpacing

        Repeater {
            model: root.modes

            delegate: Rectangle {
                Layout.fillWidth:  true
                Layout.fillHeight: true

                radius:       ThemeWidgets.powerMode.segmentRadius
                color:        index === root.activeMode
                              ? ThemeWidgets.powerMode.activeSegColor
                              : ThemeWidgets.powerMode.inactiveSegColor
                border.color: index === root.activeMode
                              ? ThemeWidgets.powerMode.activeBorderColor
                              : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: ThemeWidgets.powerMode.animDuration } }

                HoverHandler { id: segHover }

                Rectangle {
                    anchors.fill: parent
                    radius:       parent.radius
                    color:        (segHover.hovered && index !== root.activeMode)
                                  ? ThemeWidgets.powerMode.hoverColor
                                  : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                Text {
                    anchors.centerIn: parent
                    text:           modelData.label
                    font.family:    ThemeGlobal.fontIcons
                    font.pixelSize: ThemeWidgets.powerMode.fontSize * 1.4
                    font.weight:    index === root.activeMode ? Font.Medium : Font.Normal
                    color:          index === root.activeMode
                                    ? ThemeWidgets.powerMode.activeTextColor
                                    : ThemeWidgets.powerMode.inactiveTextColor
                    Behavior on color { ColorAnimation { duration: ThemeWidgets.powerMode.animDuration } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    enabled:      root.available
                    onClicked: {
                        if (index === root.activeMode) return
                        if (setProc.running) return
                        root.activeMode  = index
                        setProc.profile  = root.modes[index].profile
                        setProc.running  = true
                    }
                }
            }
        }
    }
}
