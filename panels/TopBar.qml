import QtQuick
import Quickshell
import Quickshell.Wayland
import "../widgets"
import "../themes"

PanelWindow {

    // --- Funktion ---

    id: root

    readonly property int   barHeight:  ThemePanels.topBar.height
    readonly property int   notchWidth: Screen.width / 10
    readonly property int   cornerSize: ThemePanels.topBar.cornerSize
    readonly property color barColor:   ThemePanels.topBar.color

    implicitWidth:  Screen.width
    implicitHeight: barHeight
    color: "transparent"

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1

    anchors { top: true; left: true; right: true }

    mask: Region {
        regions: [
            Region { x: notch.x;                   y: 0; width: root.notchWidth; height: root.barHeight },
            Region { x: notch.x - root.cornerSize; y: 0; width: root.cornerSize; height: root.cornerSize },
            Region { x: notch.x + root.notchWidth; y: 0; width: root.cornerSize; height: root.cornerSize }
        ]
    }

    // --- Design ---

    Rectangle {
        id: notch
        width:  root.notchWidth
        height: root.barHeight
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        radius: root.cornerSize
        color:  root.barColor
    }

    Rectangle {
        width:  root.notchWidth
        height: root.cornerSize
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        color: root.barColor
    }

    Clock {
        anchors.centerIn: notch
    }

    Canvas {
        x: notch.x - root.cornerSize
        y: 0
        width:  root.cornerSize
        height: root.cornerSize
        
        property color watchColor: root.barColor
        onWatchColorChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            const r   = root.cornerSize
            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()
            ctx.arc(0, r, r, -Math.PI / 2, 0)
            ctx.lineTo(r, 0)
            ctx.closePath()
            ctx.fillStyle = root.barColor
            ctx.fill()
        }
    }

    Canvas {
        x: notch.x + root.notchWidth
        y: 0
        width:  root.cornerSize
        height: root.cornerSize

        property color watchColor: root.barColor
        onWatchColorChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            const r   = root.cornerSize
            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()
            ctx.arc(r, r, r, Math.PI, -Math.PI / 2)
            ctx.lineTo(0, 0)
            ctx.closePath()
            ctx.fillStyle = root.barColor
            ctx.fill()
        }
    }
}
