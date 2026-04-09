pragma Singleton
import QtQuick
import "."

QtObject {

    readonly property QtObject clock: QtObject {
        readonly property color color:     ThemeService.textMain
        readonly property int   fontSize:  14
    }

    readonly property QtObject systemInfo: QtObject {
        readonly property color logoColor:     ThemeService.accentPrimary
        readonly property color accentColor:   ThemeService.accentInfo
        readonly property color sepColor:      ThemeService.textMuted
        readonly property color textColor:     ThemeService.textMain
        readonly property int   iconWidth:     22
        readonly property int   labelWidth:    44
        readonly property int   rowSpacing:    5
        readonly property int   logoTopMargin: 16
        readonly property int   fontSize:      12
        readonly property int   logoSize:      7
    }

    readonly property QtObject actionButton: QtObject {
        readonly property color bgColor:            ThemeService.backgroundFour
        readonly property color borderColor:        Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.07)
        readonly property color textColor:          ThemeService.textMain
        readonly property color hoverColor:         Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.07)
        readonly property color bgColorDanger:      Qt.rgba(ThemeService.accentDanger.r, ThemeService.accentDanger.g, ThemeService.accentDanger.b, 0.18)
        readonly property color borderColorDanger:  Qt.rgba(ThemeService.accentDanger.r, ThemeService.accentDanger.g, ThemeService.accentDanger.b, 0.55)
        readonly property color textColorDanger:    ThemeService.accentDanger
        readonly property color bgColorWarning:     Qt.rgba(ThemeService.accentPrimary.r, ThemeService.accentPrimary.g, ThemeService.accentPrimary.b, 0.18)
        readonly property color borderColorWarning: Qt.rgba(ThemeService.accentPrimary.r, ThemeService.accentPrimary.g, ThemeService.accentPrimary.b, 0.55)
        readonly property color textColorWarning:   ThemeService.accentPrimary
        readonly property int   height:             40
        readonly property int   radius:             10
        readonly property int   iconSize:           16
        readonly property int   fontSize:           13
    }

    readonly property QtObject powerSettings: QtObject {
        readonly property color bgColor:     Qt.rgba(ThemeService.accentSuccess.r, ThemeService.accentSuccess.g, ThemeService.accentSuccess.b, 0.18)
        readonly property color borderColor: Qt.rgba(ThemeService.accentSuccess.r, ThemeService.accentSuccess.g, ThemeService.accentSuccess.b, 0.55)
        readonly property color textColor:   ThemeService.accentSuccess
        readonly property color hoverColor:  Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.07)
        readonly property int   radius:      10
        readonly property int   fontSize:    13
    }

    readonly property QtObject toggleButton: QtObject {
        readonly property color bgColor:           ThemeService.backgroundFour
        readonly property color bgColorActive:     ThemeService.accentPrimary
        readonly property color borderColor:       Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.07)
        readonly property color borderColorActive: ThemeService.accentPrimary
        readonly property color textColor:         ThemeService.textMain
        readonly property color textColorActive:   ThemeService.backgroundOne
        readonly property color subColor:          ThemeService.textMuted
        readonly property color subColorActive:    ThemeService.backgroundTwo
        readonly property color hoverColor:        Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.07)
        readonly property int   radius:            14
        readonly property int   height:            60
        readonly property int   iconSize:          20
        readonly property int   fontSize:          13
        readonly property int   subFontSize:       11
    }

    readonly property QtObject slider: QtObject {
        readonly property color bgColor:     ThemeService.backgroundFour
        readonly property color borderColor: Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.07)
        readonly property color trackColor:  ThemeService.backgroundOne
        readonly property color thumbColor:  ThemeService.textMain
        readonly property color textColor:   ThemeService.textMain
        readonly property color valueColor:  ThemeService.textMuted
        readonly property int   height:      52
        readonly property int   radius:      12
        readonly property int   fontSize:    13
        readonly property int   iconSize:    16
        readonly property int   labelWidth:  70
        readonly property int   valueWidth:  30
        readonly property int   trackHeight: 4
        readonly property int   thumbSize:   16
    }

    readonly property QtObject volumeSlider: QtObject {
        readonly property color fillColor: ThemeService.accentPrimary
    }

    readonly property QtObject brightnessSlider: QtObject {
        readonly property color fillColor: ThemeService.accentInfo
    }

    readonly property QtObject powerMode: QtObject {
        readonly property color bgColor:           Qt.rgba(ThemeService.accentSuccess.r, ThemeService.accentSuccess.g, ThemeService.accentSuccess.b, 0.10)
        readonly property color borderColor:       Qt.rgba(ThemeService.accentSuccess.r, ThemeService.accentSuccess.g, ThemeService.accentSuccess.b, 0.40)
        readonly property int   radius:            10
        readonly property int   innerMargin:       3
        readonly property int   animDuration:      180
        readonly property color activeSegColor:    Qt.rgba(ThemeService.accentSuccess.r, ThemeService.accentSuccess.g, ThemeService.accentSuccess.b, 0.25)
        readonly property color activeBorderColor: ThemeService.accentSuccess
        readonly property color activeTextColor:   ThemeService.accentSuccess
        readonly property color inactiveSegColor:  "transparent"
        readonly property color inactiveTextColor: Qt.rgba(ThemeService.accentSuccess.r, ThemeService.accentSuccess.g, ThemeService.accentSuccess.b, 0.45)
        readonly property color hoverColor:        Qt.rgba(ThemeService.accentSuccess.r, ThemeService.accentSuccess.g, ThemeService.accentSuccess.b, 0.10)
        readonly property int   segmentRadius:     7
        readonly property int   segmentSpacing:    3
        readonly property int   fontSize:          11
    }

    readonly property QtObject music: QtObject {
        readonly property color coverBg:            ThemeService.backgroundTwo
        readonly property color coverFallbackColor: ThemeService.textSub
        readonly property color controlColor:       ThemeService.textMain
        readonly property color controlHover:       ThemeService.accentPrimary
        readonly property color noMediaColor:       ThemeService.textMuted
        readonly property color progressTrack:      ThemeService.backgroundFour
        readonly property color progressFill:       ThemeService.accentPrimary
        readonly property int   coverRadius:        12
        readonly property int   coverIconSize:      48
        readonly property int   controlSize:        24
        readonly property int   titleSize:          13
        readonly property int   artistSize:         11
        readonly property int   progressHeight:     4
        readonly property int   thumbSize:          12
        readonly property int   timeSize:           10
        readonly property int   spacing:            10
    }

    readonly property QtObject notify: QtObject {
        readonly property color headerColor:     ThemeService.textMain
        readonly property int   headerFontSize:  14
        readonly property color countBgColor:    ThemeService.backgroundFour
        readonly property color countBorder:     Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.12)
        readonly property color countTextColor:  ThemeService.textMuted
        readonly property int   countSize:       20
        readonly property int   countFontSize:   10
        readonly property color clearHoverBg:    Qt.rgba(ThemeService.accentDanger.r, ThemeService.accentDanger.g, ThemeService.accentDanger.b, 0.15)
        readonly property color clearHoverText:  ThemeService.accentDanger
        readonly property color clearColor:      ThemeService.textMuted
        readonly property color closeNormalColor: ThemeService.textMuted
        readonly property color closeHoverColor:  ThemeService.accentDanger
        readonly property int   clearSize:       28
        readonly property int   clearRadius:     8
        readonly property int   clearIconSize:   14
        readonly property int   closeIconSize:   9
        readonly property color separatorColor:  Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.08)
        readonly property color emptyIconColor:  ThemeService.textHint
        readonly property color emptyTextColor:  ThemeService.textHint
        readonly property int   emptyIconSize:   32
        readonly property int   emptyTextSize:   11
        readonly property color cardBg:          ThemeService.backgroundFour
        readonly property color cardBorder:      Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.07)
        readonly property color cardSummary:     ThemeService.textMain
        readonly property color cardBody:        ThemeService.textSub
        readonly property color cardAppName:     ThemeService.textMuted
        readonly property color cardTime:        ThemeService.textHint
        readonly property int   cardRadius:      10
        readonly property int   cardPadding:     12
        readonly property int   cardSpacing:     6
        readonly property int   summarySize:     12
        readonly property int   bodySize:        11
        readonly property int   appNameSize:     10
        readonly property int   timeSize:        10
        readonly property color actionBg:        Qt.rgba(ThemeService.accentPrimary.r, ThemeService.accentPrimary.g, ThemeService.accentPrimary.b, 0.12)
        readonly property color actionBorder:    Qt.rgba(ThemeService.accentPrimary.r, ThemeService.accentPrimary.g, ThemeService.accentPrimary.b, 0.30)
        readonly property color actionText:      ThemeService.accentPrimary
        readonly property int   maxListHeight:   300
        readonly property int   animDuration:    200
        readonly property color scrollbarColor:  Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.35)
    }

    readonly property QtObject calendar: QtObject {
        readonly property color textColor:       ThemeService.textMain
        readonly property color mutedColor:      ThemeService.textMuted
        readonly property color accentColor:     ThemeService.accentPrimary
        readonly property color weekendColor:    ThemeService.accentDanger
        readonly property color infoColor:       ThemeService.accentInfo
        readonly property color successColor:    ThemeService.accentSuccess
        readonly property color cardBg:          ThemeService.backgroundFour
        readonly property color cardBorder:      Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.07)
        readonly property color hoverOverlay:    Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.07)
        readonly property color todayTextColor:  ThemeService.backgroundOne
        readonly property int   spacing:         8
        readonly property int   padding:         12
        readonly property int   headerFontSize:  13
        readonly property int   labelFontSize:   10
        readonly property int   dayFontSize:     11
        readonly property int   noteFontSize:    12
        readonly property int   dayRadius:       7
        readonly property int   navBtnSize:      30
        readonly property int   navBtnRadius:    8
        readonly property int   noteRadius:      10
        readonly property int   notePadding:     10
    }

    readonly property QtObject sectionLabel: QtObject {
        readonly property int fontSize: 11
    }

    readonly property QtObject settingItem: QtObject {
        readonly property int radius:           12
        readonly property int height:           64
        readonly property int iconBoxSize:      40
        readonly property int iconBoxRadius:    10
        readonly property int iconSize:         20
        readonly property int labelFontSize:    13
        readonly property int sublabelFontSize: 11
        readonly property int innerSpacing:     14
        readonly property int rightSpacing:     8
        readonly property int columnSpacing:    2
    }
}
