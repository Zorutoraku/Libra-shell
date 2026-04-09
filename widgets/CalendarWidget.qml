import QtQuick
import QtQuick.Controls
import "../themes"
import "../services"

Item {

    id: root

    readonly property var t: ThemeWidgets.calendar

    property var now: new Date()
    Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: root.now = new Date()
    }

    readonly property int todayDay:   now.getDate()
    readonly property int todayMonth: now.getMonth()
    readonly property int todayYear:  now.getFullYear()

    property int viewYear:    todayYear
    property int viewMonth:   todayMonth
    property int selectedDay: -1

    function prevMonth() {
        if (viewMonth === 0) { viewMonth = 11; viewYear-- }
        else                 { viewMonth-- }
        selectedDay = -1
    }
    function nextMonth() {
        if (viewMonth === 11) { viewMonth = 0; viewYear++ }
        else                  { viewMonth++ }
        selectedDay = -1
    }

    readonly property int firstWeekday: {
        var d = new Date(viewYear, viewMonth, 1).getDay()
        return (d + 6) % 7
    }
    readonly property int daysInMonth: new Date(viewYear, viewMonth + 1, 0).getDate()

    readonly property var monthNames: [
        "Januar","Februar","März","April","Mai","Juni",
        "Juli","August","September","Oktober","November","Dezember"
    ]
    readonly property var dayLabels: ["Mo","Di","Mi","Do","Fr","Sa","So"]

    MouseArea {
        anchors.fill:            parent
        propagateComposedEvents: true
        onClicked: mouse => {
            noteInput.focus  = false
            root.selectedDay = -1
            mouse.accepted   = false
        }
    }

    Column {
        id: calColumn
        anchors {
            top: parent.top; left: parent.left; right: parent.right
            leftMargin: root.t.padding; rightMargin: root.t.padding
        }
        spacing: root.t.spacing

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6

            Rectangle {
                width: root.t.navBtnSize; height: root.t.navBtnSize
                radius: root.t.navBtnSize / 2
                color:  "transparent"
                border.width: 1
                border.color: prevHover.hovered ? root.t.accentColor : root.t.cardBorder
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "<"; font.family: ThemeGlobal.fontSans
                    font.pixelSize: root.t.headerFontSize; font.bold: true
                    color: prevHover.hovered ? root.t.accentColor : root.t.mutedColor
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                HoverHandler { id: prevHover; cursorShape: Qt.PointingHandCursor }
                TapHandler  { onTapped: root.prevMonth() }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text:           root.monthNames[root.viewMonth] + "  " + root.viewYear
                font.family:    ThemeGlobal.fontSans
                font.pixelSize: root.t.headerFontSize
                font.weight:    Font.Medium
                color:          root.t.accentColor
            }

            Rectangle {
                width: root.t.navBtnSize; height: root.t.navBtnSize
                radius: root.t.navBtnSize / 2
                color:  "transparent"
                border.width: 1
                border.color: nextHover.hovered ? root.t.accentColor : root.t.cardBorder
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: ">"; font.family: ThemeGlobal.fontSans
                    font.pixelSize: root.t.headerFontSize; font.bold: true
                    color: nextHover.hovered ? root.t.accentColor : root.t.mutedColor
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                HoverHandler { id: nextHover; cursorShape: Qt.PointingHandCursor }
                TapHandler  { onTapped: root.nextMonth() }
            }
        }

        Row {
            width: parent.width
            Repeater {
                model: root.dayLabels
                Text {
                    width:               parent.width / 7
                    text:                modelData
                    font.family:         ThemeGlobal.fontSans
                    font.pixelSize:      root.t.labelFontSize
                    font.weight:         Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    color: index >= 5
                           ? Qt.rgba(root.t.weekendColor.r, root.t.weekendColor.g, root.t.weekendColor.b, 0.6)
                           : root.t.infoColor
                }
            }
        }

        Grid {
            width: parent.width; columns: 7; columnSpacing: 2; rowSpacing: 2

            Repeater {
                model: root.firstWeekday
                Item { width: (parent.width - 12) / 7; height: width }
            }

            Repeater {
                model: root.daysInMonth
                delegate: Item {
                    readonly property int  day:        index + 1
                    readonly property bool isToday:    day === root.todayDay && root.viewMonth === root.todayMonth && root.viewYear === root.todayYear
                    readonly property bool isSelected: day === root.selectedDay
                    readonly property bool isWeekend:  ((root.firstWeekday + index) % 7) >= 5
                    readonly property bool hasNote:    CalendarService.hasNote(root.viewYear, root.viewMonth, day)

                    width: (parent.width - 12) / 7; height: width

                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) - 2; height: width
                        radius: width / 2
                        color: isToday    ? Qt.rgba(root.t.accentColor.r, root.t.accentColor.g, root.t.accentColor.b, 0.18)
                             : isSelected ? Qt.rgba(root.t.accentColor.r,  root.t.accentColor.g,  root.t.accentColor.b,  0.20)
                             : dayHover.hovered ? root.t.cardBg
                             : "transparent"
                        border.width: 1
                        border.color: isToday    ? root.t.accentColor
                                    : isSelected ? Qt.rgba(root.t.accentColor.r,  root.t.accentColor.g,  root.t.accentColor.b,  0.50)
                                    : dayHover.hovered ? root.t.cardBorder
                                    : "transparent"
                        Behavior on color        { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        Rectangle {
                            anchors.fill: parent; radius: parent.radius
                            color: (!isToday && dayHover.hovered) ? root.t.hoverOverlay : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }

                    Text {
                        anchors.centerIn:    parent
                        text:                day
                        font.family:         ThemeGlobal.fontMono
                        font.pixelSize:      root.t.dayFontSize
                        font.bold:           isToday || isSelected
                        horizontalAlignment: Text.AlignHCenter
                        color: isToday    ? root.t.accentColor
                             : isSelected ? root.t.accentColor
                             : hasNote    ? root.t.successColor
                             : isWeekend  ? Qt.rgba(root.t.weekendColor.r, root.t.weekendColor.g, root.t.weekendColor.b, 0.7)
                             : root.t.textColor
                    }

                    HoverHandler { id: dayHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: {
                            root.selectedDay = day
                            noteInput.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors {
            top:    calColumn.bottom;  topMargin:    root.t.spacing
            left:   parent.left;       leftMargin:   root.t.padding
            right:  parent.right;      rightMargin:  root.t.padding
            bottom: parent.bottom
        }
        radius:       root.t.noteRadius
        color:        "transparent"
        border.width: 1
        border.color: root.t.cardBorder

        Text {
            id:             clearBtn
            anchors { bottom: parent.bottom; right: parent.right; margins: root.t.notePadding }
            z:              1
            text:           "clear day"
            font.family:    ThemeGlobal.fontMono
            font.pixelSize: root.t.noteFontSize - 1
            color:          clearMA.containsMouse ? root.t.weekendColor : root.t.mutedColor
            visible:        noteInput.text.length > 0
            Behavior on color { ColorAnimation { duration: 120 } }

            MouseArea {
                id:           clearMA
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: mouse => {
                    mouse.accepted = true
                    var y = root.viewYear
                    var m = root.viewMonth
                    var d = root.selectedDay
                    noteInput.text = ""
                    CalendarService.setNote(y, m, d, "")
                }
            }
        }

        Flickable {
            id:          noteFlick
            anchors {
                top: parent.top; left: parent.left; right: parent.right
                bottom: clearBtn.visible ? clearBtn.top : parent.bottom
                topMargin: root.t.notePadding; leftMargin: root.t.notePadding; rightMargin: root.t.notePadding
            }
            contentHeight: noteInput.contentHeight
            clip:          true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOff }

            TextEdit {
                id:             noteInput
                width:          noteFlick.width
                color:          root.t.textColor
                font.family:    ThemeGlobal.fontMono
                font.pixelSize: root.t.noteFontSize
                wrapMode:       TextEdit.Wrap
                selectionColor: Qt.rgba(root.t.accentColor.r, root.t.accentColor.g, root.t.accentColor.b, 0.35)
                clip:           false

                property bool _loading: false

                Component.onCompleted: _reload()

                function _reload() {
                    _loading = true
                    text = root.selectedDay > 0
                        ? CalendarService.getNote(root.viewYear, root.viewMonth, root.selectedDay)
                        : ""
                    _loading = false
                }

                Keys.onEscapePressed: focus = false
                Keys.onReturnPressed: (e) => {
                    if (e.modifiers & Qt.ShiftModifier) {
                        insert(cursorPosition, "\n")
                    } else {
                        focus = false
                    }
                }

                Text {
                    anchors.fill:   parent
                    text:           root.selectedDay > 0
                                    ? "Notiz für " + root.monthNames[root.viewMonth].substring(0, 3) + " " + root.selectedDay + " …"
                                    : "> Choose a date"
                    color:          root.t.mutedColor
                    font.family:    ThemeGlobal.fontMono
                    font.pixelSize: root.t.noteFontSize
                    visible:        noteInput.text.length === 0 && !noteInput.activeFocus
                    wrapMode:       Text.Wrap
                }

                onTextChanged: {
                    if (!_loading && root.selectedDay > 0)
                        CalendarService.setNote(root.viewYear, root.viewMonth, root.selectedDay, text)
                }
            }
        }
    }

    Connections {
        target: root
        function onSelectedDayChanged() { noteInput._reload() }
        function onViewMonthChanged()   { if (root.selectedDay > 0) noteInput._reload() }
    }
}
