import QtQuick
import "../themes"
import "../services"

Item {

    // --- Funktion ---

    id: root

    readonly property string archLogo:
        "                    \n" +
        "                    \n" +
        "                     \n" +
        "                 .  \n" +
        "                `o  :\n" +
        "               `+o  o:\n" +
        "              `+oo  oo:\n" +
        "              -+oo  oo+:\n" +
        "            `/:-:+  ooo+:\n" +
        "           `/+++++  +++++:\n" +
        "          `/++++++  ++++++:\n" +
        "         `/+++oooo  ooooooo/`\n" +
        "        ./ooosssso  osssssso+`\n" +
        "       .oossssso-`  `/ossssss+`\n" +
        "      -osssssso.      :ssssssso.\n" +
        "     :osssssss/        osssso+++.\n" +
        "    /ossssssss/        +ssssooo/-\n" +
        "  `/ossssso+/:-        -:/+osssso+-\n" +
        " `+sso+:-`                 `.-/+oso:\n" +
        "`++:.                           `-/+/\n" +
        ".`                                 `/"

    readonly property string archLogoSword:
        "                  00\n" +
        "                  11\n" +
        "                 ====\n" +
        "                  //\n" +
        "                  // \n" +
        "                  //  \n" +
        "                  //   \n" +
        "                  //    \n" +
        "                  //     \n" +
        "                  //      \n" +
        "                  //       \n" +
        "                  //         \n" +
        "                  //          \n" +
        "                  //           \n" +
        "                  //            \n" +
        "                  //             \n" +
        "                  //             \n" +
        "                  //               \n" +
        "                  //                \n" +
        "                  //                 \n" +
        "                  /                  "


    readonly property var _infoRows: [
                    { icon: "󰣇", label: "os",     val: SystemInfoService.osVal,     accent: ThemeService.accentPrimary },
                    { icon: "󱩊", label: "host",   val: SystemInfoService.hostVal,   accent: ThemeService.accentInfo    },
                    { icon: "", label: "kernel", val: SystemInfoService.kernelVal, accent: ThemeService.accentSuccess },
                    { icon: "", label: "uptime", val: SystemInfoService.uptimeVal, accent: ThemeService.accentDanger  },
                    { icon: "", label: "shell",  val: SystemInfoService.shellVal,  accent: ThemeService.accentPrimary },
                    { icon: "", label: "wm",     val: SystemInfoService.wmVal,     accent: ThemeService.accentInfo    },
    ]

    // --- Design ---
    
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:   parent.verticalCenter
        width: parent.width
        spacing: ThemeWidgets.systemInfo.logoTopMargin

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width:  logoBase.width
            height: logoBase.height

            Text {
                id:             logoBase
                text:           root.archLogo
                font.family:    ThemeGlobal.fontMono
                font.pixelSize: ThemeWidgets.systemInfo.logoSize
                lineHeight:     1.2
                color:          ThemeService.accentPrimary
            }
            Text {
                text:           root.archLogoSword
                font.family:    ThemeGlobal.fontMono
                font.pixelSize: ThemeWidgets.systemInfo.logoSize
                lineHeight:     1.2
                color:          ThemeService.accentDanger
            }
        }

        Rectangle {
            width:   parent.width
            height:  1
            color:   ThemeWidgets.systemInfo.sepColor
            opacity: 0.25
        }

        Column {
            width: parent.width
            spacing: ThemeWidgets.systemInfo.rowSpacing

            Repeater {
                model: root._infoRows
                delegate: Row {
                    spacing: 0
                    width: parent.width

                    Text {
                        text:                modelData.icon
                        color:               modelData.accent
                        font.pixelSize:      ThemeWidgets.systemInfo.fontSize
                        font.family:         ThemeGlobal.fontMono
                        width:               ThemeWidgets.systemInfo.iconWidth
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text:           modelData.label + ":"
                        color:          modelData.accent
                        font.pixelSize: ThemeWidgets.systemInfo.fontSize
                        font.family:    ThemeGlobal.fontMono
                        font.bold:      true
                    }
                    Text {
                        text:           " " + modelData.val
                        color:          ThemeWidgets.systemInfo.textColor
                        font.pixelSize: ThemeWidgets.systemInfo.fontSize
                        font.family:    ThemeGlobal.fontMono
                        elide:          Text.ElideRight
                    }
                }
            }
        }

        Row {
            width:   parent.width
            spacing: 6

            Repeater {
                model: [
                    ThemeService.accentPrimary,
                    ThemeService.accentInfo,
                    ThemeService.accentSuccess,
                    ThemeService.accentDanger,
                ]
                Rectangle {
                    width:  (parent.width - 18) / 4
                    height: 6
                    radius: 2
                    color:  modelData
                }
            }
        }
    }
}
