pragma Singleton
import QtQuick
import "."

QtObject {

    // --- Funktion ---

    id: root

    property int panelRadius: 16

    readonly property int rightMargin: 20

    readonly property QtObject topBar: QtObject {
        readonly property color color:          ThemeService.backgroundOne
        readonly property int   height:         25
        readonly property int   cornerSize:     root.panelRadius
    }

    readonly property QtObject leftPanel: QtObject {
        readonly property color color:          ThemeService.backgroundTwo
        readonly property int   radius:         root.panelRadius
        readonly property int   width:          320
        readonly property int   height:         400
        readonly property int   peekWidth:      10
        readonly property int   openX:          20
        readonly property int   animDuration:   400
        readonly property real  animOvershoot:  0.8
    }

    readonly property QtObject carouselDots: QtObject {
        readonly property color activeColor:   ThemeService.accentPrimary
        readonly property color inactiveColor: ThemeService.textHint
        readonly property int   activeWidth:   14
        readonly property int   inactiveWidth: 7
        readonly property int   height:        7
        readonly property int   radius:        4
        readonly property int   spacing:       6
        readonly property int   bottomMargin:  10
        readonly property int   animDuration:  150
    }

    readonly property QtObject rightTop: QtObject {
        readonly property color color:          ThemeService.backgroundThree
        readonly property int   radius:         root.panelRadius
        readonly property int   width:          320
        readonly property int   height:         200
        readonly property int   peekWidth:      10
        readonly property int   bottomMargin:   root.rightBottom.height + root.rightBottom.bottomMargin + 12
        readonly property int   animDuration:   400
        readonly property real  animOvershoot:  0.8
    }

    readonly property QtObject rightBottom: QtObject {
        readonly property color color:          ThemeService.backgroundFour
        readonly property int   radius:         root.panelRadius
        readonly property int   width:          320
        readonly property int   height:         360
        readonly property int   peekWidth:      10
        readonly property int   bottomMargin:   20
        readonly property int   animDuration:   400
        readonly property real  animOvershoot:  0.8
    }
}
