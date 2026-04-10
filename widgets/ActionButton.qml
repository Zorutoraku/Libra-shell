import QtQuick
import QtQuick.Layouts
import "../themes"

Rectangle {

    // --- Funktion ---

    id: root

    property string icon:    ""
    property string label:   ""
    property string variant: "normal"

    readonly property var _bgMap: ({
        "danger":  ThemeWidgets.actionButton.bgColorDanger,
        "warning": ThemeWidgets.actionButton.bgColorWarning
    })
    readonly property var _borderMap: ({
        "danger":  ThemeWidgets.actionButton.borderColorDanger,
        "warning": ThemeWidgets.actionButton.borderColorWarning
    })
    readonly property var _fgMap: ({
        "danger":  ThemeWidgets.actionButton.textColorDanger,
        "warning": ThemeWidgets.actionButton.textColorWarning
    })

    // ?? = fallback to "normal" style when variant is unknown
    readonly property color _bg:     _bgMap[variant]     ?? ThemeWidgets.actionButton.bgColor
    readonly property color _border: _borderMap[variant] ?? ThemeWidgets.actionButton.borderColor
    readonly property color _fg:     _fgMap[variant]     ?? ThemeWidgets.actionButton.textColor

    implicitHeight: ThemeWidgets.actionButton.height
    radius:         ThemeWidgets.actionButton.radius
    color:          _bg
    border.width:   1
    border.color:   _border

    HoverHandler { id: hover }

    // --- Design ---

    Rectangle {
        anchors.fill: parent
        radius:       parent.radius
        color:        hover.hovered ? ThemeWidgets.actionButton.hoverColor : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: root.label !== "" ? 6 : 0

        Text {
            text:           root.icon
            font.family:    ThemeGlobal.fontIcons
            font.pixelSize: ThemeWidgets.actionButton.iconSize
            color:          root._fg
        }

        Text {
            text:           root.label
            font.pixelSize: ThemeWidgets.actionButton.fontSize
            font.family:    ThemeGlobal.fontSans
            font.weight:    Font.Medium
            color:          root._fg
            visible:        root.label !== ""
        }
    }
}
