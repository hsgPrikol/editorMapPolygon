import QtQuick 2.15
import QtQuick.Window 2.15
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Shapes 1.1

MapQuickItem {
    id: root
    z: 1
    property var coor
    property int dfltWidth: 100
    property int customWidth: 100

    anchorPoint.x: customWidth / 2
    anchorPoint.y: customWidth / 2

    signal printCoordinate(var coord, var index);

    function onParentZoomLevelChanged(newZoomLevel){
        customWidth = (dfltWidth / 14) * newZoomLevel
    }

    function onChangeCoorinateButton(newLatitude, newLongitude, currentIndex, currentPol)
    {
        if ((currentIndex == index) && (currentPol == parentIndex))
            coordinate = QtPositioning.coordinate(newLatitude, newLongitude);
        else
            console.log("~~~~~~~~~~~~~~~~~~");
    }

    sourceItem: Rectangle {
        id: rectangle

        width: customWidth
        height: width
        radius: width/2
        opacity: 0.8
        color: "green"
        border.width: 3

        Text {
            anchors.centerIn: parent
            text: index
        }
    }

    property int index: 0
    property int parentIndex: -1

    // Этот флаг для пересчитывания центра первой и последний координаты полигона.
    property bool isMoveFirstElement: false

    coordinate: coor

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

            }
        }

        onPressed: {
            currentPolygon = parentIndex;
            printCoordinate(coordinate, root.index);
        }
    }

    onCoordinateChanged: {
        if(!isCreate)
        {
            polygons[currentPolygon].arrayCoordinates = polygons[currentPolygon].line.path;
            polygons[currentPolygon].arrayCoordinates[index] = coordinate;

            if (polygons[currentPolygon].isClose && index === 0)
            {
                polygons[currentPolygon].arrayCoordinates[polygons[currentPolygon].arrayCoordinates.length-1] = coordinate
            }

            polygons[currentPolygon].line.path = polygons[currentPolygon].arrayCoordinates;
        }
        printCoordinate(coordinate, root.index);
    }

    Component.onCompleted: {
        isCreate = false;
    }
}
