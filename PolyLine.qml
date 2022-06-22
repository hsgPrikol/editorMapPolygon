import QtQuick 2.15
import QtQuick.Window 2.15
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Shapes 1.1

MapPolyline{
    id: lines
    line.width: mousePolyLine.containsMouse ? 13 : 7
    line.color: "black"
    property int parentIndex: -1

    MouseArea {
        id: mousePolyLine
        anchors.fill: parent
        preventStealing: false

        onClicked: {
            flagEditPolyLine = !flagEditPolyLine;
            currentPolygon = parentIndex

            createPath(mousePolyLine.mouseX + lines.x, mousePolyLine.mouseY + lines.y);
        }
    }
}
