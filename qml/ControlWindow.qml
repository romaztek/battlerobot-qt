import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3

import QtGamepad 1.0

import ru.romankartashev.logic 1.0

import ru.romankartashev.enums 1.0

Rectangle {
    id: controlW
    anchors.fill: parent
    focus: true

    color: backgroundColor

    Component.onCompleted: {
        if(logic.hasTouchScreen()) {
            currentControlType = ControlType.TOUCH
            currentTouchTop.radioButton.checked = true
        }
    }

    property double deadzoneValue: 0.1

    property int currentControlType: ControlType.TOUCH
    property int currentIntensity: SteeringIntensity.NONE

    property bool enableLogs: true

    function myprint(value) {
        if(enableLogs) console.log(value)
    }

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


    Connections {
        target: logic
        function onDeviceConnected() {
            setDeviceName(connectedDeviceName)
        }

        function onDeviceDisconnected() {
            setDeviceName(qsTr("Reconnect?"))
        }
    }

    Gamepad {
        id: gamepad
        deviceId: GamepadManager.connectedGamepads.length > 0 ? GamepadManager.connectedGamepads[0] : -1

        onConnectedChanged: {
            if(connected) {
                var gamePadName = logic.getGamepadName(gamepad.deviceId)
                currentGamepadTop.text = gamePadName.length === 0 ?  qsTr("Connected") : gamePadName
                currentControlType = ControlType.GAMEPAD
                currentGamepadTop.enabled = true
                currentGamepadTop.radioButton.checked = true
            } else {
                currentGamepadTop.text = qsTr("Not Connected")
                stopMovement()
                centerMovement()
                if(currentControlType === ControlType.GAMEPAD) {
                    currentControlType = ControlType.TOUCH
                    currentGamepadTop.enabled = false
                    currentGamepadTop.radioButton.checked = false
                }
            }
        }

        /*onButtonLeftChanged: {
            if(currentControlType !== ControlType.GAMEPAD) return
            if(buttonLeft) {
                if(!moveButtonRight.isPressed) {
                    if(currentIntensity !== SteeringIntensity.TURN) {
                        currentIntensity = SteeringIntensity.TURN
                        leftMovement()
                        driftButtonLeft.isPressed = true
                    }
                }
            } else {
                currentIntensity = SteeringIntensity.NONE
                driftButtonLeft.released()
            }
        }

        onButtonRightChanged: {
            if(currentControlType !== ControlType.GAMEPAD) return
            if(buttonRight) {
                if(!moveButtonLeft.isPressed) {
                    if(currentIntensity !== SteeringIntensity.TURN) {
                        currentIntensity = SteeringIntensity.TURN
                        rightMovement()
                        driftButtonRight.isPressed = true
                    }
                }
            } else {
                currentIntensity = SteeringIntensity.NONE
                driftButtonRight.released()
            }
        }*/

        onButtonR2Changed: {
            if(currentControlType !== ControlType.GAMEPAD) return
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
            if(currentControlType !== ControlType.GAMEPAD) return
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
            if(currentControlType !== ControlType.GAMEPAD) return

            var newIntensity

            // Left
            if(axisLeftX < -deadzoneValue) {
                moveButtonRight.isPressed = false

                if(axisLeftX > -0.4) {
                    newIntensity = SteeringIntensity.LOW
                } else if(axisLeftX > -0.7) {
                    newIntensity = SteeringIntensity.NORMAL
                } else {
                    newIntensity = SteeringIntensity.HIGH
                }

                if(newIntensity !== currentIntensity) {
                    currentIntensity = newIntensity
                    leftMovement()
                }

                moveButtonLeft.isPressed = true
                //myprint(newIntensity)
            }
            // Right
            else if(axisLeftX > deadzoneValue) {
                moveButtonLeft.isPressed = false

                if(axisLeftX > 0.1 && axisLeftX < 0.4) {
                    newIntensity = SteeringIntensity.LOW
                } else if(axisLeftX >= 0.4 && axisLeftX < 0.7) {
                    newIntensity = SteeringIntensity.NORMAL
                } else {
                    newIntensity = SteeringIntensity.HIGH
                }

                if(newIntensity !== currentIntensity) {
                    currentIntensity = newIntensity
                    rightMovement()
                }

                moveButtonRight.isPressed = true
                //myprint(newIntensity)
            }
            // In Deadzone
            else {
                if(currentIntensity !== SteeringIntensity.NONE) {
                    currentIntensity = SteeringIntensity.NONE
                    centerMovement()
                }
                moveButtonLeft.isPressed = false
                moveButtonRight.isPressed = false
            }
        }

        onAxisRightXChanged: {
            if(currentControlType !== ControlType.GAMEPAD) return

            var newIntensity

            // Left Drift
            if(axisRightX < -deadzoneValue) {
                driftButtonRight.isPressed = false

                newIntensity = SteeringIntensity.TURN

                if(newIntensity !== currentIntensity) {
                    currentIntensity = newIntensity
                    leftMovement()
                }

                driftButtonLeft.isPressed = true
                //myprint(newIntensity)
            }
            // Right Drift
            else if(axisRightX > deadzoneValue) {
                driftButtonLeft.isPressed = false

                newIntensity = SteeringIntensity.TURN

                if(newIntensity !== currentIntensity) {
                    currentIntensity = newIntensity
                    rightMovement()
                }

                driftButtonRight.isPressed = true
                //myprint(newIntensity)
            }
            // In Deadzone
            else {
                if(currentIntensity !== SteeringIntensity.NONE) {
                    currentIntensity = SteeringIntensity.NONE
                    centerMovement()
                }
                driftButtonLeft.isPressed = false
                driftButtonRight.isPressed = false
            }
        }
    }

    function setDeviceName(str) {
        currentDeviceTop.text = str
    }

    function stopMovement() {
        logic.send(stopCommand)
        myprint(qsTr("STOP"))
    }

    function centerMovement() {
        logic.send(centerCommand)
        myprint(qsTr("MIDDLE"))
    }

    function leftMovement() {
        const print_dir = qsTr("LEFT")
        var print_intensity
        var cmd
        switch(currentIntensity) {
        case SteeringIntensity.LOW:
            cmd = leftCommandLow
            print_intensity = qsTr("LOW")
            break
        case SteeringIntensity.NORMAL:
            cmd = leftCommandNormal
            print_intensity = qsTr("NORMAL")
            break
        case SteeringIntensity.HIGH:
            cmd = leftCommandHigh
            print_intensity = qsTr("HIGH")
            break
        case SteeringIntensity.TURN:
            cmd = leftCommandDrift
            print_intensity = qsTr("DRIFT")
            break
        default:
            cmd = leftCommandLow
            print_intensity = qsTr("LOW")
        }
        logic.send(cmd)
        myprint(print_dir + " " + print_intensity)
    }

    function rightMovement() {
        const print_dir = qsTr("RIGHT")
        var print_intensity
        var cmd
        switch(currentIntensity) {
        case SteeringIntensity.LOW:
            cmd = rightCommandLow
            print_intensity = qsTr("LOW")
            break
        case SteeringIntensity.NORMAL:
            cmd = rightCommandNormal
            print_intensity = qsTr("NORMAL")
            break
        case SteeringIntensity.HIGH:
            cmd = rightCommandHigh
            print_intensity = qsTr("HIGH")
            break
        case SteeringIntensity.TURN:
            cmd = rightCommandDrift
            print_intensity = qsTr("DRIFT")
            break
        default:
            cmd = rightCommandLow
            print_intensity = qsTr("LOW")
        }
        logic.send(cmd)
        myprint(print_dir + " " + print_intensity)
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
                currentControlType = ControlType.GAMEPAD
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
                currentControlType = ControlType.TOUCH
            }
        }

        MyIconButton {
            id: settingsButton
            Layout.minimumWidth: 50
            Layout.fillHeight: true
            imageSource: "qrc:/images/settings_icon.png"
            color: Qt.lighter("green", 1.3)
            onPressed: color = "green"
            onReleased: color = Qt.lighter("green", 1.3)
            onClicked: {
                createSettingsWindow()
            }
        }

        MyIconButton {
            id: exitButton
            Layout.minimumWidth: 50
            Layout.fillHeight: true
            imageSource: "qrc:/images/quit_icon.png"
            color: Qt.lighter("red", 1.3)
            onPressed: color = Qt.darker("red", 1.1)
            onReleased: color = Qt.lighter("red", 1.3)
            onClicked: {
                quitDialog.show()
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
            id: controlRowLayout
            anchors.bottom: parent.bottom
            height: parent.height
            width: parent.width
            spacing: 5

            Item {
                id: moveButtons
                Layout.preferredWidth: controlRowLayout.width/3
                Layout.preferredHeight: controlRowLayout.height
                Layout.maximumWidth: controlRowLayout.width/3
                Layout.maximumHeight: controlRowLayout.height

                property real spacing: 5
                property real elementWidth: (width - spacing)/2
                property real topElementHeight: (height - spacing)/3*2
                property real bottomElementHeight: (height - spacing)/3

                MoveButton {
                    id: moveButtonLeft
                    width: moveButtons.elementWidth
                    height: moveButtons.topElementHeight
                    anchors.top: parent.top

                    text: qsTr("LEFT")
                    image: "qrc:/images/arrow_icon.png"
                    onPressed: {
                        currentIntensity = SteeringIntensity.HIGH
                        leftMovement()
                    }
                    onReleased: {
                        currentIntensity = SteeringIntensity.NONE
                        centerMovement()
                    }
                }

                MoveButton {
                    id: moveButtonRight
                    width: moveButtons.elementWidth
                    height: moveButtons.topElementHeight
                    anchors.left: moveButtonLeft.right
                    anchors.leftMargin: 5
                    anchors.top: parent.top

                    text: qsTr("RIGHT")
                    image: "qrc:/images/arrow_icon.png"
                    mirror: true
                    onPressed: {
                        currentIntensity = SteeringIntensity.HIGH
                        rightMovement()
                    }
                    onReleased: {
                        currentIntensity = SteeringIntensity.NONE
                        centerMovement()
                    }
                }
                MoveButton {
                    id: driftButtonLeft
                    width: moveButtons.elementWidth
                    height: moveButtons.bottomElementHeight
                    anchors.top:  moveButtonLeft.bottom
                    anchors.topMargin: 5
                    anchors.bottom: parent.bottom

                    text: qsTr("LEFT")
                    image: "qrc:/images/car_icon.png"
                    onPressed: {
                        currentIntensity = SteeringIntensity.TURN
                        leftMovement()
                    }
                    onReleased: {
                        currentIntensity = SteeringIntensity.NONE
                        centerMovement()
                    }
                }

                MoveButton {
                    id: driftButtonRight
                    width: moveButtons.elementWidth
                    height: moveButtons.bottomElementHeight
                    anchors.left: driftButtonLeft.right
                    anchors.leftMargin: 5
                    anchors.top:  moveButtonRight.bottom
                    anchors.topMargin: 5
                    anchors.bottom: parent.bottom

                    text: qsTr("RIGHT")
                    image: "qrc:/images/car_icon.png"
                    mirror: true
                    onPressed: {
                        currentIntensity = SteeringIntensity.TURN
                        rightMovement()
                    }
                    onReleased: {
                        currentIntensity = SteeringIntensity.NONE
                        centerMovement()
                    }
                }
            }

            ColumnLayout {
                height: 200
                spacing: 5
                Layout.preferredHeight: controlRowLayout.height
                Layout.maximumHeight: controlRowLayout.height
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
                        myprint(qsTr("FORWARD"))
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
                        myprint(qsTr("BACKWARD"))
                    }
                    onReleased: {
                        stopMovement()
                    }
                }
            }
        }

    }

    QuitDialog {
        id: quitDialog
        width: exitButton.width * 2 + topMenu.spacing*3
        height: exitButton.height + topMenu.spacing*2
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: topMenu.spacing
    }
}
