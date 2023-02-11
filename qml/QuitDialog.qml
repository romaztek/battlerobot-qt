import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle {
    id: dialog
    border.width: 2
    radius: topMenu.height/4
    enabled: false
    visible: false

    function show() {
        enabled = true
        visible = true
    }

    function hide() {
        enabled = false
        visible = false
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5
        MyIconButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            imageSource: "qrc:/images/yes_icon.png"
            color: Qt.lighter("green", 1.3)
            onPressed: color = "green"
            onReleased: color = Qt.lighter("green", 1.3)
            onClicked: Qt.quit()
        }
        MyIconButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            imageSource: "qrc:/images/no_icon.png"
            color: Qt.lighter("red", 1.3)
            onPressed: color = "red"
            onReleased: color = Qt.lighter("red", 1.3)
            onClicked: hide()
        }
    }
}
