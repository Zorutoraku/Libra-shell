pragma Singleton
import QtQuick
import Qt.labs.settings
import Quickshell.Io
import "."

QtObject {

    id: root

    readonly property string _confPath:    Qt.resolvedUrl("quickshell.conf").toString().replace(/^file:\/\//, "")
    readonly property string _palettesDir: Qt.resolvedUrl("palettes/").toString().replace(/^file:\/\//, "")

    readonly property Settings _cfg: Settings {
        fileName: root._confPath
        category: "design"
        property string palette:     "warm-dark"
        property string fontSans:    "FreeSans"
        property int    panelRadius: 16
    }

    property string currentPalette: _cfg.palette
    property var    palettes:        []

    property color backgroundOne:   "#121009"
    property color backgroundTwo:   "#1A1712"
    property color backgroundThree: "#221E17"
    property color backgroundFour:  "#2B261D"

    property color textMain:        "#F0E8D8"
    property color textSub:         "#C8BFA8"
    property color textMuted:       "#9E9280"
    property color textHint:        "#6E6457"

    property color accentPrimary:   "#FFD060"
    property color accentDanger:    "#C84040"
    property color accentInfo:      "#A8C8F0"
    property color accentSuccess:   "#80C040"

    Component.onCompleted: {
        ThemeGlobal.fontSans    = _cfg.fontSans
        ThemePanels.panelRadius = _cfg.panelRadius
        _loadPalettes()
    }

    function setPalette(id) {
        currentPalette = id
        _cfg.palette   = id
        _applyById(id)
    }

    function setFont(family) {
        ThemeGlobal.fontSans = family
        _cfg.fontSans        = family
    }

    function setPanelRadius(r) {
        ThemePanels.panelRadius = r
        _cfg.panelRadius        = r
    }

    readonly property Process _paletteLoader: Process {
        id: paletteLoader
        command: ["python3", "-c",
            "import json, pathlib; d = pathlib.Path('" + root._palettesDir + "'); " +
            "print(json.dumps([json.loads(f.read_text()) for f in sorted(d.glob('*.json'))]))"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text) {
                    console.warn("ThemeService: Paletten konnten nicht geladen werden")
                    return
                }
                try {
                    const all = JSON.parse(text)
                    root._onAllPalettesLoaded(all.filter(p => p.id && p.name && p.preview))
                } catch (e) {
                    console.warn("ThemeService: JSON-Fehler –", e)
                }
            }
        }
        onExited: (code) => {
            if (code !== 0)
                console.warn("ThemeService: python3 palette-loader fehlgeschlagen (exit", code + ")")
        }
    }

    function _loadPalettes() {
        paletteLoader.running = true
    }

    function _onAllPalettesLoaded(loaded) {
        const order  = ["warm-dark", "cold-blue", "rose-pine", "gruvbox", "nightreign"]
        const sorted = loaded.slice().sort((a, b) => {
            const ai = order.indexOf(a.id)
            const bi = order.indexOf(b.id)
            if (ai !== -1 && bi !== -1) return ai - bi
            if (ai !== -1) return -1
            if (bi !== -1) return  1
            return a.id.localeCompare(b.id)
        })
        root.palettes = sorted
        _applyById(_cfg.palette)
    }

    function _applyById(id) {
        for (let i = 0; i < palettes.length; i++) {
            if (palettes[i].id === id) { _applyPalette(palettes[i]); return }
        }
        if (palettes.length > 0) {
            console.warn("ThemeService: Palette '" + id + "' nicht gefunden, nutze Fallback:", palettes[0].id)
            _applyPalette(palettes[0])
        }
    }

    function _applyPalette(d) {
        root.backgroundOne   = d.backgroundOne
        root.backgroundTwo   = d.backgroundTwo
        root.backgroundThree = d.backgroundThree
        root.backgroundFour  = d.backgroundFour
        root.textMain        = d.textMain
        root.textSub         = d.textSub
        root.textMuted       = d.textMuted
        root.textHint        = d.textHint
        root.accentPrimary   = d.accentPrimary
        root.accentDanger    = d.accentDanger
        root.accentInfo      = d.accentInfo
        root.accentSuccess   = d.accentSuccess
    }
}
