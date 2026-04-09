import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../themes"
import "../services"
import "../widgets"

Item {

    // --- Funktion ---

    id: root

    function sinkIcon(name) {
        if (!name) return "󰕾"
        const s = name.toLowerCase()
        if (s.includes("headphone") || s.includes("headset")) return "󰋎"
        if (s.includes("hdmi") || s.includes("displayport"))  return "󰍹"
        if (s.includes("bluetooth") || s.includes("bluez"))   return "󰂰"
        if (s.includes("usb"))                                 return "󱡬"
        return "󰕾"
    }

    function sourceIcon(name) {
        if (!name) return "󰍬"
        const s = name.toLowerCase()
        if (s.includes("webcam") || s.includes("camera")) return "󰄀"
        if (s.includes("usb"))                              return "󱡬"
        if (s.includes("bluetooth") || s.includes("bluez")) return "󰂰"
        return "󰍬"
    }

    function nodeName(node) {
        if (!node) return "Unknown"
        return node.description || node.name || "Unknown"
    }

    // --- Design ---

    ScrollView {
        anchors.fill:                parent
        contentWidth:                parent.width
        clip:                        true
        ScrollBar.vertical:          ScrollBar { policy: ScrollBar.AsNeeded; width: 4
            contentItem: Rectangle { radius: 2; color: ThemeSettings.hintColor }
            background:  Rectangle { color: "transparent" }
        }
        ScrollBar.horizontal:        ScrollBar { policy: ScrollBar.AlwaysOff }

        ColumnLayout {
            width:   root.width
            spacing: 0

            // ══════════════════════════════════════
            //  OUTPUT
            // ══════════════════════════════════════

            Item { Layout.preferredHeight: 20 }

            Text {
                Layout.leftMargin: 20
                text: "OUTPUT"
                font.pixelSize: ThemeWidgets.sectionLabel.fontSize
                font.weight:    Font.Medium
                font.family:    ThemeGlobal.fontSans
                color:          ThemeSettings.subColor
                leftPadding:    4
            }

            Item { Layout.preferredHeight: 8 }

            // Active sink header
            Rectangle {
                Layout.leftMargin:  20
                Layout.rightMargin: 20
                Layout.fillWidth:   true
                height:  64; radius: 12
                color:   ThemeSettings.sectionBg
                border.width: 1
                border.color: SoundService.activeSink
                                ? Qt.rgba(ThemeSettings.accentColor.r,
                                          ThemeSettings.accentColor.g,
                                          ThemeSettings.accentColor.b, 0.55)
                                : ThemeSettings.borderColor
                Behavior on border.color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    spacing: 14

                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: Qt.rgba(ThemeSettings.accentColor.r,
                                       ThemeSettings.accentColor.g,
                                       ThemeSettings.accentColor.b, 0.15)
                        Text {
                            anchors.centerIn: parent
                            text: root.sinkIcon(root.nodeName(SoundService.activeSink))
                            font.family: ThemeGlobal.fontIcons; font.pixelSize: 20
                            color: ThemeSettings.accentColor
                        }
                    }

                    Column {
                        Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 2
                        Text {
                            text: SoundService.activeSink
                                    ? root.nodeName(SoundService.activeSink)
                                    : "No output device"
                            font.pixelSize: 13; font.weight: Font.Medium
                            font.family: ThemeGlobal.fontSans; color: ThemeSettings.textColor
                            elide: Text.ElideRight; width: parent.width
                        }
                        Text {
                            text: SoundService.activeSink ? "Active output" : "No device found"
                            font.pixelSize: 11; font.family: ThemeGlobal.fontSans
                            color: SoundService.activeSink ? ThemeSettings.accentColor : ThemeSettings.subColor
                        }
                    }

                    Text {
                        visible: SoundService.activeSink && SoundService.activeSink.audio
                        text: SoundService.activeSink?.audio
                                ? Math.round((SoundService.activeSink.audio.volume ?? 0) * 100) + "%"
                                : ""
                        font.pixelSize: 12; font.family: ThemeGlobal.fontMono
                        color: ThemeSettings.subColor
                    }
                }
            }

            Item { Layout.preferredHeight: 12 }

            // Sink list
            Repeater {
                model: SoundService.sinks

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    readonly property bool isActive: SoundService.activeSink === modelData

                    Layout.leftMargin:   20
                    Layout.rightMargin:  20
                    Layout.fillWidth:    true
                    Layout.bottomMargin: 4
                    height:  48; radius: 10

                    color: isActive
                             ? Qt.rgba(ThemeSettings.accentColor.r,
                                       ThemeSettings.accentColor.g,
                                       ThemeSettings.accentColor.b, 0.10)
                             : sinkHover.hovered
                               ? Qt.rgba(ThemeSettings.textColor.r,
                                         ThemeSettings.textColor.g,
                                         ThemeSettings.textColor.b, 0.05)
                               : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    HoverHandler { id: sinkHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler   { onTapped: SoundService.setDefaultSink(modelData) }

                    RowLayout {
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                        spacing: 12

                        Text {
                            text: root.sinkIcon(root.nodeName(modelData))
                            font.family: ThemeGlobal.fontIcons; font.pixelSize: 16
                            color: isActive ? ThemeSettings.accentColor : ThemeSettings.subColor
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.nodeName(modelData)
                            font.pixelSize: 12; font.family: ThemeGlobal.fontSans
                            font.weight: isActive ? Font.Medium : Font.Normal
                            color: isActive ? ThemeSettings.textColor : ThemeSettings.subColor
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: isActive
                            text: "󰄬"; font.family: ThemeGlobal.fontIcons; font.pixelSize: 14
                            color: ThemeSettings.accentColor
                        }
                    }
                }
            }

            // ══════════════════════════════════════
            //  INPUT
            // ══════════════════════════════════════

            Item { Layout.preferredHeight: 16 }

            Rectangle {
                Layout.fillWidth: true; Layout.leftMargin: 20; Layout.rightMargin: 20
                implicitHeight: 1; color: ThemeSettings.separatorColor
            }

            Item { Layout.preferredHeight: 16 }

            Text {
                Layout.leftMargin: 20
                text: "INPUT"
                font.pixelSize: ThemeWidgets.sectionLabel.fontSize
                font.weight:    Font.Medium
                font.family:    ThemeGlobal.fontSans
                color:          ThemeSettings.subColor
                leftPadding:    4
            }

            Item { Layout.preferredHeight: 8 }

            Rectangle {
                Layout.leftMargin:  20
                Layout.rightMargin: 20
                Layout.fillWidth:   true
                height:  64; radius: 12
                color:   ThemeSettings.sectionBg
                border.width: 1
                border.color: SoundService.activeSource
                                ? Qt.rgba(ThemeSettings.accentColor.r,
                                          ThemeSettings.accentColor.g,
                                          ThemeSettings.accentColor.b, 0.55)
                                : ThemeSettings.borderColor
                Behavior on border.color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    spacing: 14

                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: Qt.rgba(ThemeSettings.accentColor.r,
                                       ThemeSettings.accentColor.g,
                                       ThemeSettings.accentColor.b, 0.15)
                        Text {
                            anchors.centerIn: parent
                            text: root.sourceIcon(root.nodeName(SoundService.activeSource))
                            font.family: ThemeGlobal.fontIcons; font.pixelSize: 20
                            color: SoundService.activeSource ? ThemeSettings.accentColor : ThemeSettings.subColor
                        }
                    }

                    Column {
                        Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 2
                        Text {
                            text: SoundService.activeSource
                                    ? root.nodeName(SoundService.activeSource)
                                    : "No input device"
                            font.pixelSize: 13; font.weight: Font.Medium
                            font.family: ThemeGlobal.fontSans; color: ThemeSettings.textColor
                            elide: Text.ElideRight; width: parent.width
                        }
                        Text {
                            text: SoundService.activeSource ? "Active input" : "No device found"
                            font.pixelSize: 11; font.family: ThemeGlobal.fontSans
                            color: SoundService.activeSource ? ThemeSettings.accentColor : ThemeSettings.subColor
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 12 }

            Repeater {
                model: SoundService.sources

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    readonly property bool isActive: SoundService.activeSource === modelData

                    Layout.leftMargin:   20
                    Layout.rightMargin:  20
                    Layout.fillWidth:    true
                    Layout.bottomMargin: 4
                    height:  48; radius: 10

                    color: isActive
                             ? Qt.rgba(ThemeSettings.accentColor.r,
                                       ThemeSettings.accentColor.g,
                                       ThemeSettings.accentColor.b, 0.10)
                             : srcHover.hovered
                               ? Qt.rgba(ThemeSettings.textColor.r,
                                         ThemeSettings.textColor.g,
                                         ThemeSettings.textColor.b, 0.05)
                               : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    HoverHandler { id: srcHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler   { onTapped: SoundService.setDefaultSource(modelData) }

                    RowLayout {
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                        spacing: 12

                        Text {
                            text: root.sourceIcon(root.nodeName(modelData))
                            font.family: ThemeGlobal.fontIcons; font.pixelSize: 16
                            color: isActive ? ThemeSettings.accentColor : ThemeSettings.subColor
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.nodeName(modelData)
                            font.pixelSize: 12; font.family: ThemeGlobal.fontSans
                            font.weight: isActive ? Font.Medium : Font.Normal
                            color: isActive ? ThemeSettings.textColor : ThemeSettings.subColor
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: isActive
                            text: "󰄬"; font.family: ThemeGlobal.fontIcons; font.pixelSize: 14
                            color: ThemeSettings.accentColor
                        }
                    }
                }
            }


            Item { Layout.preferredHeight: 20 }
        }
    }
}
