
import QtQuick
import QtQuick.Layouts
import "../themes"

Rectangle {

    // --- Funktion ---

    id: root

    property string icon:     ""
    property string label:    ""
    property string sublabel: ""
    default property alias content: rightSlot.data

    implicitHeight: ThemeWidgets.settingItem.height
    radius:         ThemeWidgets.settingItem.radius
    color:          ThemeSettings.sectionBg
    border.width:   1
    border.color:   ThemeSettings.borderColor

    // --- Design ---

    RowLayout {
        anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
        spacing: ThemeWidgets.settingItem.innerSpacing

        Rectangle {
            visible: root.icon !== ""
            width: ThemeWidgets.settingItem.iconBoxSize; height: ThemeWidgets.settingItem.iconBoxSize
            radius: ThemeWidgets.settingItem.iconBoxRadius
            color: Qt.rgba(ThemeSettings.accentColor.r,
                           ThemeSettings.accentColor.g,
                           ThemeSettings.accentColor.b, 0.12)
            Text {
                anchors.centerIn: parent
                text: root.icon; font.family: ThemeGlobal.fontIcons; font.pixelSize: ThemeWidgets.settingItem.iconSize
                color: ThemeSettings.accentColor
            }
        }

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: ThemeWidgets.settingItem.columnSpacing
            Text {
                text: root.label; font.pixelSize: ThemeWidgets.settingItem.labelFontSize; font.weight: Font.Medium
                font.family: ThemeGlobal.fontSans; color: ThemeSettings.textColor
                elide: Text.ElideRight; width: parent.width
            }
            Text {
                text: root.sublabel; font.pixelSize: ThemeWidgets.settingItem.sublabelFontSize; font.family: ThemeGlobal.fontSans
                color: ThemeSettings.subColor; visible: root.sublabel !== ""
                elide: Text.ElideRight; width: parent.width
            }
        }

        RowLayout { id: rightSlot; spacing: ThemeWidgets.settingItem.rightSpacing; Layout.alignment: Qt.AlignRight | Qt.AlignVCenter }
    }
}
