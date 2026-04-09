import QtQuick
import Quickshell
import Quickshell.Wayland
import "../widgets"
import "../themes"

PanelWindow {

    // --- Funktion ---

    id: root

    required property var panelState

    readonly property int peekWidth:    ThemePanels.rightTop.peekWidth
    readonly property int boxWidth:     ThemePanels.rightTop.width
    readonly property int boxHeight:    ThemePanels.rightTop.height
    
    readonly property int openX:        Screen.width - boxWidth - ThemePanels.rightMargin
    readonly property int closedX:      Screen.width - peekWidth
    readonly property int bottomMargin: ThemePanels.rightTop.bottomMargin

    implicitWidth:  Screen.width
    implicitHeight: Screen.height
    color: "transparent"

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1

    anchors { top: true; bottom: true; right: true }

    mask: panelState.right1Open ? openMask : peekMask

    Region {
        id: openMask
        regions: [
            Region { x: root.openX;   y: panel.y; width: root.boxWidth;  height: root.boxHeight },
            Region { x: root.closedX; y: panel.y; width: root.peekWidth; height: root.boxHeight }
        ]
    }

    Region { id: peekMask
        regions: [ Region { x: root.closedX; y: panel.y; width: root.peekWidth; height: root.boxHeight } ]
    }

    // --- Design ---

    Rectangle {
        id: panel
        property bool initialized: false
        Component.onCompleted: initialized = true

        width:  root.boxWidth
        height: root.boxHeight
        anchors { bottom: parent.bottom; bottomMargin: root.bottomMargin }
        x:      panelState.right1Open ? root.openX : root.closedX
        radius: ThemePanels.rightTop.radius
        color:  ThemePanels.rightTop.color

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => mouse.accepted = true
        }

        NotifyWidget {
            anchors.fill: parent
            panelState:   root.panelState
        }

        Behavior on x {
            enabled: panel.initialized
            NumberAnimation {
                duration:         ThemePanels.rightTop.animDuration
                easing.type:      Easing.OutBack
                easing.overshoot: ThemePanels.rightTop.animOvershoot
            }
        }
    }

    Item {
        x: root.closedX; y: panel.y
        width: root.peekWidth; height: root.boxHeight
        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            onClicked: panelState.right1Open = !panelState.right1Open
        }
    }
}
