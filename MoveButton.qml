import QtQuick 2.0

Rectangle {
    id: btn

    border.width: 2
    border.color: "black"

    radius: width/5

    property alias text: btnText.text

    signal pressed()
    signal released()
    signal clicked()

    property bool isPressed: false

    onPressed: {
        btn.color = "lime"
        isPressed = true
    }

    onReleased: {
        btn.color = "white"
        isPressed = false
    }

    color: "white"

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Text {
        id: btnText
        anchors.centerIn: parent
        text: "null"
        font.pointSize: 14
    }

    MultiPointTouchArea {
        id: ma
        mouseEnabled: true
        maximumTouchPoints: 2
        anchors.fill: parent

        onPressed: {
            btn.pressed()
        }
        onReleased: {
            btn.released()
        }
        onCanceled: {
            btn.released()
        }
    }

//    MouseArea {
//        id: ma
//        anchors.fill: parent

//        onPressed: {
//            btn.pressed()
//        }
//        onReleased: {
//            btn.released()
//        }
//        onClicked: btn.clicked()
//    }

}
