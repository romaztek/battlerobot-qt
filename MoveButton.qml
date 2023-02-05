import QtQuick 2.7
import QtQuick.Layouts 1.3

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
        anchors.fill: parent
        Image {
            id: btnImage
            property real sizeScale: 2.5
            Layout.preferredWidth: sourceSize.width/sourceSize.height * prefHeight
            Layout.preferredHeight: prefHeight
            Layout.alignment: Qt.AlignHCenter
            mipmap: true
            smooth: true
            antialiasing: true
            property real prefHeight: btn.width > btn.height ? btn.height/sizeScale : btn.width/sizeScale
        }
        Text {
            id: btnText
            Layout.fillWidth: true
            text: "null"
            font.pointSize: 14
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MultiPointTouchArea {
        id: ma
        mouseEnabled: true
        maximumTouchPoints: 2
        anchors.fill: parent
        enabled: currentControlType === controlType.touch

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
