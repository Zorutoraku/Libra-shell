pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {

    id: root

    // ══════════════════════════════════════════
    //  OUTPUT (Sinks)
    // ══════════════════════════════════════════

    // PwObjectTracker keeps Pipewire node objects alive
    PwObjectTracker { objects: root.sinks }
        readonly property var sinks: Pipewire.nodes.values.reduce((acc, n) => {
            if (!n.isStream && n.isSink && n.audio) acc.push(n); return acc
        }, [])

    readonly property PwNode activeSink: {
        if (!Pipewire.ready) return null
        let d = Pipewire.defaultAudioSink
        if (d && !d.isStream && d.isSink && d.audio) return d
        return sinks.length > 0 ? sinks[0] : null
    }

    function setDefaultSink(node) {
        if (!node) return
        sinkSwitchProc.command = ["wpctl", "set-default", String(node.id)]
        sinkSwitchProc.running = true
    }

    Process {
        id: sinkSwitchProc
        onExited: (code) => {
            if (code !== 0)
                console.warn("SoundService: wpctl set-default sink failed (exit", code + ")")
        }
    }

    // ══════════════════════════════════════════
    //  INPUT (Sources)
    // ══════════════════════════════════════════

    PwObjectTracker { objects: root.sources }

    readonly property var sources: Pipewire.nodes.values.reduce((acc, n) => {
        if (!n.isStream && !n.isSink && n.audio) acc.push(n); return acc
    }, [])

    readonly property PwNode activeSource: {
        if (!Pipewire.ready) return null
        let d = Pipewire.defaultAudioSource
        if (d && !d.isStream && !d.isSink && d.audio) return d
        return sources.length > 0 ? sources[0] : null
    }

    function setDefaultSource(node) {
        if (!node) return
        sourceSwitchProc.command = ["wpctl", "set-default", String(node.id)]
        sourceSwitchProc.running = true
    }

    Process {
        id: sourceSwitchProc
        onExited: (code) => {
            if (code !== 0)
                console.warn("SoundService: wpctl set-default source failed (exit", code + ")")
        }
    }
}
