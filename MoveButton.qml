import QtQuick 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: btn

    border.width: 2
    border.color: "black"

    radius: topMenu.height/4

    property alias text: btnText.text
    property alias image: btnImage.source
    property alias mirror: btnImage.mirror
    property alias rotation: btnImage.rotation

    signal pressed()
    signal released()
    signal clicked()

    property bool isPressed: false

    onIsPressedChanged: {
        if(isPressed) {
            btn.color = highlightColor
        } else {
            btn.color = defaultColor
        }
    }

    onPressed: {
        isPressed = true
    }

    onReleased: {
        isPressed = false
    }

    color: defaultColor

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        Image {
            id: btnImage
            Layout.preferredWidth: sourceSize.width/sourceSize.height * btn.width/3
            Layout.preferredHeight: btn.width/3
            Layout.alignment: Qt.AlignHCenter
            mipmap: true
            smooth: true
            antialiasing: true
        }
        Text {
            id: btnText
            Layout.alignment: Qt.AlignHCenter
            text: "null"
            font.pointSize: 14
        }
    }

    MultiPointTouchArea {
        id: ma
        mouseEnabled: true
        maximumTouchPoints: 2
        anchors.fill: parent
        enabled: currentControlType === ControlWindow.ControlType.Touch

        onPressed: {
            btn.pressed()
            isPressed = true
        }
        onReleased: {
            btn.released()
            isPressed = false
        }
        onCanceled: {
            btn.released()
            isPressed = false
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
