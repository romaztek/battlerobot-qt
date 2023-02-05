import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import ru.romanlenz.logic 1.0

Rectangle {
    id: cw
    anchors.fill: parent
    color: backgroundColor

    property string connectedDeviceName
    property string connectedDeviceAddress
    property alias connectedErrorString: errorText.text

    function show() {
        cw.visible = true
        cw.enabled = true
    }

    function hide() {
        cw.visible = false
        cw.enabled = false
    }

    function showConnectProgressWindow() {
        connectProgressWindow.visible = true
        connectProgressWindow.opacity = 1
        connectProgressWindowMouseArea.enabled = true
    }

    function hideConnectProgressWindow() {
        connectProgressWindow.opacity = 0
        connectProgressWindowMouseArea.enabled = false
    }

    function showErrorWindow() {
        connectErrorWindow.visible = true
        connectErrorWindow.opacity = 1
        connectErrorWindowMouseArea.enabled = true
    }

    function hideErrorWindow() {
        connectErrorWindow.opacity = 0
        connectErrorWindowMouseArea.enabled = false
    }

    function listClear() {
        btListModel.clear()
    }

    function listAppend(device_name, device_address) {
        btListModel.append({"name": device_name, "address": device_address })
    }

    MyIconLabel {
        id: topText
        height: 50
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 5

        image: "qrc:/images/bt_icon.png"
        text: qsTr("Select a device")

        MyIconButton {
            id: topButtonSkip
            width: cw.width/4
            height: parent.height
            anchors.top: parent.top
            anchors.right: parent.right
            text: qsTr("Skip")
            imageSource: "qrc:/images/debug_icon.png"

            onClicked: {
                controlWindow.show()
                hide()
            }
        }
    }

    ListView {
        id: btList
        anchors.top: topText.bottom
        anchors.margins: 5
        anchors.bottom: bottomRow.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 5
        clip: true
        delegate: Component {
            Rectangle {
                width: btList.width
                height: 50
                radius: height/4
                color: "transparent"
                border.width: 2
                border.color: "black"

                Image {
                    id: _bt_img
                    width: 40
                    height: 40
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/bt_icon.png"
                    x: 5
                    y: 5
                }
                Item {
                    anchors.left: _bt_img.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 5

                    Text {
                        text: name + "\n" + address
                        font.pointSize: 11
                        x: 5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: btList.currentIndex = index
                }
            }
        }
        highlight: Rectangle {
            width: parent.width
            height: 50
            radius: height/4
            color: highlightColor
            border.width: 2
            border.color: "transparent"
        }
        model: btListModel
    }

    ListModel {
        id: btListModel
    }

    Rectangle {
        id: searchingProgressWindow
        anchors.top: topText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        visible: btListModel.count > 0 ? false : true
        width: parent.width
        height: 50
        radius: height/4
        color: "transparent"
        border.width: 2
        border.color: "black"
        z: 100

        Rectangle {
            width: 40
            height: 40
            x: 5
            y: 5
            color: "black"
            radius: height/2
        }

        Image {
            id: searchingProgressWindowBusyIndicator
            width: 40
            height: 40
            x: 5
            y: 5
            source: "qrc:/images/bt_icon.png"
        }

        SequentialAnimation {
            running: searchingProgressWindow.visible
            loops: Animation.Infinite
            OpacityAnimator {
                target: searchingProgressWindowBusyIndicator
                from: 1
                to: 0.2
                duration: 800
            }
            OpacityAnimator {
                target: searchingProgressWindowBusyIndicator
                from: 0.2
                to: 1
                duration: 800
            }
        }

        Item {
            anchors.left: searchingProgressWindowBusyIndicator.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 5

            Text {
                text: qsTr("Scanning...")
                font.pointSize: 12
                x: 5
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Row {
        id: bottomRow

        spacing: 5

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5

        MyIconButton {
            id: bottomButtonRefresh
            width: cw.width/2 - 10
            height: 50
            text: qsTr("Refresh")
            imageSource: "qrc:/images/refresh_icon.png"

            onClicked: {
                btListModel.clear()

                var devices = logic.getBluetoothDevices().toString()

                var devices_list = devices.split(',')

                for(var i = 0; i < devices_list.length; i++) {
                    console.log(devices_list[i])

                    if(devices_list[i].length === 0)
                        continue

                    var device_address = devices_list[i].split(' ')[0]
                    var device_name = devices_list[i].replace(device_address + ' ', '')

                    btListModel.append({"name": device_name, "address": device_address })
                }
            }
        }

        MyIconButton {
            id: bottomButtonConnect
            width: cw.width/2 - 10
            text: qsTr("Connect")
            imageSource: "qrc:/images/connect_icon.png"

            onClicked: {
                if(btListModel.get(btList.currentIndex)) {
                    connectedDeviceName = btListModel.get(btList.currentIndex).name
                    connectedDeviceAddress = btListModel.get(btList.currentIndex).address
                }
                else
                    connectedDeviceName = "NULL"
                connectingText.deviceName = connectedDeviceName
                showConnectProgressWindow()

                if(btListModel.get(btList.currentIndex))
                    logic.connectToDevice(btListModel.get(btList.currentIndex).address)
            }
        }
    }

    Item {
        id: connectProgressWindow
        anchors.fill: parent

        opacity: 0
        visible: false

        Behavior on opacity {
            OpacityAnimator {
                duration: 250
                onStopped: {
                    if(connectProgressWindow.opacity == 0) {
                        connectProgressWindow.enabled = false
                        connectProgressWindow.visible = false
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            opacity: 0.5
            color: "grey"
        }

        MouseArea {
            id: connectProgressWindowMouseArea
            anchors.fill: parent
        }

        Rectangle {
            width: connectProgressWindowBusyIndicator.width + connectingText.contentWidth + 25
            height: Math.max(connectProgressWindowBusyIndicator.height, connectingText.contentHeight) + 20
            border.width: 2
            radius: height/4
            anchors.centerIn: parent
        }

        Row {
            spacing: 5
            anchors.centerIn: parent
            LoadingCircleIndicator {
                id: connectProgressWindowBusyIndicator
            }
            Item {
                width: connectingText.width
                height: connectProgressWindowBusyIndicator.height
                Text {
                    id: connectingText
                    font.pointSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Connecting to") + "\n" + deviceName
                    property string deviceName: ""
                }
            }
        }
    }

    Item {
        id: connectErrorWindow
        anchors.fill: parent

        opacity: 0
        visible: false

        Behavior on opacity {
            OpacityAnimator {
                duration: 250
                onStopped: {
                    if(connectErrorWindow.opacity == 0) {
                        connectErrorWindow.enabled = false
                        connectErrorWindow.visible = false
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            opacity: 0.5
            color: "grey"
        }

        MouseArea {
            id: connectErrorWindowMouseArea
            anchors.fill: parent
        }

        Rectangle {
            width: connectErrorWindowErrorSign.width + errorText.contentWidth + 25
            height: Math.max(connectErrorWindowErrorSign.height, errorText.contentHeight) + 75
            border.width: 2
            radius: 12.5
            anchors.centerIn: parent
        }

        GridLayout {
            rows: 2
            columns: 2
            columnSpacing: 5
            rowSpacing: 5
            anchors.centerIn: parent
            Image {
                id: connectErrorWindowErrorSign
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                source: "qrc:/images/error_icon.png"
            }
            Item {
                id: errorTxt
                Layout.preferredWidth: errorText.width
                Layout.preferredHeight: connectErrorWindowErrorSign.height
                Text {
                    id: errorText
                    font.pointSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Error") + "\n" + errorName
                    property string errorName: "WTF WHAT HAPPENED"
                }
            }

            MyIconButton {
                id: connectErrorCloseButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                Layout.columnSpan: 2
                text: qsTr("Close")
                imageSource: "qrc:/images/close_icon.png"
                onClicked: hideErrorWindow()
            }
        }


    }

}
