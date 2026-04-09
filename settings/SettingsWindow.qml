import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../themes"

PanelWindow {

    id: root

    required property var panelState

    implicitWidth:  Screen.width
    implicitHeight: Screen.height
    color:          "transparent"

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: panelState.settingsOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }

    mask: panelState.settingsOpen ? fullMask : emptyMask

    Region { id: emptyMask }
    Region {
        id: fullMask
        width:  root.implicitWidth
        height: root.implicitHeight
    }

    Rectangle {
        anchors.fill: parent
        color:        ThemeSettings.overlayColor
        opacity:      panelState.settingsOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: ThemeSettings.animDuration; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked:    panelState.settingsOpen = false
        }
    }

    Rectangle {
        id: win

        property bool initialized: false
        Component.onCompleted: initialized = true

        width:  ThemeSettings.windowWidth
        height: ThemeSettings.windowHeight
        anchors.centerIn: parent
        radius: ThemeSettings.radius
        color:  ThemeSettings.bgColor
        border.width: 1
        border.color: ThemeSettings.borderColor
        clip: true

        opacity: panelState.settingsOpen ? 1 : 0
        scale:   panelState.settingsOpen ? 1 : 0.94

        Behavior on opacity {
            enabled: win.initialized
            NumberAnimation { duration: ThemeSettings.animDuration; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            enabled: win.initialized
            NumberAnimation { duration: ThemeSettings.animDuration; easing.type: Easing.OutBack; easing.overshoot: 0.4 }
        }

        MouseArea {
            anchors.fill: parent
            onClicked:    (mouse) => { mouse.accepted = true }
        }

        property int activePage: 0

        RowLayout {
            anchors.fill: parent
            spacing:      0

            Rectangle {
                Layout.preferredWidth: ThemeSettings.navWidth
                Layout.fillHeight:     true
                color:                 ThemeSettings.bgColor
                topLeftRadius:         win.radius
                bottomLeftRadius:      win.radius
                topRightRadius:        0
                bottomRightRadius:     0

                Column {
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right
                    }
                    spacing: 2

                    Item { width: 1; height: 16 }

                    Text {
                        x:              16
                        text:           "Settings"
                        font.pixelSize: 13
                        font.weight:    Font.Bold
                        font.family:    ThemeGlobal.fontSans
                        color:          ThemeSettings.textColor
                    }

                    Item { width: 1; height: 8 }

                    Rectangle {
                        width:  parent.width - 24
                        height: 1; x: 12
                        color:  ThemeSettings.separatorColor
                    }

                    Item { width: 1; height: 8 }

                    Repeater {
                        model: [
                            { icon: "󰒓", label: "General"   },
                            { icon: "󰏘", label: "Design"    },
                            { icon: "󰖩", label: "Network"   },
                            { icon: "󰂯", label: "Bluetooth" },
                            { icon: "󰕾", label: "Sound"     },
                            { icon: "󰌢", label: "Device"    }
                        ]

                        delegate: Rectangle {
                            required property var  modelData
                            required property int  index

                            readonly property bool active: win.activePage === index

                            width:   parent.width - 16
                            height:  38
                            x:       8
                            radius:  10
                            color:   active
                                       ? Qt.rgba(ThemeSettings.accentColor.r,
                                                 ThemeSettings.accentColor.g,
                                                 ThemeSettings.accentColor.b, 0.15)
                                       : (navHover.hovered
                                           ? Qt.rgba(ThemeSettings.textColor.r,
                                                     ThemeSettings.textColor.g,
                                                     ThemeSettings.textColor.b, 0.05)
                                           : "transparent")

                            Behavior on color { enabled: !active && !navHover.hovered; ColorAnimation { duration: 80 } }

                            HoverHandler { id: navHover; cursorShape: Qt.PointingHandCursor }

                            Rectangle {
                                anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                                width:  3
                                height: active ? 18 : 0
                                radius: 2
                                color:  ThemeSettings.accentColor
                            }

                            RowLayout {
                                anchors { fill: parent; leftMargin: 16 }
                                spacing: 9

                                Text {
                                    text:            modelData.icon
                                    font.family:     ThemeGlobal.fontIcons
                                    font.pixelSize:  15
                                    color:           active ? ThemeSettings.accentColor : ThemeSettings.subColor
                                    Layout.preferredWidth: 24
                                    horizontalAlignment:   Text.AlignHCenter
                                }

                                Text {
                                    text:             modelData.label
                                    font.pixelSize:   12
                                    font.weight:      active ? Font.Medium : Font.Normal
                                    font.family:      ThemeGlobal.fontSans
                                    color:            active ? ThemeSettings.textColor : ThemeSettings.subColor
                                    Layout.fillWidth: true
                                }
                            }

                            TapHandler {
                                cursorShape: Qt.PointingHandCursor
                                onTapped:    win.activePage = index
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                color:             ThemeSettings.bgColor
                topLeftRadius:     0
                bottomLeftRadius:  0
                topRightRadius:    win.radius
                bottomRightRadius: win.radius

                component EmptyPage: Item {
                    required property string label
                    Text {
                        anchors.centerIn: parent
                        text:             label
                        font.pixelSize:   13
                        font.family:      ThemeGlobal.fontSans
                        color:            ThemeSettings.subColor
                    }
                }

                Loader {
                    anchors.fill: parent
                    active:       win.activePage === 0
                    sourceComponent: GeneralSettings { anchors.fill: parent }
                }

                Loader {
                    anchors.fill: parent
                    active:       win.activePage === 1
                    sourceComponent: DesignSettings { anchors.fill: parent }
                }

                Loader {
                    anchors.fill: parent
                    active:       win.activePage === 2
                    sourceComponent: NetworkSettings {
                        anchors.fill: parent
                        panelState:   root.panelState
                    }
                }

                Loader {
                    anchors.fill: parent
                    active:       win.activePage === 3
                    sourceComponent: BluetoothSettings { anchors.fill: parent }
                }

                Loader {
                    anchors.fill: parent
                    active:       win.activePage === 4
                    sourceComponent: SoundSettings { anchors.fill: parent }
                }

                Loader {
                    anchors.fill: parent
                    active:       win.activePage === 5
                    sourceComponent: DeviceSettings { anchors.fill: parent }
                }
            }
        }

        Rectangle {
            x:              ThemeSettings.navWidth
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          1
            color:          ThemeSettings.separatorColor
        }
    }
}
