pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {

    id: root

    property alias activePlayer: instance.activePlayer
    property bool  isPlaying: activePlayer ? activePlayer.playbackState === MprisPlaybackState.Playing : false
    property string title:    activePlayer ? activePlayer.trackTitle  : ""
    property string artist:   activePlayer ? activePlayer.trackArtist : ""
    property bool  hasPlayer: Mpris.players.values.length > 0
    property real  length:    activePlayer ? activePlayer.length : 0

    property real _position: 0
    readonly property real position: _position

    // normalize art URL
    readonly property string artUrl: {
        if (!activePlayer) return ""
        const raw = activePlayer.trackArtUrl
        if (!raw || raw === "") return ""
        if (raw.startsWith("file://") || raw.startsWith("http://") || raw.startsWith("https://"))
            return raw
        if (raw.startsWith("/"))
            return "file://" + raw
        return raw
    }

    function playPause() {
        if (activePlayer && activePlayer.canTogglePlaying)
            activePlayer.togglePlaying()
    }
    function next() {
        if (activePlayer && activePlayer.canGoNext)
            activePlayer.next()
    }
    function previous() {
        if (activePlayer && activePlayer.canGoPrevious)
            activePlayer.previous()
    }
    function setPosition(pos) {
        if (activePlayer)
            activePlayer.position = pos
    }

    // prefers a currently-playing player
    function updateActivePlayer() {
        const players = Mpris.players.values
        const playing = players.find(p => p.playbackState === MprisPlaybackState.Playing)
        if (playing) {
            instance.activePlayer = playing
        } else if (players.length > 0) {
            if (!instance.activePlayer || !players.includes(instance.activePlayer))
                instance.activePlayer = players[0]
        } else {
            instance.activePlayer = null
        }
    }

    Component.onCompleted: updateActivePlayer()

    // QtObject wrapper: Singleton can't hold a writable var alias to itself
    QtObject {
        id: instance
        property var activePlayer: null
    }

    onActivePlayerChanged: {
        if (!activePlayer)
            root._position = 0
    }

    Connections {
        target:  root.activePlayer
        enabled: root.activePlayer !== null
        function onPlaybackStateChanged() { root.updateActivePlayer() }
        function onPositionChanged() {
            root._position = root.activePlayer ? root.activePlayer.position : 0
        }
    }

    // 1s poll supplements onPositionChanged
    Timer {
        repeat:   true
        onTriggered: {
            if (root.activePlayer)
                root._position = root.activePlayer.position
        }
    }

    Connections {
        target: Mpris.players
        function onValuesChanged() { root.updateActivePlayer() }
    }
}
