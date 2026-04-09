import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../themes"
import "../widgets"   

Item {

    // --- Funktion ---

    id: root

    readonly property int maxPanelRadius: 28

    // --- Design ---

    MouseArea {
        anchors.fill:            parent
        z:                       -1
        propagateComposedEvents: true
        onPressed: (mouse) => { customInput.focus = false; mouse.accepted = false }
    }

    ScrollView {
        anchors.fill:                parent
        contentWidth:                parent.width
        ScrollBar.vertical.policy:   ScrollBar.AlwaysOff
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width:   root.width
            spacing: 0

            Item { Layout.preferredHeight: 20 }

            Text {
                Layout.leftMargin: 20
                text: "PANEL ROUNDING"
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
                height:             ThemeWidgets.settingItem.height
                radius:             ThemeWidgets.settingItem.radius
                color:              ThemeSettings.sectionBg
                border.width:       1
                border.color:       ThemeSettings.borderColor

                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    spacing: 12

                    Text {
                        text:           "󰘇"
                        font.family:    ThemeGlobal.fontIcons
                        font.pixelSize: 18
                        color:          ThemeSettings.accentColor
                    }

                    Text {
                        text:           "Corner Radius"
                        font.pixelSize: ThemeWidgets.settingItem.labelFontSize
                        font.family:    ThemeGlobal.fontSans
                        font.weight:    Font.Medium
                        color:          ThemeSettings.textColor
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 28; height: 28; radius: 8
                        color: minusHover.hovered
                               ? Qt.rgba(ThemeSettings.textColor.r, ThemeSettings.textColor.g, ThemeSettings.textColor.b, 0.10)
                               : "transparent"
                        Behavior on color { ColorAnimation { duration: 80 } }

                        Text {
                            anchors.centerIn: parent
                            text:             "−"
                            font.pixelSize:   16
                            font.family:      ThemeGlobal.fontSans
                            color:            ThemePanels.panelRadius <= 0 ? ThemeSettings.hintColor : ThemeSettings.textColor
                        }
                        HoverHandler { id: minusHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            onTapped: if (ThemePanels.panelRadius > 0)
                                          ThemeService.setPanelRadius(ThemePanels.panelRadius - 1)
                        }
                    }

                    Text {
                        text:                ThemePanels.panelRadius + "px"
                        font.pixelSize:      13
                        font.family:         ThemeGlobal.fontMono
                        color:               ThemeSettings.accentColor
                        Layout.preferredWidth: 40
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        width: 28; height: 28; radius: 8
                        color: plusHover.hovered
                               ? Qt.rgba(ThemeSettings.textColor.r, ThemeSettings.textColor.g, ThemeSettings.textColor.b, 0.10)
                               : "transparent"
                        Behavior on color { ColorAnimation { duration: 80 } }

                        Text {
                            anchors.centerIn: parent
                            text:             "+"
                            font.pixelSize:   16
                            font.family:      ThemeGlobal.fontSans
                            color:            ThemePanels.panelRadius >= root.maxPanelRadius ? ThemeSettings.hintColor : ThemeSettings.textColor
                        }
                        HoverHandler { id: plusHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            onTapped: if (ThemePanels.panelRadius < root.maxPanelRadius)
                                          ThemeService.setPanelRadius(ThemePanels.panelRadius + 1)
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 24 }

            Text {
                Layout.leftMargin: 20
                text: "FONT"
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
                height:             ThemeWidgets.settingItem.height
                radius:             ThemeWidgets.settingItem.radius
                color:              ThemeSettings.sectionBg
                border.width:       1
                border.color:       customInput.activeFocus ? ThemeSettings.accentColor : ThemeSettings.borderColor
                Behavior on border.color { ColorAnimation { duration: 100 } }

                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    spacing: 12

                    Text {
                        text:           ""
                        font.family:    ThemeGlobal.fontIcons
                        font.pixelSize: 18
                        color:          ThemeSettings.accentColor
                    }

                    Text {
                        text:           "Font Style"
                        font.pixelSize: ThemeWidgets.settingItem.labelFontSize
                        font.family:    ThemeGlobal.fontSans
                        font.weight:    Font.Medium
                        color:          ThemeSettings.textColor
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width:  160
                        height: 26
                        radius: 6
                        color:  Qt.rgba(ThemeSettings.textColor.r, ThemeSettings.textColor.g, ThemeSettings.textColor.b, 0.07)

                        TextInput {
                            id:             customInput
                            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                            text:              ThemeGlobal.fontSans
                            font.pixelSize:    13
                            font.family:       ThemeGlobal.fontMono
                            color:             ThemeSettings.accentColor
                            selectionColor:    Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.3)
                            verticalAlignment: TextInput.AlignVCenter
                            focus:             false
                            activeFocusOnTab:  false
                            onAccepted:        { ThemeService.setFont(text); focus = false }

                            HoverHandler { cursorShape: Qt.IBeamCursor }
                            TapHandler   { onTapped: customInput.forceActiveFocus() }

                            Text {
                                anchors.fill:      parent
                                visible:           !parent.text
                                text:              "font name…"
                                font:              parent.font
                                color:             ThemeSettings.hintColor
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 24 }

            Text {
                Layout.leftMargin: 20
                text: "COLOR PALETTE"
                font.pixelSize: ThemeWidgets.sectionLabel.fontSize
                font.weight:    Font.Medium
                font.family:    ThemeGlobal.fontSans
                color:          ThemeSettings.subColor
                leftPadding:    4
            }

            Item { Layout.preferredHeight: 8 }

            Repeater {
                model: ThemeService.palettes

                delegate: Rectangle {
                    required property var  modelData
                    required property int  index
                    readonly property bool active: ThemeService.currentPalette === modelData.id

                    Layout.leftMargin:   20
                    Layout.rightMargin:  20
                    Layout.fillWidth:    true
                    Layout.bottomMargin: index < ThemeService.palettes.length - 1 ? 6 : 0

                    height:       60
                    radius:       ThemeWidgets.settingItem.radius
                    color:        active
                                  ? Qt.rgba(ThemeSettings.accentColor.r, ThemeSettings.accentColor.g, ThemeSettings.accentColor.b, 0.10)
                                  : palHover.hovered
                                    ? Qt.rgba(ThemeSettings.textColor.r, ThemeSettings.textColor.g, ThemeSettings.textColor.b, 0.07)
                                    : ThemeSettings.sectionBg
                    border.width: 1
                    border.color: active ? ThemeSettings.accentColor : ThemeSettings.borderColor

                    RowLayout {
                        anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                        spacing: 14

                        Row {
                            spacing: 5
                            Repeater {
                                model: modelData.preview
                                delegate: Rectangle {
                                    required property string modelData
                                    width: 16; height: 16; radius: 8
                                    color: modelData
                                }
                            }
                        }

                        Text {
                            text:             modelData.name
                            font.pixelSize:   ThemeWidgets.settingItem.labelFontSize
                            font.family:      ThemeGlobal.fontSans
                            font.weight:      active ? Font.Medium : Font.Normal
                            color:            active ? ThemeSettings.accentColor : ThemeSettings.textColor
                            Layout.fillWidth: true
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        Text {
                            visible:        active
                            text:           "󰄬"
                            font.family:    ThemeGlobal.fontIcons
                            font.pixelSize: 14
                            color:          ThemeSettings.accentColor
                        }
                    }

                    HoverHandler { id: palHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler   { onTapped: ThemeService.setPalette(modelData.id) }
                }
            }

            Item { Layout.preferredHeight: 20 }
        }
    }
}
