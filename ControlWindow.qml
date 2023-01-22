import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12

import QtGamepad 1.12

import ru.romanlenz.logic 1.0

Rectangle {
    id: controlW
    anchors.fill: parent
    visible: false
    enabled: false

    Gamepad {
        id: gamepad
        deviceId: GamepadManager.connectedGamepads.length > 0 ? GamepadManager.connectedGamepads[0] : -1

        onConnectedChanged: {
            if(connected) {
                currentGamepadText.text = qsTr("Connected")
            } else {
                currentGamepadText.text = qsTr("Not Connected")
            }
        }

        onButtonLeftChanged: {
            if(buttonLeft) {
                if(!moveButtonRight.isPressed && (axisLeftX >= -0.3 && axisLeftX <= 0.3))
                    moveButtonLeft.pressed()
            } else {
                moveButtonLeft.released()
            }
        }

        onButtonRightChanged: {
            if(buttonRight) {
                if(!moveButtonLeft.isPressed && (axisLeftX >= -0.3 && axisLeftX <= 0.3))
                moveButtonRight.pressed()
            } else {
                moveButtonRight.released()
            }
        }

        onButtonR2Changed: {
            if(buttonR2) {
                if(buttonL2)
                    moveButtonBackward.released()
                moveButtonForward.pressed()
            } else {
                moveButtonForward.released()
            }
        }

        onButtonL2Changed: {
            if(buttonL2) {
                if(buttonR2)
                    moveButtonForward.released()
                moveButtonBackward.pressed()
            } else {
                moveButtonBackward.released()
            }
        }

        onAxisLeftXChanged: {
            console.log(axisLeftX)
            if(axisLeftX < -0.3) {
                if(!moveButtonRight.isPressed && !buttonLeft)
                    moveButtonLeft.pressed()
            } else if(axisLeftX > 0.3) {
                if(!moveButtonLeft.isPressed && !buttonRight)
                    moveButtonRight.pressed()
            } else {
                moveButtonLeft.released()
                moveButtonRight.released()
            }
        }
    }

    Connections {
        target: GamepadManager
        onGamepadConnected: {
            gamepad.deviceId = deviceId
        }
    }

    function show() {
        controlW.visible = true
        controlW.enabled = true
    }

    function hide() {
        controlW.visible = false
        controlW.enabled = false
    }

    function setDeviceName(str) {
        currentDeviceText.text = str
    }

    function stopMovement() {
        logic.send("5")
        console.log(qsTr("STOP"))
    }

    Item {
        id: topMenu
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        width: parent.width

        height: 50

        Rectangle {
            id: currentDeviceTop
            width: parent.width/2 - 7.5
            height: 50
            anchors.left: parent.left
            anchors.leftMargin: 5
            border.width: 2
            border.color: "black"
            radius: height/4

            RowLayout {
                spacing: 5
                anchors.fill: parent
                Image {
                    id: robotHeadIcon
                    Layout.maximumWidth: 40
                    Layout.maximumHeight: 40
                    Layout.margins: 5
                    source: "qrc:/img/bt_icon.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
                Text {
                    id: currentDeviceText
                    font.pointSize: 11
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("NULL")
                }
            }
        }
        Rectangle {
            id: currentGamepadTop
            width: parent.width/2 - 7.5
            height: 50
            anchors.left: currentDeviceTop.right
            anchors.leftMargin: 5
            border.width: 2
            border.color: "black"
            radius: height/4

            RowLayout {
                spacing: 5
                anchors.fill: parent
                Image {
                    id: gamepadIcon
                    Layout.maximumWidth: 40
                    Layout.maximumHeight: 40
                    Layout.margins: 5
                    source: "qrc:/img/gamepad_icon.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
                Text {
                    id: currentGamepadText
                    font.pointSize: 11
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr("Not Connected")
                }
            }
        }

    }

    Item {
        id: moveMenu
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: topMenu.bottom
        anchors.bottom: parent.bottom
        anchors.margins: 5

        visible: true
        enabled: true

        RowLayout {
            anchors.bottom: parent.bottom
            height: parent.height
            width: parent.width
            spacing: 5

            MoveButton {
                id: moveButtonLeft
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("LEFT")
                onPressed: {
                    logic.send("4")
                    console.log(qsTr("LEFT"))
                }
                onReleased: {
                    stopMovement()
                }
            }

            MoveButton {
                id: moveButtonRight
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("RIGHT")
                onPressed: {
                    logic.send("6")
                    console.log(qsTr("RIGHT"))
                }
                onReleased: {
                    stopMovement()
                }
            }

            ColumnLayout {
                height: 200
                spacing: 5
                Layout.fillWidth: true
                Layout.fillHeight: true
                MoveButton {
                    id: moveButtonForward
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("FORWARD")
                    onPressed: {
                        logic.send("8")
                        console.log(qsTr("FORWARD"))
                    }
                    onReleased: {
                        stopMovement()
                    }
                }
                MoveButton {
                    id: moveButtonBackward
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("BACKWARD")
                    onPressed: {
                        logic.send("2")
                        console.log(qsTr("BACKWARD"))
                    }
                    onReleased: {
                        stopMovement()
                    }
                }
            }

        }
    }

}
