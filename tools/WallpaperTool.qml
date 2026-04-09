import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../themes"

PanelWindow {
    id: root

    required property var panelState

    implicitWidth:  Screen.width
    implicitHeight: Screen.height
    color:          "transparent"

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: panelState.wallpaperOpen
                                 ? WlrKeyboardFocus.Exclusive
                                 : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }

    mask: panelState.wallpaperOpen ? fullMask : emptyMask

    Region { id: emptyMask }
    Region {
        id: fullMask
        width:  root.implicitWidth
        height: root.implicitHeight
    }

    readonly property string wallDir:  Quickshell.env("HOME") + "/Pictures/Wallpapers"
    readonly property string thumbDir: Quickshell.env("HOME") + "/.cache/wallpaper-thumbs"

    ListModel { id: wallpapers }

    Process {
        id: thumbProc
        command: ["bash", "-c",
            "mkdir -p \"" + root.thumbDir + "\" && " +
            "ls -1 \"" + root.wallDir + "\" | grep -iE '\\.(jpg|jpeg|png)$' | while read f; do " +
            "  t=\"" + root.thumbDir + "/${f%.*}.jpg\"; " +
            "  [ -f \"$t\" ] || convert -thumbnail 640x360^ -gravity center -extent 640x360 -quality 85 " +
            "    \"" + root.wallDir + "/$f\" \"$t\"; " +
            "  echo \"$f\"; " +
            "done"
        ]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() !== "")
                    wallpapers.append({ filename: data.trim() })
            }
        }
    }

    Component.onDestruction: {
        if (thumbProc.running) thumbProc.running = false
    }

    Process {
        id: swwwProc
        running: false
    }

    function setWallpaper(filename) {
        swwwProc.command = ["swww", "img",
            "--transition-type",     "grow",
            "--transition-pos",      "center",
            "--transition-duration", "1.5",
            "--transition-fps",      "144",
            "--transition-bezier",   ".25,1,.25,1",
            root.wallDir + "/" + filename
        ]
        swwwProc.running = true
        panelState.wallpaperOpen = false
    }

    Connections {
        target: panelState
        function onWallpaperOpenChanged() {
            if (panelState.wallpaperOpen)
                carousel.forceActiveFocus()
        }
    }

    Rectangle {
        anchors.fill: parent
        color:        ThemeSettings.overlayColor
        opacity:      panelState.wallpaperOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked:    panelState.wallpaperOpen = false
            property real scrollAccum: 0
            onWheel: wheel => {
                scrollAccum += wheel.angleDelta.x + wheel.angleDelta.y
                if (scrollAccum > 120)       { carousel.prev(); scrollAccum = 0 }
                else if (scrollAccum < -120) { carousel.next(); scrollAccum = 0 }
            }
        }
    }

    Item {
        id: carousel

        readonly property int centerW: 320
        readonly property int centerH: 180
        readonly property int sideW:   256
        readonly property int sideH:   144
        readonly property int itemH:   180
        readonly property int spacing: 10
        readonly property int count:   wallpapers.count

        property int  currentIndex: 0
        property real scrollAccum:  0

        function prev() { currentIndex = (currentIndex - 1 + count) % count }
        function next() { currentIndex = (currentIndex + 1) % count }
        function confirm() {
            if (count > 0) root.setWallpaper(wallpapers.get(currentIndex).filename)
        }

        function thumbFor(filename) {
            return "file://" + root.thumbDir + "/" + filename.replace(/\.[^.]+$/, ".jpg")
        }

        width:  root.implicitWidth
        height: itemH
        anchors.centerIn: parent

        opacity: panelState.wallpaperOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

        focus: true
        Keys.onLeftPressed:   prev()
        Keys.onRightPressed:  next()
        Keys.onReturnPressed: confirm()
        Keys.onEnterPressed:  confirm()
        Keys.onEscapePressed: panelState.wallpaperOpen = false

        Repeater {
            model: 6
            Image {
                visible:      false
                cache:        true
                asynchronous: true
                source: carousel.count > 0
                    ? carousel.thumbFor(wallpapers.get(
                        ((carousel.currentIndex + (index - 3)) % carousel.count + carousel.count) % carousel.count
                      ).filename)
                    : ""
            }
        }

        Repeater {
            model: 5

            Item {
                id: slot

                readonly property int  offset:   index - 2
                readonly property int  imgIndex: ((carousel.currentIndex + offset) % carousel.count + carousel.count) % carousel.count
                readonly property bool isCenter: offset === 0
                readonly property int  slotW:    isCenter ? carousel.centerW : carousel.sideW
                readonly property int  slotH:    isCenter ? carousel.centerH : carousel.sideH
                readonly property string fname:  carousel.count > 0 ? wallpapers.get(imgIndex).filename : ""

                readonly property real targetX: {
                    var cx = (carousel.width - carousel.centerW) / 2
                    if (offset ===  0) return cx
                    if (offset === -1) return cx - carousel.sideW - carousel.spacing
                    if (offset === -2) return cx - carousel.sideW * 2 - carousel.spacing * 2
                    if (offset ===  1) return cx + carousel.centerW + carousel.spacing
                    if (offset ===  2) return cx + carousel.centerW + carousel.sideW + carousel.spacing * 2
                    return cx
                }

                x:      targetX
                y:      (carousel.itemH - slot.slotH) / 2
                width:  slotW
                height: slotH

                Behavior on x      { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                Behavior on width  { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                Behavior on height { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                Behavior on y      { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

                visible: carousel.count > 0

                Image {
                    anchors.fill: parent
                    source:       slot.fname !== "" ? carousel.thumbFor(slot.fname) : ""
                    fillMode:     Image.PreserveAspectCrop
                    asynchronous: true
                    cache:        true
                    opacity:      slot.isCenter ? 1.0 : 0.45
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                Rectangle {
                    visible:        slot.isCenter
                    anchors.bottom: parent.bottom
                    width:          parent.width
                    height:         30
                    color:          Qt.rgba(0, 0, 0, 0.6)

                    Text {
                        anchors.centerIn:    parent
                        text:                slot.fname
                        font.pixelSize:      11
                        font.family:         ThemeGlobal.fontSans
                        color:               "white"
                        elide:               Text.ElideMiddle
                        width:               parent.width - 16
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        carousel.forceActiveFocus()
                        if (slot.isCenter)        carousel.confirm()
                        else if (slot.offset < 0) carousel.prev()
                        else                      carousel.next()
                    }
                    onWheel: wheel => {
                        carousel.scrollAccum += wheel.angleDelta.x + wheel.angleDelta.y
                        if (carousel.scrollAccum > 120)       { carousel.prev(); carousel.scrollAccum = 0 }
                        else if (carousel.scrollAccum < -120) { carousel.next(); carousel.scrollAccum = 0 }
                    }
                }
            }
        }

        Text {
            anchors.left:           parent.left
            anchors.leftMargin:     80
            anchors.verticalCenter: parent.verticalCenter
            text:           "‹"
            font.pixelSize: 40
            color:          "white"
            opacity:        0.7
            MouseArea { anchors.fill: parent; onClicked: carousel.prev() }
        }

        Text {
            anchors.right:          parent.right
            anchors.rightMargin:    80
            anchors.verticalCenter: parent.verticalCenter
            text:           "›"
            font.pixelSize: 40
            color:          "white"
            opacity:        0.7
            MouseArea { anchors.fill: parent; onClicked: carousel.next() }
        }

        Text {
            anchors.top:              parent.bottom
            anchors.topMargin:        14
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "← → navigation  ·  ENTER confirm  ·  ESC close"
            font.pixelSize: 11
            font.family:    ThemeGlobal.fontSans
            color:          "white"
            opacity:        0.45
        }
    }
}
