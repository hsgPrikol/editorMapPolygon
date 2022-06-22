import QtQuick 2.15
import QtQuick.Window 2.15
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Shapes 1.1

MapCircle {
    id: mapItem
    z: 1
    radius: 200
    border.width: 2
    border.color: "black"
    color: "green"

    property var coor
    property int index: 0
    property int parentIndex: -1

    // Этот флаг для пересчитывания центра первой и последний координаты полигона.
    property bool isMoveFirstElement: false

    center: coor

    property bool isCreate: true

    MouseArea {
        id: mouseCircle
        anchors.fill: parent
        drag.target: parent

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: {
            if (mouse.button == Qt.RightButton)
            {
                console.log("remove");
                removePoint(index);

            }
            else if (mouse.button == Qt.LeftButton)
            {
                console.log(index);
            }
        }

        onPressed: {
            currentPolygon = parentIndex;
        }
    }

    onCenterChanged: {
        if(!isCreate)
        {
            polygons[currentPolygon].arrayCoordinates = polygons[currentPolygon].line.path;
            polygons[currentPolygon].arrayCoordinates[index] = center;

            if (polygons[currentPolygon].isClose && index === 0)
            {
                polygons[currentPolygon].arrayCoordinates[polygons[currentPolygon].arrayCoordinates.length-1] = center
            }

            polygons[currentPolygon].line.path = polygons[currentPolygon].arrayCoordinates;
        }
    }

    Component.onCompleted: {
        isCreate = false;
    }
}
