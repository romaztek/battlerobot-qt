import QtQuick 2.12
import QtQuick.Shapes 1.12

Shape {
    id: _line
    height: 2
    property alias color: _path.strokeColor
    ShapePath {
        id: _path
        strokeWidth: 2
        strokeColor: "black"
        startX: 0
        startY: 0
        PathLine { x: _line.width; y: 0 }
    }
}
