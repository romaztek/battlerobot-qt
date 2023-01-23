import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import Qt.labs.settings 1.0

import ru.romanlenz.logic 1.0

Window {
    id: main
    visible: true
    width: 640
    height: 360

    property color highlightColor: "#76FF03"
    property color defaultColor: "#f6f6f6"
    property color backgroundColor: "white"
    property color labelBackgroundColor: "#4fc3f7"
    property bool hasTouchScreen: logic.hasTouchScreen()

    property string leftCommand: "4"
    property string rightCommand: "6"
    property string centerCommand: "0"
    property string forwardCommand: "2"
    property string backwardCommand: "8"
    property string stopCommand: "5"

    x: (Screen.desktopAvailableWidth - width)/2
    y: (Screen.desktopAvailableHeight - height)/2

    visibility: (Qt.platform.os == "android" || Qt.platform.os == "winrt" ? Window.FullScreen : Window.AutomaticVisibility )

    Component.onCompleted: {
        if(Qt.platform.os == "android" || Qt.platform.os == "linux") {
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
    }

    Logic {
        id: logic
    }

    Connections {
        target: logic
        function onDeviceConnected() {
            controlWindow.setDeviceName(connectWindow.connectedDeviceName)
            connectWindow.hideConnectProgressWindow()
            connectWindow.hide()
            controlWindow.show()
        }
        function onDeviceFound() {
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
        function onDeviceDisconnected() {

        }
        function onDeviceError() {
            console.log(err);
            connectWindow.hideConnectProgressWindow()
            connectWindow.connectedErrorString = err
            connectWindow.showErrorWindow()

        }
    }

    ConnectWindow {
        id: connectWindow
        anchors.fill: parent
    }
    
    ControlWindow {
        id: controlWindow
        anchors.fill: parent
    }    

}
