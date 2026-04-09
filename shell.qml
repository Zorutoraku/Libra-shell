import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "themes"
import "panels"
import "settings"
import "tools"

ShellRoot {

    id: root

    // ThemeService früh initialisieren — verhindert lazy-init pro PanelWindow
    Component.onCompleted: ThemeService

    QtObject {
        id: panelState

        property bool leftOpen:      false
        property bool right1Open:    false
        property bool right2Open:    false
        property bool settingsOpen:  false
        property bool wallpaperOpen: false
        property bool dndEnabled:    false
        readonly property bool anyOpen: leftOpen || right1Open || right2Open || settingsOpen

        function openAll()  { leftOpen = right1Open = right2Open = true  }
        function closeAll() { leftOpen = right1Open = right2Open = settingsOpen = false }
    }

    //Panels
    TopBar      {}
    PanelOverlay { panelState: panelState }
    LeftPanel    { panelState: panelState }
    RightPanelTop    { panelState: panelState }
    RightPanelBottom { panelState: panelState }

    //Windows
    SettingsWindow { panelState: panelState }
    WallpaperTool  { panelState: panelState }

    //Shortcuts
    GlobalShortcut {
        name:        "toggleWallpaper"
        description: "Toggle Wallpaper Switcher"
        onPressed:   panelState.wallpaperOpen = !panelState.wallpaperOpen
    }
}
