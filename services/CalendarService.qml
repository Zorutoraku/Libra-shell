pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {

    id: root

    readonly property string filePath: Quickshell.shellDir + "/calendar_notes.json"

    property var notes: ({})

    function getNote(year, month, day) {
        return root.notes[_key(year, month, day)] || ""
    }

    function setNote(year, month, day, text) {
        var n = Object.assign({}, root.notes)
        var k = _key(year, month, day)
        if (text === "") delete n[k]
        else             n[k] = text
        root.notes = n
        _scheduleSave()
    }

    function hasNote(year, month, day) {
        return !!root.notes[_key(year, month, day)]
    }

    function _key(y, m, d) { return y + "-" + m + "-" + d }

    function _scheduleSave() {
        saveDebounce.restart()
    }

    Timer {
        id: saveDebounce
        interval: 800
        repeat:   false
        onTriggered: root._save()
    }

    Component.onDestruction: {
        saveDebounce.stop()
        root._save()
    }

    function _save() {
        var json = JSON.stringify(root.notes)
        writeProc.command = ["sh", "-c",
            "printf '%s' " + _shellQuote(json) + " > " + _shellQuote(root.filePath)]
        writeProc.running = true
    }

    function _shellQuote(s) {
        return "'" + s.replace(/'/g, "'\\''") + "'"
    }

    function _load() {
        try {
            var parsed = JSON.parse(fileView.text())
            root.notes = (parsed && typeof parsed === "object") ? parsed : ({})
        } catch (_) {
            root.notes = ({})
        }
    }

    property var fileView: FileView {
        path: root.filePath
        onTextChanged: root._load()
        Component.onCompleted: reload()
    }

    property var writeProc: Process {
        running: false
    }
}