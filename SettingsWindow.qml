import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle {
    id: settingsW
    radius: 50/4
    border.color: "black"
    border.width: 2
    anchors.fill: parent
    visible: false
    enabled: false

    MouseArea {
        anchors.fill: parent
    }

    function show() {
        settingsW.visible = true
        settingsW.enabled = true
    }

    function hide() {
        settingsW.visible = false
        settingsW.enabled = false
    }

    RowLayout {
        id: topMenu
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        height: 50
        spacing: 5

        Text {
            id: settingsText
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pointSize: 14
            x: 5
            verticalAlignment: Qt.AlignVCenter
            text: qsTr("Settings")
        }

        MyIconButton {
            id: saveButton
            visible: false
            enabled: false
            Layout.minimumWidth: 50
            Layout.fillHeight: true
            imageSource: "qrc:/images/save_icon.png"
            color: Qt.lighter("green", 1.3)
            onPressed: color = "green"
            onReleased: color = Qt.lighter("green", 1.3)
            onClicked: {
            }

        }
        MyIconButton {
            id: backButton
            Layout.minimumWidth: 50
            Layout.fillHeight: true
            imageSource: "qrc:/images/back_icon.png"
            color: Qt.lighter("red", 1.3)
            onPressed: color = Qt.darker("red", 1.1)
            onReleased: color = Qt.lighter("red", 1.3)
            onClicked: {
                hide()
            }
        }
    }

    Line {
        id: sepLine
        anchors.top: topMenu.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        color: "black"
        height: 2
    }

    Item {
        id: layoutSettings
        anchors.top: sepLine.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 5
        anchors.topMargin: 0

        Text {
            id: speedText
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 5
            height: 50
            font.pointSize: 14
            text: qsTr("Speed")
            verticalAlignment: Qt.AlignVCenter
        }

        Slider {
            id: speedSlider
            anchors.left: speedText.right
            anchors.top: parent.top
            anchors.right: speedValueText.left
            anchors.margins: 5
            height: 50
            value: 11
            from: 1
            to: 11
            stepSize: 1
            onValueChanged: {
                var cmd
                switch(value) {
                case 1:
                    cmd = 'z'
                    break
                case 2:
                    cmd = 'x'
                    break
                case 3:
                    cmd = 'c'
                    break
                case 4:
                    cmd = 'v'
                    break
                case 5:
                    cmd = 'b'
                    break
                case 6:
                    cmd = 'n'
                    break
                case 7:
                    cmd = 'm'
                    break
                case 8:
                    cmd = '<'
                    break
                case 9:
                    cmd = '>'
                    break
                case 10:
                    cmd = '/'
                    break
                case 11:
                    cmd = '='
                    break
                default:
                    cmd = '='
                }
                controlWindow.myprint(value.toString() + ": " + cmd)
                logic.send(cmd)
            }
        }

        Text {
            id: speedValueText
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 5
            width: 40
            height: 50
            font.pointSize: 14
            text: (35 + speedSlider.value*20).toString()
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
        }
    }


    Text {
        text: "2023 (c) Roman Kartashev " + "\nSource: " + "https://github.com/romaztek/battlerobot-qt"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 5
        verticalAlignment: Qt.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter
        height: 40
        font.pointSize: 12
        onLinkActivated: Qt.openUrlExternally("https://github.com/romaztek/battlerobot-qt")
    }

}





