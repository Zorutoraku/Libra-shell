pragma Singleton
import QtQuick
import "."

QtObject {

    // --- Funktion ---

    readonly property color bgColor:          ThemeService.backgroundTwo
    readonly property color headerBg:         ThemeService.backgroundThree
    readonly property color sectionBg:        ThemeService.backgroundThree
    readonly property color borderColor:      Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.07)
    readonly property color separatorColor:   Qt.rgba(ThemeService.textMain.r, ThemeService.textMain.g, ThemeService.textMain.b, 0.05)
    readonly property color accentColor:      ThemeService.accentPrimary
    readonly property color textColor:        ThemeService.textMain
    readonly property color subColor:         ThemeService.textMuted
    readonly property color hintColor:        ThemeService.textHint
    readonly property color closeHoverColor:  ThemeService.accentDanger
    readonly property color navActiveColor:   ThemeService.accentPrimary
    readonly property color navInactiveColor: ThemeService.textHint
    readonly property color overlayColor:     Qt.rgba(0, 0, 0, 0.5)
    readonly property int   windowWidth:      640
    readonly property int   windowHeight:     520
    readonly property int   radius:           20
    readonly property int   headerHeight:     58
    readonly property int   navWidth:         160
    readonly property int   animDuration:     280
}
