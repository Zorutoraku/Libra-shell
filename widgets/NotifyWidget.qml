import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../themes"

Item {

    id: root

    required property var panelState

    property int _uid: 0
    property var _queue: []

    ListModel { id: notifs }

    function _addNotif(n) {
        const uid = root._uid++
        n.tracked = true

        var summary = (n.summary !== undefined) ? String(n.summary) : ""
        var body    = (n.body    !== undefined) ? String(n.body)    : ""
        if (summary === "" && body !== "") {
            summary = body
            body    = ""
        }

        notifs.insert(0, {
            "uid":     uid,
            "ref":     n,
            "appName": (n.appName  !== undefined) ? String(n.appName)  : "System",
            "summary": summary,
            "body":    body,
            "appIcon": (n.appIcon  !== undefined) ? String(n.appIcon)  : "",
            "image":   (n.image    !== undefined) ? String(n.image)    : ""
        })
        n.closed.connect(() => {
            for (let i = 0; i < notifs.count; i++) {
                if (notifs.get(i).uid === uid) { notifs.remove(i); break }
            }
        })
    }

    function _addCaptured(cap) {
        const uid = root._uid++
        const n   = cap.ref
        if (n) n.tracked = true
        notifs.insert(0, {
            "uid":     uid,
            "ref":     n,
            "appName": cap.appName,
            "summary": cap.summary,
            "body":    cap.body,
            "appIcon": cap.appIcon,
            "image":   cap.image
        })
        if (n) {
            n.closed.connect(() => {
                for (let i = 0; i < notifs.count; i++) {
                    if (notifs.get(i).uid === uid) { notifs.remove(i); break }
                }
            })
        }
    }

    property bool _flushing: false
    property var  _flushBuf: []
    property int  _flushIdx: 0

    function _flushQueue() {
        const q = root._queue
        root._queue = []
        if (q.length === 0) return
        root._flushing = true
        root._flushBuf = q
        root._flushIdx = 0
        flushTimer.start()
    }

    Timer {
        id: flushTimer
        interval: 100
        repeat:   true
        onTriggered: {
            if (root._flushIdx >= root._flushBuf.length) {
                stop()
                root._flushBuf = []
                root._flushing = false
                return
            }
            root._addCaptured(root._flushBuf[root._flushIdx])
            root._flushIdx++
        }
    }

    Connections {
        target: root.panelState
        function onDndEnabledChanged() {
            if (!root.panelState.dndEnabled) root._flushQueue()
        }
    }

    NotificationServer {
        bodySupported:    true
        imageSupported:   true
        actionsSupported: true

        onNotification: (n) => {
            if (root.panelState.dndEnabled) {
                n.tracked = true
                var summary = (n.summary !== undefined) ? String(n.summary) : ""
                var body    = (n.body    !== undefined) ? String(n.body)    : ""
                if (summary === "" && body !== "") { summary = body; body = "" }
                root._queue = root._queue.concat([{
                    ref:     n,
                    appName: (n.appName  !== undefined) ? String(n.appName)  : "System",
                    summary: summary,
                    body:    body,
                    appIcon: (n.appIcon  !== undefined) ? String(n.appIcon)  : "",
                    image:   (n.image    !== undefined) ? String(n.image)    : ""
                }])
            } else {
                root._addNotif(n)
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible:        notifs.count === 0
        text:           "No notifications"
        color:          ThemeWidgets.notify.emptyTextColor
        font.pixelSize: ThemeWidgets.notify.emptyTextSize
        font.family:    ThemeGlobal.fontSans
        font.italic:    true
    }

    ListView {
        id: list

        readonly property int hMargin: 10

        anchors {
            fill:         parent
            leftMargin:   hMargin
            rightMargin:  hMargin
            topMargin:    10
            bottomMargin: 10
        }

        model:   notifs
        spacing: 6
        clip:    true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width:  4
            contentItem: Rectangle {
                radius: 2
                color:  ThemeWidgets.notify.scrollbarColor
            }
            background: Rectangle { color: "transparent" }
        }

        add:       Transition {
            enabled: !root._flushing
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: ThemeWidgets.notify.animDuration }
            NumberAnimation { property: "y"; from: -16; to: 0; duration: ThemeWidgets.notify.animDuration; easing.type: Easing.OutQuad }
        }
        remove:    Transition { NumberAnimation { property: "opacity"; to: 0; duration: 150 }
                                NumberAnimation { property: "x"; to: 40; duration: 150; easing.type: Easing.InQuad } }
        displaced: Transition {
            enabled: !root._flushing
            NumberAnimation { property: "y"; duration: 180; easing.type: Easing.OutQuad }
        }

        delegate: Rectangle {
            id: delegateRoot
            width:          list.width
            implicitHeight: cardCol.implicitHeight + 18
            radius:       13
            color:        ThemeWidgets.notify.cardBg
            border.width: 1
            border.color: ThemeWidgets.notify.cardBorder

            Rectangle {
                id: closeBtn
                anchors { top: parent.top; right: parent.right; topMargin: 6; rightMargin: 6 }
                width: 16; height: 16; radius: 8
                z: 1

                color: closeHover.containsMouse
                       ? Qt.rgba(ThemeWidgets.notify.closeHoverColor.r,
                                 ThemeWidgets.notify.closeHoverColor.g,
                                 ThemeWidgets.notify.closeHoverColor.b, 0.28)
                       : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text:             "✕"
                    font.pixelSize:   ThemeWidgets.notify.closeIconSize
                    lineHeight:       1.0
                    lineHeightMode:   Text.FixedHeight
                    height:           font.pixelSize
                    color:            closeHover.containsMouse
                                      ? ThemeWidgets.notify.closeHoverColor
                                      : ThemeWidgets.notify.closeNormalColor
                    Behavior on color { ColorAnimation { duration: 100 } }
                }

                MouseArea {
                    id:           closeHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked: {
                        const ref = model.ref
                        if (ref) {
                            try { ref.dismiss() } catch (e) {
                                console.warn("NotifyWidget: ref.dismiss() fehlgeschlagen:", e)
                                const uid = model.uid
                                for (let i = 0; i < notifs.count; i++) {
                                    if (notifs.get(i).uid === uid) { notifs.remove(i); break }
                                }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                id: cardCol
                anchors {
                    left:  parent.left;  leftMargin:  10
                    right: parent.right; rightMargin: 10
                    top:   parent.top;   topMargin:   9
                }
                spacing: 3

                RowLayout {
                    Layout.fillWidth:   true
                    Layout.rightMargin: 18
                    spacing: 5

                    Image {
                        width: 13; height: 13
                        sourceSize.width: 13; sourceSize.height: 13
                        fillMode: Image.PreserveAspectFit
                        visible:  status === Image.Ready
                        cache:    true
                        source: {
                            const ic = model.appIcon || model.image || ""
                            if (!ic)                      return ""
                            if (ic.startsWith("/"))       return "file://" + ic
                            if (ic.startsWith("file://")) return ic
                            return "image://icon/" + ic
                        }
                    }

                    Text {
                        text:           model.appName
                        color:          ThemeWidgets.notify.cardAppName
                        font.pixelSize: ThemeWidgets.notify.appNameSize
                        font.family:    ThemeGlobal.fontSans
                        font.bold:      true
                        elide:          Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Text {
                    visible:        text !== ""
                    text:           model.summary
                    color:          ThemeWidgets.notify.cardSummary
                    font.pixelSize: ThemeWidgets.notify.summarySize
                    font.family:    ThemeGlobal.fontSans
                    font.weight:    Font.DemiBold
                    wrapMode:       Text.WordWrap
                    Layout.fillWidth: true
                }

                Text {
                    visible:             text !== ""
                    text:                model.body
                    color:               ThemeWidgets.notify.cardBody
                    font.pixelSize:      ThemeWidgets.notify.bodySize
                    font.family:         ThemeGlobal.fontSans
                    wrapMode:            Text.WordWrap
                    maximumLineCount:    4
                    elide:               Text.ElideRight
                    Layout.fillWidth:    true
                    Layout.bottomMargin: 2
                }
            }
        }
    }
}
