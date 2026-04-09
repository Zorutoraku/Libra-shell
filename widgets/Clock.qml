import QtQuick
import "../themes"

Text {

    // --- Funktion ---

    id: clock
    color:          ThemeWidgets.clock.color
    font.pixelSize: ThemeWidgets.clock.fontSize
    font.family:    ThemeGlobal.fontSans
    text: Qt.formatTime(new Date(), "hh:mm")

    // Synchronisiert auf die nächste volle Minute, danach exakt jede 60s
    Timer {
        id:       syncTimer
        interval: (60 - new Date().getSeconds()) * 1000
        running:  true
        repeat:   false
        onTriggered: {
            clock.text = Qt.formatTime(new Date(), "hh:mm")
            tickTimer.start()
        }
    }

    Timer {
        id:       tickTimer
        interval: 60000
        running:  false
        repeat:   true
        onTriggered: clock.text = Qt.formatTime(new Date(), "hh:mm")
    }
}
