import QtQuick 2.12
import QtQuick.Controls 2.12

BusyIndicator {
    id: _loadingCircleIndicator
    width: 50
    height: 50

    property color circleColor: "black"

    contentItem: Item {
        implicitWidth: _loadingCircleIndicator.width
        implicitHeight: _loadingCircleIndicator.height

        Item {
            id: item
            x: (parent.width - width)/2
            y: (parent.height - height)/2
            width: _loadingCircleIndicator.width
            height: _loadingCircleIndicator.height

            RotationAnimator {
                target: item
                running: _loadingCircleIndicator.visible && _loadingCircleIndicator.running
                from: 0
                to: 360
                loops: Animation.Infinite
                duration: 1250
            }

            Repeater {
                id: repeater
                model: 6

                Rectangle {
                    x: item.width / 2 - width / 2
                    y: item.height / 2 - height / 2
                    implicitWidth: _loadingCircleIndicator.width/5
                    implicitHeight: _loadingCircleIndicator.height/5
                    radius: 5
                    color: circleColor
                    transform: [
                        Translate {
                            y: -Math.min(item.width, item.height) * 0.5 + _loadingCircleIndicator.width/10
                        },
                        Rotation {
                            angle: index / repeater.count * 360
                            origin.x: _loadingCircleIndicator.width/10
                            origin.y: _loadingCircleIndicator.width/10
                        }
                    ]
                }
            }
        }
    }
}
