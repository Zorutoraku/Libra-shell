import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../services"
import "../themes"

Rectangle {

    // --- Funktion ---

    id: root

    implicitHeight: ThemeWidgets.slider.height
    color:          ThemeWidgets.slider.bgColor
    radius:         ThemeWidgets.slider.radius
    border.width:   1
    border.color:   ThemeWidgets.slider.borderColor

    // --- Design ---

    RowLayout {
        anchors { fill: parent; margins: 12 }
        spacing: 12

        Text {
            text:           "󰃠"
            font.family:    ThemeGlobal.fontIcons
            font.pixelSize: ThemeWidgets.slider.iconSize
            color:          ThemeWidgets.slider.textColor
            Layout.preferredWidth: ThemeWidgets.slider.iconSize
        }

        Text {
            text:                  "Brightness"
            font.pixelSize:        ThemeWidgets.slider.fontSize
            font.family:           ThemeGlobal.fontSans
            color:                 ThemeWidgets.slider.textColor
            Layout.preferredWidth: ThemeWidgets.slider.labelWidth
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            from: 0; to: 1

            Binding on value {
                value:       BrightnessService.brightness
                when:        !slider.pressed && BrightnessService.ready
                restoreMode: Binding.RestoreNone
            }

            onMoved: BrightnessService.setBrightness(value)

            MouseArea {
                anchors.fill:    parent
                acceptedButtons: Qt.NoButton
                cursorShape:     Qt.PointingHandCursor
                onWheel: (w) => {
                    var next = slider.value + (w.angleDelta.y > 0 ? 0.05 : -0.05);
                    BrightnessService.setBrightness(Math.max(0, Math.min(1, next)));
                }
            }

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width:  slider.availableWidth
                height: ThemeWidgets.slider.trackHeight
                radius: ThemeWidgets.slider.trackHeight / 2
                color:  ThemeWidgets.slider.trackColor

                Rectangle {
                    width:  slider.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color:  ThemeWidgets.brightnessSlider.fillColor
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding  + slider.availableHeight / 2 - height / 2
                implicitWidth:  ThemeWidgets.slider.thumbSize
                implicitHeight: ThemeWidgets.slider.thumbSize
                radius:         ThemeWidgets.slider.thumbSize / 2
                color:          ThemeWidgets.slider.thumbColor
            }
        }

        Text {
            text:                  Math.round(slider.value * 100) + "%"
            font.pixelSize:        ThemeWidgets.slider.fontSize
            font.family:           ThemeGlobal.fontSans
            color:                 ThemeWidgets.slider.valueColor
            Layout.preferredWidth: ThemeWidgets.slider.valueWidth
            horizontalAlignment:   Text.AlignRight
        }
    }
}
