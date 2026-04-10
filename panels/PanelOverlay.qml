import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {

    // --- Funktion ---

    id: root

    required property var panelState

    implicitWidth:  Screen.width
    implicitHeight: Screen.height
    color: "transparent"

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1

    anchors { top: true; bottom: true; left: true; right: true }

    // full-screen transparent click-catcher
    mask: panelState.anyOpen ? fullMask : emptyMask

    Region {
        id: fullMask
        regions: [ Region { x: 0; y: 0; width: root.width; height: root.height } ]
    }

    Region { id: emptyMask }

    // --- Design ---

    MouseArea {
        anchors.fill: parent
        enabled: panelState.anyOpen
        onClicked: panelState.closeAll()
    }
}
