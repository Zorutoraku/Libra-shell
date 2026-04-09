import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../widgets"
import "../themes"
import "../services"

PanelWindow {

    id: root

    required property var panelState

    readonly property int peekWidth: ThemePanels.rightBottom.peekWidth
    readonly property int boxWidth:  ThemePanels.rightBottom.width
    readonly property int boxHeight: ThemePanels.rightBottom.height
    readonly property int openX:     Screen.width - boxWidth - ThemePanels.rightMargin
    readonly property int closedX:   Screen.width - peekWidth

    implicitWidth:  Screen.width
    implicitHeight: Screen.height
    color: "transparent"

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1

    anchors { top: true; bottom: true; right: true }

    mask: panelState.right2Open ? openMask : peekMask

    Region {
        id: openMask
        regions: [
            Region { x: root.openX;   y: panel.y; width: root.boxWidth;  height: root.boxHeight },
            Region { x: root.closedX; y: panel.y; width: root.peekWidth; height: root.boxHeight }
        ]
    }

    Region { id: peekMask
        regions: [ Region { x: root.closedX; y: panel.y; width: root.peekWidth; height: root.boxHeight } ]
    }

    Rectangle {
        id: panel
        property bool initialized: false
        Component.onCompleted: initialized = true

        width:  root.boxWidth
        height: root.boxHeight
        anchors { bottom: parent.bottom; bottomMargin: ThemePanels.rightBottom.bottomMargin }
        x:      panelState.right2Open ? root.openX : root.closedX
        radius: ThemePanels.rightBottom.radius
        color:  ThemePanels.rightBottom.color

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => mouse.accepted = true
        }

        Column {
            id: contentCol
            readonly property int _margin:   16
            readonly property int _gridGap:  16
            readonly property int _contentH: ThemeWidgets.actionButton.height
                                           + (ThemeWidgets.toggleButton.height * 2 + _gridGap)
                                           + ThemeWidgets.slider.height * 2
            readonly property int _spacing:  (ThemePanels.rightBottom.height - _margin * 2 - _contentH) / 3

            anchors { fill: parent; margins: _margin }
            spacing: _spacing

            RowLayout {
                width:   parent.width
                height:  ThemeWidgets.actionButton.height
                spacing: 8

                ActionButton {
                    icon:    "󰒓"
                    variant: "normal"
                    width:   ThemeWidgets.actionButton.height
                    height:  ThemeWidgets.actionButton.height
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    panelState.settingsOpen = !panelState.settingsOpen
                    }
                }
                ActionButton {
                    icon:    "󰑓"
                    variant: "warning"
                    width:   ThemeWidgets.actionButton.height
                    height:  ThemeWidgets.actionButton.height
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    Quickshell.execDetached(["systemctl", "reboot"])
                    }
                }
                ActionButton {
                    icon:    "󰐥"
                    variant: "danger"
                    width:   ThemeWidgets.actionButton.height
                    height:  ThemeWidgets.actionButton.height
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    Quickshell.execDetached(["systemctl", "poweroff"])
                    }
                }

                PowerModeSelector {
                    Layout.fillWidth: true
                    height:           ThemeWidgets.actionButton.height
                }
            }

            Grid {
                width:   parent.width
                columns: 2
                spacing: contentCol._gridGap

                ToggleButton {
                    width:       (contentCol.width - contentCol._gridGap) / 2
                    label:       "WiFi"
                    sublabel:    NetworkService.wifiEnabled ? (NetworkService.active ? NetworkService.active.ssid : "On") : "Off"
                    icon:        "󰖩"
                    active:      NetworkService.wifiEnabled
                    MouseArea {
                        anchors.fill:    parent
                        cursorShape:     Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked:       NetworkService.toggleWifi()
                    }
                }

                ToggleButton {
                    width:       (contentCol.width - contentCol._gridGap) / 2
                    label:       "Bluetooth"
                    sublabel:    BluetoothService.sublabel
                    icon:        "󰂯"
                    active:      BluetoothService.enabled
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    BluetoothService.toggleBluetooth()
                    }
                }

                ToggleButton {
                    width:    (contentCol.width - contentCol._gridGap) / 2
                    label:    "Flugmodus"
                    sublabel: NetworkService.airplaneMode ? "An" : "Aus"
                    icon:     "󰀝"
                    active:   NetworkService.airplaneMode
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    NetworkService.toggleAirplane()
                    }
                }

                ToggleButton {
                    id: dndToggle
                    width:    (contentCol.width - contentCol._gridGap) / 2
                    label:    "DND"
                    sublabel: panelState.dndEnabled ? "An" : "Aus"
                    icon:     "󰂛"
                    active:   panelState.dndEnabled
                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    panelState.dndEnabled = !panelState.dndEnabled
                    }
                }
            }

            VolumeSlider     { width: parent.width }
            BrightnessSlider { width: parent.width }
        }

        Behavior on x {
            enabled: panel.initialized
            NumberAnimation {
                duration:         ThemePanels.rightBottom.animDuration
                easing.type:      Easing.OutBack
                easing.overshoot: ThemePanels.rightBottom.animOvershoot
            }
        }
    }

    Item {
        x: root.closedX; y: panel.y
        width: root.peekWidth; height: root.boxHeight
        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked: panelState.right2Open = !panelState.right2Open
        }
    }
}
