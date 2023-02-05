import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3

import QtGamepad 1.0

import ru.romanlenz.logic 1.0

Rectangle {
    id: controlW
    anchors.fill: parent
    visible: false
    enabled: false
    focus: true

    color: backgroundColor



//    enum ControlType {
//        none,
//        Touch,
//        Gamepad
//    }

//    enum SteeringIntensity {
//        none,
//        Low,
//        Normal,
//        High,
//        Drift
//    }

    Component.onCompleted: {
        if(logic.hasTouchScreen()) {
            currentControlType = controlType.touch
            currentTouchTop.radioButton.checked = true
        }
    }

    property double deadzoneValue: 0.1

    property int currentControlType: controlType.touch
    property int currentIntensity: steeringIntensity.none

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

    Gamepad {
        id: gamepad
        deviceId: GamepadManager.connectedGamepads.length > 0 ? GamepadManager.connectedGamepads[0] : -1

        onConnectedChanged: {
            if(connected) {
                var gamePadName = logic.getGamepadName(gamepad.deviceId)
                currentGamepadTop.text = gamePadName.length === 0 ?  qsTr("Connected") : gamePadName
                currentControlType = controlType.gamepad
                currentGamepadTop.enabled = true
                currentGamepadTop.radioButton.checked = true
            } else {
                currentGamepadTop.text = qsTr("Not Connected")
                stopMovement()
                centerMovement()
                if(currentControlType === controlType.gamepad) {
                    currentControlType = controlType.touch
                    currentGamepadTop.enabled = false
                    currentGamepadTop.radioButton.checked = false
                }
            }
        }

        /*onButtonLeftChanged: {
            if(currentControlType !== controlType.gamepad) return
            if(buttonLeft) {
                if(!moveButtonRight.isPressed) {
                    if(currentIntensity !== steeringIntensity.drift) {
                        currentIntensity = steeringIntensity.drift
                        leftMovement()
                        driftButtonLeft.isPressed = true
                    }
                }
            } else {
                currentIntensity = steeringIntensity.none
                driftButtonLeft.released()
            }
        }

        onButtonRightChanged: {
            if(currentControlType !== controlType.gamepad) return
            if(buttonRight) {
                if(!moveButtonLeft.isPressed) {
                    if(currentIntensity !== steeringIntensity.drift) {
                        currentIntensity = steeringIntensity.drift
                        rightMovement()
                        driftButtonRight.isPressed = true
                    }
                }
            } else {
                currentIntensity = steeringIntensity.none
                driftButtonRight.released()
            }
        }*/

        onButtonR2Changed: {
            if(currentControlType !== controlType.gamepad) return
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
            if(currentControlType !== controlType.gamepad) return
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
            if(currentControlType !== controlType.gamepad) return

            var newIntensity

            // Left
            if(axisLeftX < -deadzoneValue) {
                moveButtonRight.isPressed = false

                if(axisLeftX > -0.4) {
                    newIntensity = steeringIntensity.low
                } else if(axisLeftX > -0.7) {
                    newIntensity = steeringIntensitynNormal
                } else {
                    newIntensity = steeringIntensity.high
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
                    newIntensity = steeringIntensity.low
                } else if(axisLeftX >= 0.4 && axisLeftX < 0.7) {
                    newIntensity = steeringIntensitynNormal
                } else {
                    newIntensity = steeringIntensity.high
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
                if(currentIntensity !== steeringIntensity.none) {
                    currentIntensity = steeringIntensity.none
                    centerMovement()
                }
                moveButtonLeft.isPressed = false
                moveButtonRight.isPressed = false
            }
        }

        onAxisRightXChanged: {
            if(currentControlType !== controlType.gamepad) return

            var newIntensity

            // Left Drift
            if(axisRightX < -deadzoneValue) {
                driftButtonRight.isPressed = false

                newIntensity = steeringIntensity.drift

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

                newIntensity = steeringIntensity.drift

                if(newIntensity !== currentIntensity) {
                    currentIntensity = newIntensity
                    rightMovement()
                }

                driftButtonRight.isPressed = true
                //myprint(newIntensity)
            }
            // In Deadzone
            else {
                if(currentIntensity !== steeringIntensity.none) {
                    currentIntensity = steeringIntensity.none
                    centerMovement()
                }
                driftButtonLeft.isPressed = false
                driftButtonRight.isPressed = false
            }
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
        case steeringIntensity.low:
            cmd = leftCommandLow
            print_intensity = qsTr("LOW")
            break
        case steeringIntensitynNormal:
            cmd = leftCommandNormal
            print_intensity = qsTr("NORMAL")
            break
        case steeringIntensity.high:
            cmd = leftCommandHigh
            print_intensity = qsTr("HIGH")
            break
        case steeringIntensity.drift:
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
        case steeringIntensity.low:
            cmd = rightCommandLow
            print_intensity = qsTr("LOW")
            break
        case steeringIntensitynNormal:
            cmd = rightCommandNormal
            print_intensity = qsTr("NORMAL")
            break
        case steeringIntensity.high:
            cmd = rightCommandHigh
            print_intensity = qsTr("HIGH")
            break
        case steeringIntensity.drift:
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
                currentControlType = controlType.gamepad
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
                currentControlType = controlType.touch
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
                settingsWindow.show()
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
                        currentIntensity = steeringIntensity.high
                        leftMovement()
                    }
                    onReleased: {
                        currentIntensity = steeringIntensity.none
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
                        currentIntensity = steeringIntensity.high
                        rightMovement()
                    }
                    onReleased: {
                        currentIntensity = steeringIntensity.none
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
                        currentIntensity = steeringIntensity.drift
                        leftMovement()
                    }
                    onReleased: {
                        currentIntensity = steeringIntensity.none
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
                        currentIntensity = steeringIntensity.drift
                        rightMovement()
                    }
                    onReleased: {
                        currentIntensity = steeringIntensity.none
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
