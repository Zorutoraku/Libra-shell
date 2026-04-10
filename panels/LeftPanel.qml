import QtQuick
import Quickshell
import Quickshell.Wayland
import "../widgets"
import "../themes"

PanelWindow {

    // --- Funktion ---

    id: root

    required property var panelState

    readonly property int peekWidth: ThemePanels.leftPanel.peekWidth
    readonly property int boxWidth:  ThemePanels.leftPanel.width
    readonly property int boxHeight: ThemePanels.leftPanel.height
    readonly property int openX:     ThemePanels.leftPanel.openX
    readonly property int closedX:   -(boxWidth - peekWidth) // slides left, only peekWidth strip remains visible

    implicitWidth:  Screen.width
    implicitHeight: Screen.height
    color: "transparent"

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors { top: true; bottom: true; left: true }

    mask: panelState.leftOpen ? openMask : peekMask

    Region {
        id: openMask
        regions: [
            Region { x: root.openX; y: panel.y; width: root.boxWidth;  height: root.boxHeight },
            Region { x: 0;          y: panel.y; width: root.peekWidth; height: root.boxHeight }
        ]
    }
    Region {
        id: peekMask
        regions: [ Region { x: 0; y: panel.y; width: root.peekWidth; height: root.boxHeight } ]
    }

    // --- Design ---

    Rectangle {
        id: panel

        property bool initialized: false
        Component.onCompleted: initialized = true

        width:  root.boxWidth
        height: root.boxHeight
        anchors.verticalCenter: parent.verticalCenter
        x:      panelState.leftOpen ? root.openX : root.closedX
        radius: ThemePanels.leftPanel.radius
        color:  ThemePanels.leftPanel.color

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => mouse.accepted = true
        }

        Behavior on x {
            enabled: panel.initialized
            NumberAnimation {
                duration:         ThemePanels.leftPanel.animDuration
                easing.type:      Easing.OutBack
                easing.overshoot: ThemePanels.leftPanel.animOvershoot
            }
        }

        Item {
            id: carousel

            anchors {
                left: parent.left; right: parent.right
                top: parent.top; bottom: dots.top
                margins: 20; bottomMargin: 8
            }
            clip: true

            readonly property int total:   3
            property int  current:  1
            property real dragX:    0
            property bool settling: false
            property int  _target:  0
            property bool musicSeeking: false

            function wrap(i) { return ((i % total) + total) % total }

            NumberAnimation {
                id: snapAnim
                target: carousel; property: "dragX"
                duration: 220; easing.type: Easing.OutCubic
                onStopped: {
                    carousel.current  = carousel._target
                    carousel.dragX    = 0
                    carousel.settling = false
                }
            }

            function snap(dir) {
                settling = true
                _target  = wrap(current + dir)
                snapAnim.to = -dir * carousel.width
                snapAnim.start()
            }

            readonly property var _sources: [
                musicComp,
                systemInfoComp,
                wetterComp
            ]

            Component {
                id: musicComp
                MusicWidget {}
            }
            Component {
                id: systemInfoComp
                SystemInfo {}
            }
            Component {
                id: wetterComp
                CalendarWidget {}
            }

            component CarouselSlot: Item {
                id: slotRoot
                required property int  wIdx
                required property real slotX
                required property bool isCenter

                width: carousel.width; height: carousel.height
                x:     slotX
                layer.enabled: snapAnim.running // GPU layer only during animation, saves memory at rest

                Loader {
                    id: slotLoader
                    anchors.fill:    parent
                    sourceComponent: carousel._sources[wIdx]
                }

                Binding {
                    target:   carousel
                    property: "musicSeeking"
                    value:    (slotRoot.isCenter
                               && slotLoader.status === Loader.Ready
                               && slotLoader.item)
                              ? slotLoader.item.isSeeking
                              : false
                    when: slotRoot.isCenter
                    restoreMode: Binding.RestoreNone
                }
            }

            CarouselSlot {
                wIdx:     carousel.wrap(carousel.current - 1)
                slotX:    -carousel.width + carousel.dragX
                isCenter: false
            }
            CarouselSlot {
                id:       centerSlot
                wIdx:     carousel.current
                slotX:    carousel.dragX
                isCenter: true
                
                onWIdxChanged: if (wIdx !== undefined && wIdx !== 0) carousel.musicSeeking = false
            }
            CarouselSlot {
                wIdx:     carousel.wrap(carousel.current + 1)
                slotX:    carousel.width + carousel.dragX
                isCenter: false
            }

            DragHandler {
                target:        null  // manual dragX tracking; don't let QML move the item automatically
                xAxis.enabled: true
                yAxis.enabled: false
                enabled:       !carousel.musicSeeking // disabled while scrubbing music progress bar
                onTranslationChanged: { if (!carousel.settling) carousel.dragX = translation.x }
                onActiveChanged: {
                    if (!active && !carousel.settling) {
                    if      (carousel.dragX < -50) carousel.snap(+1) // 50px threshold to commit swipe
                        else if (carousel.dragX >  50) carousel.snap(-1)
                        else { snapAnim.to = 0; snapAnim.start() }
                    }
                }
            }
        }

        Row {
            id: dots
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: ThemePanels.carouselDots.bottomMargin }
            spacing: ThemePanels.carouselDots.spacing
            Repeater {
                model: carousel.total
                Rectangle {
                    readonly property bool active: carousel.current === index
                    width:  active ? ThemePanels.carouselDots.activeWidth : ThemePanels.carouselDots.inactiveWidth
                    height: ThemePanels.carouselDots.height
                    radius: ThemePanels.carouselDots.radius
                    color:  active ? ThemePanels.carouselDots.activeColor : ThemePanels.carouselDots.inactiveColor
                    Behavior on width { NumberAnimation { duration: ThemePanels.carouselDots.animDuration } }
                    Behavior on color { ColorAnimation  { duration: ThemePanels.carouselDots.animDuration } }
                }
            }
        }
    }

    Item {
        x: 0; y: panel.y
        width: root.peekWidth; height: root.boxHeight
        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked:    panelState.leftOpen = !panelState.leftOpen
        }
    }
}
