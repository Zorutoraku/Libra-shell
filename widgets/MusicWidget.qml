import QtQuick
import QtQuick.Layouts
import "../services"
import "../themes"

Item {

    // --- Funktion ---

    id: root

    readonly property var  t:   ThemeWidgets.music
    readonly property bool has: MprisService.hasPlayer
    readonly property bool isSeeking: progressBar.seeking

    property real displayPosition: 0
    property bool _snapping: false

    Behavior on displayPosition {
        enabled: MprisService.isPlaying && !progressBar.seeking && !progressBar.cooldown && !root._snapping
        NumberAnimation { duration: 1100; easing.type: Easing.Linear }
    }

    Connections {
        target: MprisService
        function onPositionChanged() {
            if (Math.abs(root.displayPosition - MprisService.position) > 2) {
                root._snapping = true;
                root.displayPosition = MprisService.position;
                Qt.callLater(function() { root._snapping = false; });
            } else {
                root.displayPosition = MprisService.position;
            }
        }
    }

    function fmt(s) {
        const m  = Math.floor(s / 60);
        const ss = Math.floor(s % 60);
        return m + ":" + (ss < 10 ? "0" : "") + ss;
    }

    // --- Design ---

    ColumnLayout {
        anchors.fill: parent
        spacing: root.t.spacing

        Rectangle {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            radius: root.t.coverRadius
            color:  root.t.coverBg
            clip:   true

            Image {
                id: coverImage
                anchors.fill: parent
                source:       MprisService.artUrl
                fillMode:     Image.PreserveAspectCrop
                asynchronous: true

                opacity:      (status === Image.Ready && source !== "") ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 300 } }
            }

            Text {
                anchors.centerIn: parent

                visible:          !root.has
                                  || MprisService.artUrl === ""
                                  || coverImage.status === Image.Error
                                  || coverImage.status === Image.Null
                text:             "󰎈"
                font.family:      ThemeGlobal.fontIcons
                font.pixelSize:   root.t.coverIconSize
                color:            root.t.noMediaColor
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height:  50
                visible: root.has
                color:   Qt.rgba(0, 0, 0, 0.55)

                ColumnLayout {
                    anchors { fill: parent; margins: 8 }
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        text:             MprisService.title || "No Media"
                        color:            "white"
                        font.pixelSize:   root.t.titleSize
                        font.family:      ThemeGlobal.fontSans
                        font.bold:        true
                        elide:            Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text:             MprisService.artist || ""
                        color:            root.t.coverFallbackColor
                        font.pixelSize:   root.t.artistSize
                        font.family:      ThemeGlobal.fontSans
                        elide:            Text.ElideRight
                        visible:          text !== ""
                    }
                }
            }
        }

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 24

            Rectangle {
                width: 40; height: 40; radius: 20
                color: prevArea.containsMouse ? Qt.rgba(1,1,1,0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text:             "󰒮"
                    font.family:      ThemeGlobal.fontIcons
                    font.pixelSize:   root.t.controlSize
                    color:            prevArea.containsMouse ? root.t.controlHover : root.t.controlColor
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                MouseArea {
                    id:           prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    enabled:      root.has
                    onClicked:    MprisService.previous()
                }
            }

            Rectangle {
                width: 40; height: 40; radius: 20
                color: ppArea.containsMouse ? Qt.rgba(1,1,1,0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text:             MprisService.isPlaying ? "󰏤" : "󰐊"
                    font.family:      ThemeGlobal.fontIcons
                    font.pixelSize:   root.t.controlSize + 4
                    color:            ppArea.containsMouse ? root.t.controlHover : root.t.controlColor
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                MouseArea {
                    id:           ppArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    enabled:      root.has
                    onClicked:    MprisService.playPause()
                }
            }

            Rectangle {
                width: 40; height: 40; radius: 20
                color: nextArea.containsMouse ? Qt.rgba(1,1,1,0.12) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text:             "󰒭"
                    font.family:      ThemeGlobal.fontIcons
                    font.pixelSize:   root.t.controlSize
                    color:            nextArea.containsMouse ? root.t.controlHover : root.t.controlColor
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                MouseArea {
                    id:           nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    enabled:      root.has
                    onClicked:    MprisService.next()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                text:           root.fmt(progressBar.seeking || progressBar.cooldown ? progressBar.seekValue : root.displayPosition)
                color:          root.t.controlColor
                font.pixelSize: root.t.timeSize
                font.family:    ThemeGlobal.fontMono
            }

            Item {
                id: progressBar
                property bool seeking:   false
                property bool cooldown:  false
                property real seekValue: 0

                function seekTo(mx) {
                    seekValue = Math.max(0, Math.min(mx / width, 1)) * MprisService.length
                }

                Layout.fillWidth:       true
                Layout.preferredHeight: 20

                Binding {
                    target: progressBar; property: "seekValue"
                    value: root.displayPosition
                    when: !progressBar.seeking && !progressBar.cooldown
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width; height: root.t.progressHeight
                    radius: root.t.progressHeight / 2; color: root.t.progressTrack

                    Rectangle {
                        width: {
                            const len = MprisService.length > 0 ? MprisService.length : 1;
                            const pos = (progressBar.seeking || progressBar.cooldown) ? progressBar.seekValue : root.displayPosition;
                            return Math.max(0, Math.min((pos / len) * parent.width, parent.width));
                        }
                        height: parent.height; radius: parent.radius; color: root.t.progressFill
                    }
                }

                Rectangle {
                    x: {
                        const len = MprisService.length > 0 ? MprisService.length : 1;
                        const pos = (progressBar.seeking || progressBar.cooldown) ? progressBar.seekValue : root.displayPosition;
                        return Math.max(0, Math.min((pos / len) * (parent.width - width), parent.width - width));
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.t.thumbSize; height: root.t.thumbSize
                    radius: root.t.thumbSize / 2; color: root.t.progressFill
                }

                Timer {
                    id: cooldownTimer; interval: 1000
                    onTriggered: progressBar.cooldown = false
                }

                MouseArea {
                    anchors.fill:    parent
                    cursorShape:     Qt.PointingHandCursor
                    enabled:         root.has
                    onPressed:         (m) => { cooldownTimer.stop(); progressBar.cooldown = false; progressBar.seekTo(m.x); progressBar.seeking = true }
                    onPositionChanged: (m) => { if (progressBar.seeking) progressBar.seekTo(m.x) }
                    onReleased: {
                        if (progressBar.seeking) {
                            MprisService.setPosition(progressBar.seekValue)
                            progressBar.seeking = false; progressBar.cooldown = true
                            cooldownTimer.restart()
                        }
                    }
                }
            }

            Text {
                text:           root.fmt(MprisService.length)
                color:          root.t.controlColor
                font.pixelSize: root.t.timeSize
                font.family:    ThemeGlobal.fontMono
            }
        }
    }
}
