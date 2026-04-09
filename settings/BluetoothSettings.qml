import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../themes"
import "../services"
import "../widgets"

Item {

    // --- Funktion ---

    id: root

    function deviceIcon(iconStr) {
        if (!iconStr) return "󰂯"
        const s = iconStr.toLowerCase()
        if (s.includes("headphone") || s.includes("headset"))   return "󰋎"
        if (s.includes("speaker")   || s.includes("audio-card")) return "󰓃"
        if (s.includes("keyboard"))  return "󰌌"
        if (s.includes("mouse"))     return "󰍽"
        if (s.includes("phone"))     return "󰏲"
        if (s.includes("computer")  || s.includes("laptop"))    return "󰇄"
        if (s.includes("joystick")  || s.includes("gamepad"))   return "󰊖"
        if (s.includes("camera"))    return "󰄀"
        return "󰂯"
    }

    property string selectedAddress:   ""
    property string connectingAddress: ""
    property string connectStatus:     ""
    property string failedAddress:     ""

    property var sortedDevices: {
        const devs = BluetoothService.allDevices
        if (!devs || devs.length === 0) return []
        return devs.slice().sort((a, b) => {
            if ( a.connected && !b.connected) return -1
            if (!a.connected &&  b.connected) return  1
            if ( a.paired    && !b.paired)    return -1
            if (!a.paired    &&  b.paired)    return  1
            return (a.name ?? "").localeCompare(b.name ?? "")
        })
    }

    Process {
        id: forgetProc
        onExited: (code) => {
            const addr             = root.selectedAddress
            root.selectedAddress   = ""
            root.connectingAddress = ""
            root.connectStatus     = code === 0 ? "ok" : "fail"
            root.failedAddress     = code === 0 ? "" : addr
            statusClearTimer.restart()
        }
    }

    Timer {
        id: connectTimeout
        interval: 8000
        onTriggered: {
            root.failedAddress     = root.connectingAddress
            root.connectingAddress = ""
            root.connectStatus     = "fail"
            statusClearTimer.restart()
        }
    }

    Timer {
        id: discoveryTimeout
        interval: 30000
        onTriggered: { if (BluetoothService.discovering) BluetoothService.stopDiscovery() }
    }

    Connections {
        target: BluetoothService
        function onDiscoveringChanged() {
            if (BluetoothService.discovering) discoveryTimeout.restart()
            else                              discoveryTimeout.stop()
        }
    }

    Timer {
        id: statusClearTimer
        interval: 2000
        onTriggered: { root.connectStatus = ""; root.failedAddress = "" }
    }

    // --- Design ---

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Column {
            Layout.fillWidth: true
            Layout.topMargin: 20
            spacing: 8

            Text {
                x: 20
                text: "BLUETOOTH"
                font.pixelSize: ThemeWidgets.sectionLabel.fontSize
                font.weight:    Font.Medium
                font.family:    ThemeGlobal.fontSans
                color:          ThemeSettings.subColor
                leftPadding:    4
            }

            Rectangle {
                x: 20; width: parent.width - 40; height: 64
                radius: 12; color: ThemeSettings.sectionBg
                border.width: 1
                border.color: BluetoothService.enabled
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
                            text:        BluetoothService.enabled ? "󰂯" : "󰂲"
                            font.family: ThemeGlobal.fontIcons; font.pixelSize: 20
                            color:       BluetoothService.enabled ? ThemeSettings.accentColor : ThemeSettings.subColor
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    Column {
                        Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 2
                        Text {
                            text: BluetoothService.active
                                    ? (BluetoothService.active.name ?? "Unknown Device")
                                    : (BluetoothService.enabled ? "No device connected" : "Bluetooth off")
                            font.pixelSize: 13; font.weight: Font.Medium
                            font.family: ThemeGlobal.fontSans; color: ThemeSettings.textColor
                            elide: Text.ElideRight; width: parent.width
                        }
                        Text {
                            text: BluetoothService.active ? "Connected"
                                    : (BluetoothService.enabled ? "Not connected" : "Disabled")
                            font.pixelSize: 11; font.family: ThemeGlobal.fontSans
                            color: BluetoothService.active ? ThemeSettings.accentColor : ThemeSettings.subColor
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    Rectangle {
                        id: bluetoothToggle
                        property bool checked: BluetoothService.enabled
                        implicitWidth:  44
                        implicitHeight: 24
                        radius:         height / 2
                        color:          checked ? ThemeSettings.accentColor : ThemeSettings.sectionBg
                        border.width:   1
                        border.color:   checked ? ThemeSettings.accentColor : ThemeSettings.borderColor
                        Behavior on color        { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        Rectangle {
                            width:  parent.height - 4; height: width; radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            x:     bluetoothToggle.checked ? parent.width - width - 2 : 2
                            color: bluetoothToggle.checked ? ThemeSettings.sectionBg : ThemeSettings.textColor
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on x     { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                        }
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        TapHandler   { onTapped: BluetoothService.toggleBluetooth() }
                    }
                }
            }
        }

        Item { Layout.preferredHeight: 20 }

        RowLayout {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24

            Text {
                text: "DEVICES"
                font.pixelSize: ThemeWidgets.sectionLabel.fontSize
                font.weight:    Font.Medium
                font.family:    ThemeGlobal.fontSans
                color:          ThemeSettings.subColor
                leftPadding:    4
            }
            Item { Layout.fillWidth: true }

            Rectangle {
                width: 24; height: 24; radius: 6
                color: scanHover.hovered
                         ? Qt.rgba(ThemeSettings.textColor.r, ThemeSettings.textColor.g, ThemeSettings.textColor.b, 0.08)
                         : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }
                HoverHandler { id: scanHover }

                Text {
                    id: scanIcon
                    anchors.centerIn: parent
                    text: "󰑓"; font.family: ThemeGlobal.fontIcons; font.pixelSize: 13
                    color: BluetoothService.discovering ? ThemeSettings.accentColor : ThemeSettings.subColor
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RotationAnimator on rotation {
                        from: 0; to: 360; duration: 900
                        loops: Animation.Infinite
                        running: BluetoothService.discovering
                    }
                    NumberAnimation on rotation {
                        running: !BluetoothService.discovering
                        to: 0; duration: 200; easing.type: Easing.OutCubic
                    }
                }

                TapHandler {
                    cursorShape: Qt.PointingHandCursor
                    onTapped: {
                        if (!BluetoothService.enabled) return
                        if (BluetoothService.discovering) BluetoothService.stopDiscovery()
                        else                              BluetoothService.startDiscovery()
                    }
                }
            }
        }

        Item { Layout.preferredHeight: 8; visible: BluetoothService.enabled }

        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true; contentWidth: availableWidth
            ScrollBar.vertical:   ScrollBar { policy: ScrollBar.AlwaysOff }
            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }

            Column {
                width: parent.width; spacing: 4

                Item {
                    width: parent.width; height: !BluetoothService.enabled ? 80 : 0
                    visible: !BluetoothService.enabled
                    Text {
                        anchors.centerIn: parent
                        text: "Enable Bluetooth to see devices"
                        font.pixelSize: 12; font.family: ThemeGlobal.fontSans
                        color: ThemeSettings.hintColor
                    }
                }

                Item {
                    width: parent.width
                    height: BluetoothService.enabled && root.sortedDevices.length === 0 ? 80 : 0
                    visible: BluetoothService.enabled && root.sortedDevices.length === 0
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No devices found"
                            font.pixelSize: 12; font.family: ThemeGlobal.fontSans; color: ThemeSettings.hintColor
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: BluetoothService.discovering ? "Scanning…" : "Tap 󰑓 to scan"
                            font.pixelSize: 11; font.family: ThemeGlobal.fontSans; color: ThemeSettings.hintColor
                        }
                    }
                }

                Repeater {
                    model: BluetoothService.enabled ? root.sortedDevices : []

                    delegate: Item {
                        required property var modelData
                        required property int index

                        readonly property bool isConnected:  modelData.connected
                        readonly property bool isPaired:     modelData.paired
                        readonly property bool isSelected:   root.selectedAddress === modelData.address
                        readonly property bool isProcessing: root.connectingAddress === modelData.address
                        readonly property bool isFailed:     root.connectStatus === "fail" && root.failedAddress === modelData.address

                        Connections {
                            target: modelData
                            function onConnectedChanged() {
                                if (modelData.address === root.connectingAddress) {
                                    connectTimeout.stop()
                                    root.connectingAddress = ""
                                    root.connectStatus     = "ok"
                                    root.selectedAddress   = ""
                                    statusClearTimer.restart()
                                }
                            }
                        }

                        width: parent.width - 40; x: 20; height: 56

                        Rectangle {
                            id: frontFace
                            anchors.fill: parent; radius: 10
                            color: isConnected
                                     ? Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.10)
                                     : (rowHover.hovered
                                         ? Qt.rgba(ThemeSettings.textColor.r, ThemeSettings.textColor.g, ThemeSettings.textColor.b, 0.05)
                                         : "transparent")
                            Behavior on color { ColorAnimation { duration: 100 } }

                            opacity: isSelected ? 0 : 1; scale: isSelected ? 0.92 : 1
                            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InCubic } }
                            Behavior on scale   { NumberAnimation { duration: 140; easing.type: Easing.InCubic } }
                            visible: opacity > 0

                            HoverHandler { id: rowHover; cursorShape: Qt.PointingHandCursor }
                            TapHandler {
                                onTapped: {
                                    root.selectedAddress = (root.selectedAddress === modelData.address) ? "" : modelData.address
                                    root.connectStatus   = ""
                                }
                            }

                            RowLayout {
                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                                spacing: 12
                                Text {
                                    text: root.deviceIcon(modelData.icon ?? "")
                                    font.family: ThemeGlobal.fontIcons; font.pixelSize: 18
                                    color: isConnected ? ThemeSettings.accentColor : ThemeSettings.subColor
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                Column {
                                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 2
                                    Text {
                                        text: modelData.name ?? modelData.address ?? "Unknown"
                                        font.pixelSize: 13; font.weight: isConnected ? Font.Medium : Font.Normal
                                        font.family: ThemeGlobal.fontSans
                                        color: isConnected ? ThemeSettings.textColor : ThemeSettings.subColor
                                        elide: Text.ElideRight; width: parent.width
                                    }
                                    Text {
                                        text: isConnected ? "Connected" : (isPaired ? "Paired" : "Discovered")
                                        font.pixelSize: 11; font.family: ThemeGlobal.fontSans
                                        color: isConnected ? ThemeSettings.accentColor : ThemeSettings.hintColor
                                    }
                                }
                                Text {
                                    text: "󰅂"; font.family: ThemeGlobal.fontIcons; font.pixelSize: 13
                                    color: ThemeSettings.subColor
                                }
                            }
                        }

                        Rectangle {
                            id: backFace
                            anchors.fill: parent; radius: 10
                            color: ThemeSettings.sectionBg; border.width: 1
                            border.color: isFailed
                                            ? Qt.rgba(ThemeSettings.closeHoverColor.r, ThemeSettings.closeHoverColor.g, ThemeSettings.closeHoverColor.b, 0.55)
                                            : ThemeSettings.borderColor
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            opacity: isSelected ? 1 : 0; scale: isSelected ? 1 : 0.92
                            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                            Behavior on scale   { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                            visible: opacity > 0

                            RowLayout {
                                anchors { fill: parent; margins: 10 }
                                spacing: 8
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name ?? modelData.address ?? "Unknown"
                                    font.pixelSize: 12; font.family: ThemeGlobal.fontSans; font.weight: Font.Medium
                                    color: ThemeSettings.textColor; elide: Text.ElideRight
                                }

                                Rectangle {
                                    visible: isPaired || isConnected
                                    width: 36; height: 36; radius: 8
                                    color: forgetHover.hovered
                                             ? Qt.rgba(ThemeSettings.closeHoverColor.r, ThemeSettings.closeHoverColor.g, ThemeSettings.closeHoverColor.b, 0.18)
                                             : "transparent"
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    Text {
                                        anchors.centerIn: parent; text: "󰗜"
                                        font.family: ThemeGlobal.fontIcons; font.pixelSize: 15
                                        color: forgetHover.hovered ? ThemeSettings.closeHoverColor : ThemeSettings.subColor
                                        Behavior on color { ColorAnimation { duration: 100 } }
                                    }
                                    HoverHandler { id: forgetHover; cursorShape: Qt.PointingHandCursor }
                                    TapHandler {
                                        onTapped: {
                                            const addr = modelData.address
                                            if (!addr) return
                                            forgetProc.command = ["bluetoothctl", "remove", addr]
                                            forgetProc.running = true
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 36; height: 36; radius: 8
                                    color: cancelHover.hovered
                                             ? Qt.rgba(ThemeSettings.textColor.r, ThemeSettings.textColor.g, ThemeSettings.textColor.b, 0.08)
                                             : "transparent"
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    Text {
                                        anchors.centerIn: parent; text: "󰅖"
                                        font.family: ThemeGlobal.fontIcons; font.pixelSize: 14
                                        color: ThemeSettings.subColor
                                    }
                                    HoverHandler { id: cancelHover; cursorShape: Qt.PointingHandCursor }
                                    TapHandler {
                                        onTapped: {
                                            root.selectedAddress   = ""
                                            root.connectingAddress = ""
                                            root.connectStatus     = ""
                                            connectTimeout.stop()
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 36; height: 36; radius: 8
                                    color: isFailed
                                             ? Qt.rgba(ThemeSettings.closeHoverColor.r, ThemeSettings.closeHoverColor.g, ThemeSettings.closeHoverColor.b, 0.18)
                                             : Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.18)
                                    border.width: 1
                                    border.color: isFailed
                                                    ? Qt.rgba(ThemeSettings.closeHoverColor.r, ThemeSettings.closeHoverColor.g, ThemeSettings.closeHoverColor.b, 0.5)
                                                    : Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.4)
                                    Behavior on color        { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            if (isProcessing) return "󰔟"
                                            if (root.connectStatus === "ok" && root.connectingAddress === modelData.address) return "󰄬"
                                            if (isFailed)                                                                   return "󰅖"
                                            return isConnected ? "󰂲" : "󰂯"
                                        }
                                        font.family: ThemeGlobal.fontIcons; font.pixelSize: 16
                                        color: isFailed ? ThemeSettings.closeHoverColor : ThemeSettings.accentColor
                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        RotationAnimator on rotation {
                                            from: 0; to: 360; duration: 900
                                            loops: Animation.Infinite; running: isProcessing
                                        }
                                        NumberAnimation on rotation {
                                            running: !isProcessing; to: 0; duration: 150
                                        }
                                    }
                                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                                    TapHandler {
                                        onTapped: {
                                            if (isProcessing) return
                                            root.connectingAddress = modelData.address
                                            connectTimeout.restart()
                                            if (isConnected) BluetoothService.disconnectDevice(modelData)
                                            else             BluetoothService.connectDevice(modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item { width: 1; height: 8 }
            }
        }

        Rectangle {
            Layout.fillWidth: true; Layout.bottomMargin: 20
            Layout.leftMargin: 20; Layout.rightMargin: 20
            implicitHeight: 1; color: ThemeSettings.separatorColor
        }

        SettingItem {
            Layout.fillWidth: true; Layout.bottomMargin: 20
            Layout.leftMargin: 20; Layout.rightMargin: 20
            icon: "󰾰"; label: "Discoverable"
            sublabel: BluetoothService.discoverable ? "Other devices can find this device" : ""

            Rectangle {
                id: discoverableToggle
                property bool checked: BluetoothService.discoverable
                implicitWidth:  44
                implicitHeight: 24
                radius:         height / 2
                color:          checked ? ThemeSettings.accentColor : ThemeSettings.sectionBg
                border.width:   1
                border.color:   checked ? ThemeSettings.accentColor : ThemeSettings.borderColor
                Behavior on color        { ColorAnimation { duration: 200 } }
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Rectangle {
                    width:  parent.height - 4; height: width; radius: width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    x:     discoverableToggle.checked ? parent.width - width - 2 : 2
                    color: discoverableToggle.checked ? ThemeSettings.sectionBg : ThemeSettings.textColor
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on x     { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                }
                HoverHandler { cursorShape: Qt.PointingHandCursor }
                TapHandler   { onTapped: BluetoothService.setDiscoverable(!BluetoothService.discoverable) }
            }
        }
    }
}
