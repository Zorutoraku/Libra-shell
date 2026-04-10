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

    required property var panelState

    property string selectedSsid:  ""
    property string passwordInput: ""
    property string connectStatus: ""
    property bool   scanning:      false

    // nmcli can return duplicate SSIDs, deduplicate by ssid key
    property var filteredNetworks: {
        const nets = NetworkService.networks
        if (!nets || !NetworkService.wifiEnabled) return []
        const seen = {}
        const arr  = []
        for (let i = 0; i < nets.length; i++) {
            const ssid = nets[i].ssid
            if (ssid && !seen[ssid]) { seen[ssid] = true; arr.push(nets[i]) }
        }
        return arr
    }

    Process {
        id: connectProc
        onExited: (code) => {
            connectStatus = (code === 0) ? "ok" : "fail"
            statusClearTimer.restart()
            if (code === 0) {
                selectedSsid  = ""
                passwordInput = ""
                rescanProc.running = true // refresh list so connected network shows active
            }
        }
    }

    Timer {
        id: statusClearTimer
        interval: 2000
        onTriggered: root.connectStatus = ""
    }

    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onStarted: root.scanning = true
        onExited:  root.scanning = false
    }

    function tryConnect(ssid, password) {
        if (connectProc.running) return
        connectStatus = "connecting"
        selectedSsid  = ssid
        let cmd = ["nmcli", "d", "wifi", "connect", ssid]
        if (password !== "") cmd = cmd.concat(["password", password])
        connectProc.command = cmd
        connectProc.running = true
    }

    // --- Design ---

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Column {
            Layout.fillWidth: true; Layout.topMargin: 20; spacing: 8

            Text {
                x: 20
                text: "WIRELESS"
                font.pixelSize: ThemeWidgets.sectionLabel.fontSize
                font.weight:    Font.Medium
                font.family:    ThemeGlobal.fontSans
                color:          ThemeSettings.subColor
                leftPadding:    4
            }

            Rectangle {
                x: 20; width: parent.width - 40; height: 64
                radius: 12; color: ThemeSettings.sectionBg; border.width: 1
                border.color: NetworkService.wifiEnabled && NetworkService.active
                                ? Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.55)
                                : ThemeSettings.borderColor
                Behavior on border.color { ColorAnimation { duration: 200 } }

                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    spacing: 14

                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.15)
                        Text {
                            anchors.centerIn: parent
                            text: NetworkService.wifiEnabled ? "󰖩" : "󰖪"
                            font.family: ThemeGlobal.fontIcons; font.pixelSize: 20
                            color: NetworkService.wifiEnabled ? ThemeSettings.accentColor : ThemeSettings.subColor
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    Column {
                        Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 2
                        Text {
                            text: NetworkService.wifiEnabled && NetworkService.active
                                    ? NetworkService.active.ssid
                                    : (NetworkService.wifiEnabled ? "No network" : "Wi-Fi off")
                            font.pixelSize: 13; font.weight: Font.Medium
                            font.family: ThemeGlobal.fontSans; color: ThemeSettings.textColor
                            elide: Text.ElideRight; width: parent.width
                        }
                        Text {
                            text: NetworkService.wifiEnabled && NetworkService.active
                                    ? "Connected"
                                    : (NetworkService.wifiEnabled ? "Not connected" : "Disabled")
                            font.pixelSize: 11; font.family: ThemeGlobal.fontSans
                            color: NetworkService.wifiEnabled && NetworkService.active
                                    ? ThemeSettings.accentColor : ThemeSettings.subColor
                        }
                    }

                    Rectangle {
                        id: wifiToggle
                        property bool checked: NetworkService.wifiEnabled
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
                            x:     wifiToggle.checked ? parent.width - width - 2 : 2
                            color: wifiToggle.checked ? ThemeSettings.sectionBg : ThemeSettings.textColor
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on x     { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                        }
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        TapHandler   { onTapped: NetworkService.toggleWifi() }
                    }
                }
            }
        }

        Item { Layout.preferredHeight: 20 }

        RowLayout {
            Layout.fillWidth: true; Layout.leftMargin: 24; Layout.rightMargin: 24

            Text {
                text: "AVAILABLE NETWORKS"
                font.pixelSize: ThemeWidgets.sectionLabel.fontSize
                font.weight:    Font.Medium
                font.family:    ThemeGlobal.fontSans
                color:          ThemeSettings.subColor
                leftPadding:    4
            }
            Item { Layout.fillWidth: true }

            Rectangle {
                width: 24; height: 24; radius: 6
                color: rfHover.hovered
                         ? Qt.rgba(ThemeSettings.textColor.r, ThemeSettings.textColor.g, ThemeSettings.textColor.b, 0.08)
                         : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }
                HoverHandler { id: rfHover }

                Text {
                    id: refreshIcon
                    anchors.centerIn: parent; text: "󰑓"
                    font.family: ThemeGlobal.fontIcons; font.pixelSize: 13
                    color: root.scanning ? ThemeSettings.accentColor : ThemeSettings.subColor
                    Behavior on color { ColorAnimation { duration: 150 } }

                    RotationAnimator on rotation {
                        from: 0; to: 360; duration: 900
                        loops: Animation.Infinite; running: root.scanning
                    }
                    NumberAnimation on rotation {
                        running: !root.scanning; to: 0; duration: 200; easing.type: Easing.OutCubic
                    }
                }

                TapHandler {
                    cursorShape: Qt.PointingHandCursor
                    onTapped: if (!root.scanning) rescanProc.running = true
                }
            }
        }

        Item { Layout.preferredHeight: 8; visible: NetworkService.wifiEnabled }

        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true; contentWidth: availableWidth
            ScrollBar.vertical:   ScrollBar { policy: ScrollBar.AlwaysOff }
            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOff }

            Column {
                width: parent.width; spacing: 4

                Item {
                    width: parent.width; height: NetworkService.wifiEnabled ? 0 : 80
                    visible: !NetworkService.wifiEnabled
                    Text {
                        anchors.centerIn: parent
                        text: "Enable Wi-Fi to see available networks"
                        font.pixelSize: 12; font.family: ThemeGlobal.fontSans; color: ThemeSettings.hintColor
                    }
                }

                Repeater {
                    model: NetworkService.wifiEnabled ? root.filteredNetworks : []

                    delegate: Item {
                        required property var modelData
                        required property int index

                        readonly property bool isActive:   modelData.active
                        readonly property bool isSelected: root.selectedSsid === modelData.ssid
                        readonly property int  sig:        modelData.strength

                        property bool showPassword: false

                        onIsSelectedChanged: {
                            if (isSelected) { pwField.text = ""; pwField.forceActiveFocus() }
                            else            { showPassword = false }
                        }

                        width: parent.width - 40; x: 20; height: 56

                        Rectangle {
                            id: frontFace
                            anchors.fill: parent; radius: 10
                            color: isActive
                                     ? Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.10)
                                     : (rowHover.hovered
                                         ? Qt.rgba(ThemeSettings.textColor.r, ThemeSettings.textColor.g, ThemeSettings.textColor.b, 0.05)
                                         : "transparent")
                            Behavior on color { ColorAnimation { duration: 100 } }

                            opacity: isSelected ? 0 : 1; scale: isSelected ? 0.92 : 1
                            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InCubic } }
                            Behavior on scale   { NumberAnimation { duration: 140; easing.type: Easing.InCubic } }
                            visible: opacity > 0

                            HoverHandler { id: rowHover; cursorShape: isActive ? Qt.ArrowCursor : Qt.PointingHandCursor }
                            TapHandler {
                                enabled: !isActive
                                onTapped: {
                                    root.selectedSsid  = (root.selectedSsid === modelData.ssid) ? "" : modelData.ssid
                                    root.connectStatus = ""
                                    root.passwordInput = ""
                                }
                            }

                            RowLayout {
                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                                spacing: 12
                                Text {
                                    text: { if (sig >= 75) return "󰤨"; if (sig >= 50) return "󰤥"; if (sig >= 25) return "󰤢"; return "󰤟" }
                                    font.family: ThemeGlobal.fontIcons; font.pixelSize: 18
                                    color: isActive ? ThemeSettings.accentColor : ThemeSettings.subColor
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.ssid; font.pixelSize: 13
                                    font.weight: isActive ? Font.Medium : Font.Normal
                                    font.family: ThemeGlobal.fontSans
                                    color: isActive ? ThemeSettings.textColor : ThemeSettings.subColor
                                    elide: Text.ElideRight
                                }
                                Text { visible: isActive;  text: "󰄬"; font.family: ThemeGlobal.fontIcons; font.pixelSize: 14; color: ThemeSettings.accentColor }
                                Text { visible: !isActive; text: "󱕆"; font.family: ThemeGlobal.fontIcons; font.pixelSize: 13; color: ThemeSettings.subColor }
                            }
                        }

                        Rectangle {
                            id: backFace
                            anchors.fill: parent; radius: 10
                            color: ThemeSettings.sectionBg; border.width: 1
                            
                            border.color: root.connectStatus === "fail" && root.selectedSsid === modelData.ssid
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

                                Rectangle {
                                    Layout.fillWidth: true; height: 36; radius: 8
                                    color: ThemeSettings.bgColor; border.width: 1
                                    border.color: pwField.activeFocus
                                                    ? Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.55)
                                                    : ThemeSettings.borderColor
                                    Behavior on border.color { ColorAnimation { duration: 120 } }

                                    RowLayout {
                                        anchors { fill: parent; leftMargin: 4; rightMargin: 4 }
                                        spacing: 0

                                        TextField {
                                            id: pwField
                                            Layout.fillWidth: true; Layout.fillHeight: true
                                            echoMode:        showPassword ? TextInput.Normal : TextInput.Password
                                            font.pixelSize:  12; font.family: ThemeGlobal.fontSans
                                            color:           ThemeSettings.textColor
                                            placeholderText: "Password"
                                            placeholderTextColor: ThemeSettings.textColor
                                            background:      Item {}
                                            onTextChanged:   if (root.selectedSsid === modelData.ssid) root.passwordInput = text
                                            onAccepted:      root.tryConnect(modelData.ssid, root.passwordInput)
                                        }

                                        Rectangle {
                                            width: 28; height: 28; radius: 6
                                            color: eyeHover.hovered
                                                     ? Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.12)
                                                     : "transparent"
                                            Behavior on color { ColorAnimation { duration: 100 } }
                                            Text {
                                                anchors.centerIn: parent
                                                text: showPassword ? "󰛑" : "󰛐"
                                                font.family: ThemeGlobal.fontIcons; font.pixelSize: 14
                                                color: showPassword ? ThemeSettings.accentColor : ThemeSettings.subColor
                                                Behavior on color { ColorAnimation { duration: 120 } }
                                            }
                                            HoverHandler { id: eyeHover; cursorShape: Qt.PointingHandCursor }
                                            TapHandler   { onTapped: { showPassword = !showPassword; pwField.forceActiveFocus() } }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 36; height: 36; radius: 8
                                    color: cancelHover.hovered
                                             ? Qt.rgba(ThemeSettings.textColor.r, ThemeSettings.textColor.g, ThemeSettings.textColor.b, 0.08)
                                             : "transparent"
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    Text { anchors.centerIn: parent; text: "󰅖"; font.family: ThemeGlobal.fontIcons; font.pixelSize: 14; color: ThemeSettings.subColor }
                                    HoverHandler { id: cancelHover; cursorShape: Qt.PointingHandCursor }
                                    TapHandler   { onTapped: { root.selectedSsid = ""; root.passwordInput = ""; root.connectStatus = "" } }
                                }

                                Rectangle {
                                    width: 36; height: 36; radius: 8
                                    
                                    color: root.connectStatus === "fail" && root.selectedSsid === modelData.ssid
                                             ? Qt.rgba(ThemeSettings.closeHoverColor.r, ThemeSettings.closeHoverColor.g, ThemeSettings.closeHoverColor.b, 0.18)
                                             : Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.18)
                                    border.width: 1
                                    border.color: root.connectStatus === "fail" && root.selectedSsid === modelData.ssid
                                                    ? Qt.rgba(ThemeSettings.closeHoverColor.r, ThemeSettings.closeHoverColor.g, ThemeSettings.closeHoverColor.b, 0.5)
                                                    : Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.4)
                                    Behavior on color        { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            if (root.connectStatus === "connecting" && root.selectedSsid === modelData.ssid) return "󰔟"
                                            if (root.connectStatus === "ok"         && root.selectedSsid === modelData.ssid) return "󰄬"
                                            if (root.connectStatus === "fail"       && root.selectedSsid === modelData.ssid) return "󰅖"
                                            return "󰖩"
                                        }
                                        font.family: ThemeGlobal.fontIcons; font.pixelSize: 16
                                        
                                        color: root.connectStatus === "fail" && root.selectedSsid === modelData.ssid
                                                 ? ThemeSettings.closeHoverColor : ThemeSettings.accentColor
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                                    TapHandler   { onTapped: root.tryConnect(modelData.ssid, root.passwordInput) }
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
            icon: "󰀝"; label: "Airplane Mode"
            sublabel: NetworkService.airplaneMode ? "All wireless connections disabled" : ""

            Rectangle {
                id: airplaneToggle
                property bool checked: NetworkService.airplaneMode
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
                    x:     airplaneToggle.checked ? parent.width - width - 2 : 2
                    color: airplaneToggle.checked ? ThemeSettings.sectionBg : ThemeSettings.textColor
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on x     { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                }
                HoverHandler { cursorShape: Qt.PointingHandCursor }
                TapHandler   { onTapped: NetworkService.toggleAirplane() }
            }
        }
    }

}
