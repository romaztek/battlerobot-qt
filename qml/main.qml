import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import Qt.labs.settings 1.0

import ru.romankartashev.logic 1.0

ApplicationWindow {
    id: main
    visible: true
    width: 640
    height: 360

    property bool hasTouchScreen: logic.hasTouchScreen()

    property color highlightColor: "#76FF03"
    property color defaultColor: "#f6f6f6"
    property color backgroundColor: "white"
    property color labelBackgroundColor: "#4fc3f7"

    property string leftCommandLow: "q"
    property string leftCommandNormal: "w"
    property string leftCommandHigh: "4"
    property string leftCommandDrift: "o"

    property string rightCommandLow: "e"
    property string rightCommandNormal: "r"
    property string rightCommandHigh: "6"
    property string rightCommandDrift: "p"

    property string centerCommand: "0"
    property string forwardCommand: "2"
    property string backwardCommand: "8"
    property string stopCommand: "5"

    property var connectWindow
    property var controlWindow
    property var settingsWindow

    property string connectedDeviceName
    property string connectedDeviceAddress

    Item {
        id: controlType
        property int none: 0
        property int touch: 1
        property int gamepad: 1
    }

    x: (Screen.desktopAvailableWidth - width)/2
    y: (Screen.desktopAvailableHeight - height)/2

    visibility: (Qt.platform.os == "android" ? Window.FullScreen :
                                               Qt.platform.os == "winrt" ? Window.Maximized :
                                                                           Window.AutomaticVisibility)
    Component.onCompleted: {
        createConnectWindow()
        connectWindow.listClear()

        var devices = logic.getBluetoothDevices().toString()

        var devices_list = devices.split(',')

        for(var i = 0; i < devices_list.length; i++) {
            console.log(devices_list[i])

            if(devices_list[i].length === 0)
                continue

            var device_address = devices_list[i].split(' ')[0]
            var device_name = devices_list[i].replace(device_address + ' ', '')

            connectWindow.listAppend(device_name, device_address)
        }
    }

    Logic {
        id: logic
    }

    Connections {
        target: logic
        function onDeviceConnected() {
            destroyConnectWindow()
            createControlWindow()
        }
    }

    function createConnectWindow() {
        connectWindow = myConnectWindow.createObject(main, {"id": "connectWindow"});
    }

    function destroyConnectWindow() {
        connectWindow.destroy()
    }

    function createControlWindow() {
        controlWindow = myControlWindow.createObject(main, {"id": "controlWindow"});
    }

    function destroyControlWindow() {
        controlWindow.destroy()
    }

    function recreateControlWindow() {
        destroyControlWindow()
        createControlWindow()
    }

    function createSettingsWindow() {
        settingsWindow = mySettingsWindow.createObject(main, {"id": "settingsWindow"});
    }

    function destroySettingsWindow() {
        settingsWindow.destroy()
    }

    Component {
        id: myConnectWindow
        ConnectWindow { }
    }

    Component {
        id: myControlWindow
        ControlWindow { }
    }

    Component {
        id: mySettingsWindow
        SettingsWindow { }
    }

    //    ConnectWindow {
    //        id: connectWindow
    //        anchors.fill: parent
    //    }

    //    ControlWindow {
    //        id: controlWindow
    //        anchors.fill: parent
    //    }

    //    SettingsWindow {
    //        id: settingsWindow
    //        anchors.fill: parent
    //        anchors.margins: 5
    //    }

}
