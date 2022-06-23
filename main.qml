import QtQuick 2.15
import QtQuick.Window 2.15
import QtLocation 5.12
import QtPositioning 5.12
import QtQuick.Shapes 1.1
import QtQuick.Controls 2.12

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: qsTr("Hello World")

    Plugin {
        id: mapPlugin
        name: "osm"
    }

    property bool tmpFlag: true
    property int errorСoefficientDistance: 3
    property int currentPolygon: 0
    property var tmpObject
    property var polygons: []
    property var circles: []
    property var circle
    property var line
    property var testLine
    property bool flagEditPolyLine: false

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    //createClassCircle
    function createClassCircle(/*index*/)
    {
        var tmpCircle = {
            circkles: [],
            arrayCoordinates: [],
            isClose: false
        };

        return tmpCircle;
    }

    function createPointCircle(x_coor, y_coor)
    {
        var tmpCircle = circle.createObject(map, {
                                                coor: map.toCoordinate(Qt.point(x_coor, y_coor)),
                                                index: window.polygons[window.currentPolygon].line.path.length,
                                                isMoveFirstElement: window.tmpFlag,
                                                parentIndex: currentPolygon,
                                                customWidth: (100 / 14) * map.zoomLevel
                                            });
        window.tmpFlag = false;

        information.coordinateChangeButton.connect(tmpCircle.onChangeCoorinateButton);
        map.zoomLevelChangedForChild.connect(tmpCircle.onParentZoomLevelChanged);
        tmpCircle.printCoordinate.connect(onPrintCoordinate);

        map.addMapItem(tmpCircle);
        return tmpCircle;
    }



    function createLine()
    {
        var tmpLine = window.testLine = line.createObject(map, {
                                                              parentIndex: currentPolygon
                                                          });

        return tmpLine;
    }

    function removePoint(tmpIndex)
    {
        window.polygons[window.currentPolygon].line.removeCoordinate(tmpIndex);

        if((window.polygons[window.currentPolygon].isClose) && (tmpIndex == 0))
        {
            var tmpPath = window.polygons[window.currentPolygon].line.path;
            tmpPath[tmpPath.length - 1] = tmpPath[0];
            window.polygons[window.currentPolygon].line.path = tmpPath;
        }

        map.removeMapItem(window.polygons[window.currentPolygon].circkles[tmpIndex]);
        window.polygons[window.currentPolygon].circkles.splice(tmpIndex,1);

        sortIndex();
    }

    function sortIndex()
    {
        for (var j=0; j < window.polygons[window.currentPolygon].circkles.length; j++)
        {
            window.polygons[window.currentPolygon].circkles[j].index = j;
        }
    }

    //createPath
    function createPath(x_coor, y_coor)
    {
        if (window.polygons[window.currentPolygon].line === undefined)
        {
            window.polygons[window.currentPolygon].line = window.createLine();

            var tmpCircle = window.createPointCircle(x_coor, y_coor);

            window.polygons[window.currentPolygon].circkles.push(tmpCircle);

            map.addMapItem(window.polygons[window.currentPolygon].line);

            window.polygons[window.currentPolygon].line.addCoordinate(map.toCoordinate(Qt.point(x_coor, y_coor)));

            return;
        }

        if (flagEditPolyLine)
        {
            var mousePixel = map.toCoordinate(Qt.point(x_coor, y_coor));

            for (var i = 0; i < window.polygons[window.currentPolygon].line.path.length-1; i++)
            {
                var pointStart = map.fromCoordinate(window.polygons[window.currentPolygon].line.path[i]);
                var pointEnd = map.fromCoordinate(window.polygons[window.currentPolygon].line.path[i+1]);

                var distance = Math.abs((pointEnd.y - pointStart.y) * x_coor - (pointEnd.x - pointStart.x) * y_coor + pointEnd.x*pointStart.y - pointEnd.y* pointStart.x) / Math.sqrt(Math.pow(pointEnd.y - pointStart.y,2) + Math.pow(pointEnd.x - pointStart.x,2));


                if (distance < window.errorСoefficientDistance)
                {
                    var tmpCircle = window.createPointCircle(x_coor, y_coor);

                    window.polygons[window.currentPolygon].line.insertCoordinate(i+1,map.toCoordinate(Qt.point(x_coor, y_coor)));
                    flagEditPolyLine = !flagEditPolyLine;

                    window.polygons[window.currentPolygon].circkles.splice(i+1, 0, tmpCircle);

                    window.sortIndex();

                    break;
                }
            }
            return;
        }

        var tmpCircle = window.createPointCircle(x_coor, y_coor);

        window.polygons[window.currentPolygon].circkles.push(tmpCircle);
        window.polygons[window.currentPolygon].line.addCoordinate(map.toCoordinate(Qt.point(x_coor, y_coor)));

        if (window.polygons[window.currentPolygon].circkles.length == 3 )
        {
            currentPolygon = window.polygons.length - 1
            window.polygons[window.currentPolygon].isClose = true;
            window.polygons[window.currentPolygon].line.addCoordinate(window.polygons[window.currentPolygon].line.path[0]);
            window.tmpObject = createClassCircle();

            polygons.push(window.tmpObject);
        }
    }

    Map {
        id: map
        anchors.fill: parent
        plugin: mapPlugin
        zoomLevel: 14

        center: QtPositioning.coordinate(59.939099, 30.315877); // Санкт-Петербург
        z: 0

        signal zoomLevelChangedForChild(var newZoomLevel);

        MouseArea{
            id: mouseMap

            anchors.fill: parent

            onClicked: {
                currentPolygon = polygons.length - 1

                if(polygons[currentPolygon].isClose)
                {
                    currentPolygon = polygons.length;
                }

                createPath(mouseMap.mouseX, mouseMap.mouseY);
            }

            onDoubleClicked: {

            }
        }

        onZoomLevelChanged:
        {
            zoomLevelChangedForChild(zoomLevel)
        }
    }

    Column{
        spacing: 10
    }

    function onPrintCoordinate(coordinate, index)
    {
        information.infoCoor = coordinate;
        information.infoIndex = index;
    }

    Rectangle{
        id: information

        property var infoCoor
        property var infoIndex: 0

        signal coordinateChangeButton(var newlatitude, var longitude, var index, var pol);

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 20
        anchors.topMargin: 20

        width: parent.width / 2.7
        height: 200
        color: "#7Fc0c0c0"
        radius: information.width / 10
        clip: true

        Column{
            anchors.centerIn: parent
            anchors.top: parent.top
            anchors.topMargin: 5
            spacing: 10

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Номер позиции "+ information.infoIndex
            }

            Row{
                anchors.right: information.right
                anchors.rightMargin: 5
                spacing: 5
                Text {
                    text: "Широта: "
                }

                TextField{
                    id: latitudeTextField
                    width: information.width / 4 * 3 - 5
                    text: information.infoCoor.latitude
                    selectByMouse: true
                }
            }

            Row{
                anchors.rightMargin: 5
                anchors.right: information.right
                spacing: 5

                Text {
                    text: "Долгота:"
                }

                TextField{
                    id: longitudeTextField
                    width: information.width / 4 * 3 -5
                    text: information.infoCoor.longitude
                    selectByMouse: true
                }
            }

            Button{
                anchors.horizontalCenter: parent.horizontalCenter
                id: acceptLatitude
                text: "Применить"

                onClicked: {
                    console.log("color", information.color)
                    information.coordinateChangeButton(latitudeTextField.text, longitudeTextField.text, information.infoIndex, currentPolygon);
                }
            }
        }
    }

    Component.onCompleted: {
        //        window.circle = Qt.createComponent("CircleMap.qml");
        window.circle = Qt.createComponent("PointMap.qml");
        window.line = Qt.createComponent("PolyLine.qml");

        window.tmpObject = createClassCircle();

        polygons.push(window.tmpObject);
    }
}
