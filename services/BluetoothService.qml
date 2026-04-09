pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {

    // --- Funktion ---

    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available:    adapter !== null
    readonly property bool enabled:      adapter?.enabled    ?? false
    readonly property bool discovering:  adapter?.discovering ?? false
    readonly property bool discoverable: adapter?.discoverable ?? false

    readonly property var devices: {
        if (!adapter?.devices) return []
        return adapter.devices.values.filter(d => d?.connected)
    }

    readonly property var allDevices: {
        if (!adapter?.devices) return []
        return adapter.devices.values.filter(d => d !== null && d !== undefined)
    }

    readonly property var active: devices.length > 0 ? devices[0] : null

    readonly property string sublabel: {
        if (!enabled) return "Off"
        if (active)   return active.name ?? "Connected"
        return "On"
    }

    function toggleBluetooth() {
        if (adapter) adapter.enabled = !adapter.enabled
    }

    function startDiscovery() {
        if (adapter && !adapter.discovering) adapter.discovering = true
    }

    function stopDiscovery() {
        if (adapter && adapter.discovering) adapter.discovering = false
    }

    function setDiscoverable(v) {
        if (adapter) adapter.discoverable = v
    }

    function connectDevice(device) {
        if (device) device.connected = true
    }

    function disconnectDevice(device) {
        if (device) device.connected = false
    }
}
