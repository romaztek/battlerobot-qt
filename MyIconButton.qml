import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: iconButton
    width: 50
    height: 50
    color: _ma.pressed ? "#d6d6d6" : "#f6f6f6"
    border.color: "#26282a"
    border.width: 2
    radius: height/4

    property alias text: _txt.text
    property alias imageSource: _img.source
    property alias fontSize: _txt.font.pointSize
    property bool noImage: false
    property bool centerAlignment: true

    signal clicked()
    signal pressed()
    signal released()
    signal pressAndHold()

    Item {
        x: centerAlignment ? (iconButton.width - (_img.width + _txt.width + 10))/2 : 0
        Image {
            id: _img
            x: 5
            y: 5
            width: noImage ? 0 : iconButton.height - 10
            height: noImage ? 0 : iconButton.height - 10
            source: "qrc:/images/bt_icon.png"
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }
        Text {
            id: _txt
            font.pointSize: 12
            text: ""
            anchors.left: _img.right
            anchors.margins: 5
            x: (iconButton.width - contentWidth)/2
            y: (iconButton.height - contentHeight)/2
        }
    }

    MouseArea {
        id: _ma
        anchors.fill: parent
        onClicked: iconButton.clicked()
        onPressed: iconButton.pressed()
        onReleased: iconButton.released()
        onPressAndHold: iconButton.pressAndHold()
    }


}
