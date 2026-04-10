import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import "../themes"
import "../widgets"   

Item {

    // --- Funktion ---

    id: root

    property string homePath: ""

    Process {
        command: ["sh", "-c", "echo $HOME"]
        running: true
        stdout: SplitParser { onRead: line => root.homePath = line.trim() }
    }

    // --- Design ---

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
                text: "PROFILE"
                font.pixelSize: ThemeWidgets.sectionLabel.fontSize
                font.weight:    Font.Medium
                font.family:    ThemeGlobal.fontSans
                color:          ThemeSettings.subColor
                leftPadding:    4
            }

            Item { Layout.preferredHeight: 8 }

            RowLayout {
                Layout.leftMargin:  20
                Layout.rightMargin: 20
                Layout.fillWidth:   true
                spacing:            12

                Item {
                    Layout.preferredWidth:  (root.width - 52) / 2
                    Layout.preferredHeight: (root.width - 52) / 2

                    Rectangle {
                        id:            avatarMask
                        anchors.fill:  parent
                        radius:        width / 2
                        color:         "white"
                        visible:       false
                        layer.enabled: true
                    }

                    Image {
                        id:            faceImg
                        anchors.fill:  parent
                        source:        root.homePath ? ("file://" + root.homePath + "/.face") : "" // standard avatar path
                        fillMode:      Image.PreserveAspectCrop
                        smooth:        true
                        visible:       false
                        layer.enabled: true
                    }

                    // MultiEffect+mask = circular crop
                    MultiEffect {
                        anchors.fill:     parent
                        source:           faceImg
                        maskEnabled:      true
                        maskSource:       avatarMask
                        maskThresholdMin: 0.5
                        maskSpreadAtMin:  1.0
                        visible:          faceImg.status === Image.Ready
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius:       width / 2
                        color:        ThemeSettings.sectionBg
                        visible:      faceImg.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text:             "󰀄"
                            font.family:      ThemeGlobal.fontIcons
                            font.pixelSize:   48
                            color:            ThemeSettings.subColor
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius:       width / 2
                        color:        "transparent"
                        border.width: 1
                        border.color: ThemeSettings.borderColor
                    }
                }

                Item {
                    Layout.fillWidth:       true
                    Layout.preferredHeight: (root.width - 52) / 2

                    Column {
                        anchors.centerIn: parent
                        spacing:          6

                        Text {
                            width:               parent.parent.width - 16
                            text:                "\"Decide now, coward\""
                            font.pixelSize:      14
                            font.family:         ThemeGlobal.fontSans
                            font.italic:         true
                            color:               ThemeSettings.subColor
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode:            Text.WordWrap
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:                "~ Libra"
                            font.pixelSize:      11
                            font.family:         ThemeGlobal.fontSans
                            color:               ThemeSettings.hintColor
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 20 }
        }
    }
}
