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
    focus: true

    color: backgroundColor

    enum ControlType {
        None,
        Touch,
        Gamepad
    }

    Component.onCompleted: {
        if(logic.hasTouchScreen()) {
            currentControlType = ControlWindow.ControlType.Touch
            currentTouchTop.radioButton.checked = true
        }
    }

    property double deadzoneValue: 0.15
    property int currentControlType: ControlWindow.ControlType.Touch

    onCurrentControlTypeChanged: {
        if(moveButtonLeft.isPressed) {
            moveButtonLeft.released()
        } else if(moveButtonRight.isPressed) {
            moveButtonRight.released()
        } else if(moveButtonForward.isPressed) {
            moveButtonForward.released()
        } else if(moveButtonBackward.isPressed) {
            moveButtonBackward.released()
        }
    }

    Gamepad {
        id: gamepad
        deviceId: GamepadManager.connectedGamepads.length > 0 ? GamepadManager.connectedGamepads[0] : -1

        onConnectedChanged: {
            if(connected) {
                var gamePadName = logic.getGamepadName(gamepad.deviceId)
                currentGamepadTop.text = gamePadName.length === 0 ?  qsTr("Connected") : gamePadName
                currentControlType = ControlWindow.ControlType.Gamepad
                currentGamepadTop.enabled = true
            } else {
                currentGamepadTop.text = qsTr("Not Connected")
                logic.send(stopCommand)
                if(currentControlType === ControlWindow.ControlType.Gamepad) {
                    currentControlType = ControlWindow.ControlType.Touch
                    currentGamepadTop.enabled = false
                    currentGamepadTop.radioButton.checked = false
                }
            }
        }

        onButtonLeftChanged: {
            if(currentControlType !== ControlWindow.ControlType.Gamepad) return
            if(buttonLeft) {
                if(!moveButtonRight.isPressed)
                    moveButtonLeft.pressed()
            } else {
                moveButtonLeft.released()
            }
        }

        onButtonRightChanged: {
            if(currentControlType !== ControlWindow.ControlType.Gamepad) return
            if(buttonRight) {
                if(!moveButtonLeft.isPressed)
                    moveButtonRight.pressed()
            } else {
                moveButtonRight.released()
            }
        }

        onButtonR2Changed: {
            if(currentControlType !== ControlWindow.ControlType.Gamepad) return
            if(buttonR2) {
                if(buttonL2)
                    moveButtonBackward.released()
                if(moveButtonForward.isPressed) return
                moveButtonForward.pressed()
            } else {
                moveButtonForward.released()
            }
        }

        onButtonL2Changed: {
            if(currentControlType !== ControlWindow.ControlType.Gamepad) return
            if(buttonL2) {
                if(buttonR2)
                    moveButtonForward.released()
                if(moveButtonBackward.isPressed) return
                moveButtonBackward.pressed()
            } else {
                moveButtonBackward.released()
            }
        }

        onAxisLeftXChanged: {
            if(currentControlType !== ControlWindow.ControlType.Gamepad) return
            if(axisLeftX < -deadzoneValue) {
                //if(!moveButtonRight.isPressed && !buttonLeft)
                    moveButtonLeft.pressed()
            } else if(axisLeftX > deadzoneValue) {
                //if(!moveButtonLeft.isPressed && !buttonRight)
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
        currentDeviceTop.text = str
    }

    function stopMovement() {
        logic.send(stopCommand)
        console.log(qsTr("STOP"))
    }

    function centerMovement() {
        logic.send(centerCommand)
        console.log(qsTr("MIDDLE"))
    }

    ButtonGroup {
        id: controlButtonsGroup
        buttons: [
            currentGamepadTop.radioButton,
            currentTouchTop.radioButton
        ]
    }

    RowLayout {
        id: topMenu
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        height: 50
        spacing: 5

        MyIconLabel {
            id: currentDeviceTop
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: labelBackgroundColor
            image: "qrc:/images/bt_icon.png"
            text: qsTr("NULL")
        }
        MyIconRadioButtonLabel {
            id: currentGamepadTop
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: labelBackgroundColor
            image: "qrc:/images/gamepad_icon.png"
            text: qsTr("Not Connected")
            enabled: false
            radioButton.onCheckedChanged: {
                currentControlType = ControlWindow.ControlType.Gamepad
            }
        }
        MyIconRadioButtonLabel {
            id: currentTouchTop
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: labelBackgroundColor
            image: "qrc:/images/touch_icon.png"
            text: qsTr("Touch")
            radioButton.checked: true
            radioButton.onCheckedChanged: {
                currentControlType = ControlWindow.ControlType.Touch
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
                image: "qrc:/images/car_icon.png"
                onPressed: {
                    logic.send("4")
                    console.log(qsTr("LEFT"))
                }
                onReleased: {
                    if(moveButtonForward.isPressed || moveButtonBackward.isPressed) return
                    stopMovement()
                }
            }

            MoveButton {
                id: moveButtonRight
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("RIGHT")
                image: "qrc:/images/car_icon.png"
                mirror: true
                onPressed: {
                    logic.send(rightCommand)
                    console.log(qsTr("RIGHT"))
                }
                onReleased: {
                    if(moveButtonForward.isPressed || moveButtonBackward.isPressed) return
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
                    image: "qrc:/images/gaz_icon.png"
                    onPressed: {
                        logic.send(forwardCommand)
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
                    image: "qrc:/images/gaz_icon.png"
                    rotation: 180
                    onPressed: {
                        logic.send(backwardCommand)
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
