import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: settingsW
    radius: 50/4
    border.color: "black"
    border.width: 2
    anchors.fill: parent
    visible: false
    enabled: false

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
            font.pointSize: 11
            x: 5
            verticalAlignment: Qt.AlignVCenter
            text: qsTr("Settings")
        }

        MyIconButton {
            id: saveButton
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
        anchors.topMargin: 5
        color: "black"
        width: parent.width
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


    }

}





