import QtQuick
import QtQuick.Layouts
import "../themes"

Rectangle {

    // --- Funktion ---

    id: root

    property string label:       ""
    property string sublabel:    ""
    property string icon:        ""
    property bool   active:      false

    implicitHeight: ThemeWidgets.toggleButton.height
    radius:         ThemeWidgets.toggleButton.radius
    color:          active ? ThemeWidgets.toggleButton.bgColorActive   : ThemeWidgets.toggleButton.bgColor
    border.width:   1
    border.color:   active ? ThemeWidgets.toggleButton.borderColorActive : ThemeWidgets.toggleButton.borderColor

    Behavior on color       { ColorAnimation { duration: 150 } }
    Behavior on border.color{ ColorAnimation { duration: 150 } }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }

    // --- Design ---

    Rectangle {
        anchors.fill: parent
        radius:       parent.radius
        color:        hover.hovered ? ThemeWidgets.toggleButton.hoverColor : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    RowLayout {
        anchors { fill: parent; margins: 14 }
        spacing: 12

        Text {
            text:           root.icon
            font.family:    ThemeGlobal.fontIcons
            font.pixelSize: ThemeWidgets.toggleButton.iconSize
            color:          root.active ? ThemeWidgets.toggleButton.textColorActive : ThemeWidgets.toggleButton.textColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text:           root.label
                font.pixelSize: ThemeWidgets.toggleButton.fontSize
                font.family:    ThemeGlobal.fontSans
                font.weight:    Font.Medium
                color:          root.active ? ThemeWidgets.toggleButton.textColorActive : ThemeWidgets.toggleButton.textColor
                elide:          Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text:           root.sublabel
                font.pixelSize: ThemeWidgets.toggleButton.subFontSize
                font.family:    ThemeGlobal.fontSans
                color:          root.active ? ThemeWidgets.toggleButton.subColorActive : ThemeWidgets.toggleButton.subColor
                visible:        text !== ""
                elide:          Text.ElideRight
            }
        }

    }
}
