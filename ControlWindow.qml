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

    enum SteeringIntensity {
        None,
        Low,
        Normal,
        High
    }

    Component.onCompleted: {
        if(logic.hasTouchScreen()) {
            currentControlType = ControlWindow.ControlType.Touch
            currentTouchTop.radioButton.checked = true
        }
    }

    property double deadzoneValue: 0.1

    property int currentControlType: ControlWindow.ControlType.Touch
    property int currentIntensity: ControlWindow.SteeringIntensity.None


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
                currentGamepadTop.radioButton.checked = true
            } else {
                currentGamepadTop.text = qsTr("Not Connected")
                stopMovement()
                centerMovement()
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
                if(!moveButtonRight.isPressed) {
                    if(currentIntensity !== ControlWindow.SteeringIntensity.High) {
                        currentIntensity = ControlWindow.SteeringIntensity.High
                        leftMovement()
                        moveButtonLeft.isPressed = true
                    }
                }
            } else {
                currentIntensity = ControlWindow.SteeringIntensity.None
                moveButtonLeft.released()
            }
        }

        onButtonRightChanged: {
            if(currentControlType !== ControlWindow.ControlType.Gamepad) return
            if(buttonRight) {
                if(!moveButtonLeft.isPressed) {
                    if(currentIntensity !== ControlWindow.SteeringIntensity.High) {
                        currentIntensity = ControlWindow.SteeringIntensity.High
                        rightMovement()
                        moveButtonRight.isPressed = true
                    }
                }
            } else {
                currentIntensity = ControlWindow.SteeringIntensity.None
                moveButtonRight.released()
            }
        }

        onButtonR2Changed: {
            if(currentControlType !== ControlWindow.ControlType.Gamepad) return
            if(buttonR2) {
                if(moveButtonBackward.isPressed)
                    moveButtonBackward.released()
                if(!moveButtonForward.isPressed)
                    moveButtonForward.pressed()
            } else {
                if(moveButtonForward.isPressed && !moveButtonBackward.isPressed)
                    moveButtonForward.released()
            }
        }

        onButtonL2Changed: {
            if(currentControlType !== ControlWindow.ControlType.Gamepad) return
            if(buttonL2) {
                if(moveButtonForward.isPressed)
                    moveButtonForward.released()
                if(!moveButtonBackward.isPressed)
                    moveButtonBackward.pressed()
            } else {
                if(moveButtonBackward.isPressed && !moveButtonForward.isPressed)
                    moveButtonBackward.released()
            }
        }

        onAxisLeftXChanged: {
            if(currentControlType !== ControlWindow.ControlType.Gamepad) return

            var newIntensity

            // Left
            if(axisLeftX < -deadzoneValue) {
                moveButtonRight.isPressed = false

                if(axisLeftX > -0.4) {
                    newIntensity = ControlWindow.SteeringIntensity.Low
                } else if(axisLeftX > -0.7) {
                    newIntensity = ControlWindow.SteeringIntensity.Normal
                } else {
                    newIntensity = ControlWindow.SteeringIntensity.High
                }

                //if(newIntensity !== currentIntensity)
                    leftMovement()
                currentIntensity = newIntensity

                moveButtonLeft.isPressed = true
                console.log(newIntensity)
            }
            // Right
            else if(axisLeftX > deadzoneValue) {
                moveButtonLeft.isPressed = false

                if(axisLeftX > 0.1 && axisLeftX < 0.4) {
                    newIntensity = ControlWindow.SteeringIntensity.Low
                } else if(axisLeftX >= 0.4 && axisLeftX < 0.7) {
                    newIntensity = ControlWindow.SteeringIntensity.Normal
                } else {
                    newIntensity = ControlWindow.SteeringIntensity.High
                }

                //if(newIntensity !== currentIntensity)
                    rightMovement()
                currentIntensity = newIntensity

                moveButtonRight.isPressed = true
                console.log(newIntensity)
            }
            // In Deadzone
            else {
                if(currentIntensity !== ControlWindow.SteeringIntensity.None) {
                    currentIntensity = ControlWindow.SteeringIntensity.None
                    centerMovement()
                }
                moveButtonLeft.isPressed = false
                moveButtonRight.isPressed = false
            }
        }
    }

    Connections {
        target: GamepadManager
        function onGamepadConnected() {
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

    function leftMovement() {
        const print_dir = qsTr("LEFT")
        var print_intensity
        var cmd
        switch(currentIntensity) {
        case ControlWindow.SteeringIntensity.Low:
            cmd = leftCommandLow
            print_intensity = qsTr("LOW")
            break
        case ControlWindow.SteeringIntensity.Normal:
            cmd = leftCommandNormal
            print_intensity = qsTr("NORMAL")
            break
        case ControlWindow.SteeringIntensity.High:
            cmd = leftCommandHigh
            print_intensity = qsTr("HIGH")
            break
        default:
            cmd = leftCommandLow
            print_intensity = qsTr("LOW")
        }
        logic.send(cmd)
        console.log(print_dir + " " + print_intensity)
    }

    function rightMovement() {
        const print_dir = qsTr("RIGHT")
        var print_intensity
        var cmd
        switch(currentIntensity) {
        case ControlWindow.SteeringIntensity.Low:
            cmd = rightCommandLow
            print_intensity = qsTr("LOW")
            break
        case ControlWindow.SteeringIntensity.Normal:
            cmd = rightCommandNormal
            print_intensity = qsTr("NORMAL")
            break
        case ControlWindow.SteeringIntensity.High:
            cmd = rightCommandHigh
            print_intensity = qsTr("HIGH")
            break
        default:
            cmd = rightCommandLow
            print_intensity = qsTr("LOW")
        }
        logic.send(cmd)
        console.log(print_dir + " " + print_intensity)
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
            color: text !== qsTr("Reconnect?") && text !== qsTr("NULL") ? labelBackgroundColor : "grey"
            image: text !== qsTr("Reconnect?") ? "qrc:/images/bt_icon.png" : "qrc:/images/refresh_icon.png"
            text: qsTr("NULL")
            MouseArea {
                id: ma
                anchors.fill: parent
                enabled: currentDeviceTop.text === qsTr("Reconnect?")
                onClicked: {
                    logic.connectToDevice(connectWindow.connectedDeviceAddress)
                }
            }
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
                    currentIntensity = ControlWindow.SteeringIntensity.High
                    leftMovement()
                }
                onReleased: {
                    currentIntensity = ControlWindow.SteeringIntensity.None
                    centerMovement()
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
                    currentIntensity = ControlWindow.SteeringIntensity.High
                    rightMovement()
                }
                onReleased: {
                    currentIntensity = ControlWindow.SteeringIntensity.None
                    centerMovement()
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
