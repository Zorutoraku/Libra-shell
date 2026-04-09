pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {

    // --- Funktion ---

    id: root

    PwObjectTracker { objects: root.sinks }

    readonly property var sinks: Pipewire.nodes.values.reduce((acc, n) => {
        if (!n.isStream && n.isSink && n.audio) acc.push(n);
        return acc;
    }, [])

    readonly property PwNode sink: {
        if (!Pipewire.ready) return null;
        let d = Pipewire.defaultAudioSink;
        if (d && !d.isStream && d.isSink && d.audio) return d;
        return sinks.length > 0 ? sinks[0] : null;
    }

    readonly property bool  ready:  !!sink
    readonly property real  volume: sink?.audio?.volume ?? 0
    readonly property bool  muted:  sink?.audio?.muted  ?? false

    readonly property string icon: {
        if (muted)         return "󰖁";
        if (volume <= 0)   return "󰝟";
        if (volume < 0.33) return "󰕿";
        if (volume < 0.66) return "󰖀";
        return "󰕾";
    }

    function setVolume(v) {
        if (sink?.audio) {
            if (sink.audio.muted) sink.audio.muted = false;
            sink.audio.volume = v;
        }
    }
    function toggleMute() { if (sink?.audio) sink.audio.muted = !sink.audio.muted; }
}
