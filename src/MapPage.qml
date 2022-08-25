import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

RowLayout {
    id: navigatePage

    property string ip
    property bool cameraPause

    Layout.fillHeight: true
    Layout.fillWidth: true

    ColumnLayout{
        id: page1column1
        ImageLoader {
            id: map
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 5
            initialSource: "http://" + navigatePage.ip +":8080/snapshot?topic=/stretch_gui/map"
            pause: cameraPause
            fillmode: Image.Stretch

            property var robotPoint: Qt.point(0,0)
            property real robotRotation: 0.0
            property var press: Qt.point(0,0)

            // https://stackoverflow.com/questions/65803655/paint-arrow-with-qml
            Canvas {
              id: canvas
              anchors.fill: parent
              z: 5
              // Code to draw a simple arrow on TypeScript canvas got from https://stackoverflow.com/a/64756256/867349
              function arrow(context, fromx, fromy, tox, toy) {
                context.strokeStyle = "#FF00FF";
                context.lineWidth = 5;
                const dx = tox - fromx;
                const dy = toy - fromy;
                const headlen = Math.sqrt(dx * dx + dy * dy) * 0.3; // length of head in pixels
                const angle = Math.atan2(dy, dx);
                context.beginPath();
                context.moveTo(fromx, fromy);
                context.lineTo(tox, toy);
                context.stroke();
                context.beginPath();
                context.moveTo(tox - headlen * Math.cos(angle - Math.PI / 6), toy - headlen * Math.sin(angle - Math.PI / 6));
                context.lineTo(tox, toy );
                context.lineTo(tox - headlen * Math.cos(angle + Math.PI / 6), toy - headlen * Math.sin(angle + Math.PI / 6));
                context.stroke();
              }

              onPaint: {
                // Get the canvas context
                var ctx = getContext("2d");
                ctx.reset()
                arrow(ctx, map.press.x, map.press.y, ma.mouseX, ma.mouseY)
              }
            }

            Image {
                id: robot
                source: "/src/img/stretch-pixel-art.png"
                fillMode: Image.Stretch
                width: robot.sourceSize.width * (map.paintedWidth / map.sourceWidth) / 10
                height: robot.sourceSize.height * (map.paintedHeight / map.sourceHeight) / 10
                x: map.robotPoint.x * (map.paintedWidth / map.sourceWidth)
                y: map.robotPoint.y * (map.paintedHeight / map.sourceHeight)
                rotation: -(map.robotRotation * 180 / Math.PI) - 90

                function updatePosition() {
                    robot.x = map.robotPoint.x * (map.paintedWidth / map.sourceWidth)
                    robot.y = map.robotPoint.y * (map.paintedHeight / map.sourceHeight)
                    robot.rotation = -(map.robotRotation * 180 / Math.PI) - 90
                }

                Connections {
                    target: map
                    function onRobotPointChanged() {
                        robot.updatePosition()
                    }
                    function onRobotRotationChanged() {
                        robot.updatePosition()
                    }
                    function onSourceWidthChanged() {
                        robot.updatePosition()
                    }
                    function onSourceHeightChanged() {
                        robot.updatePosition()
                    }
                }
            }
            Connections {
                target: server
                function onRobotPose(point, rotation) {
//                            robot.x = point.x * (map.paintedWidth / map.sourceWidth)
//                            robot.y = point.y * (map.paintedHeight / map.sourceHeight)
//                            robot.rotation = -(rotation * 180 / Math.PI) - 90
                    map.robotPoint = point
                    map.robotRotation = rotation
                }
            }
            PinchHandler {
                id: pinch
                target: map
                minimumPointCount: 2
                onActiveChanged: () => {
                                     if(pinch.active){
                                         canvas.visible = false
                                     }
                                 }
            }

            MouseArea {
                id: ma
                anchors.fill: parent
                enabled: !pinch.active
                onPressed: (mouse)=> {
                    map.press = Qt.point(mouse.x, mouse.y)
                    canvas.visible = true
                }
                onMouseXChanged: canvas.requestPaint()
                onMouseYChanged: canvas.requestPaint()
                onReleased: (mouse)=> {
                    server.uiDisplayMapMouseClick(map.press, Qt.point(mouse.x, mouse.y), Qt.size(parent.width, parent.height))
                    canvas.visible = false
                }
            }
        }
    }
    ColumnLayout{
        id: page1column2
        Layout.alignment: Qt.AlignRight
        Layout.fillHeight: true
        Layout.maximumWidth: parent.width / 3
        Layout.rightMargin: 5
        Pane{
            id: pleaseWait
            Material.elevation: 6
            Material.background: Material.Red
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            opacity: 0
            Label{
                anchors.centerIn: parent
                text: qsTr("Please Wait for\nRobot to Move")
            }
            Connections {
                target: server
                function onUiPleaseWaitSetVisible(b: Boolean){
                    pleaseWait.opacity = b
                }
            }
        }
        Button{
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            text: qsTr("STOP")
            Material.background: Material.Red
            onClicked: {
                server.uiButtonStopClicked()
            }
        }
        RowLayout{
            Layout.alignment: Qt.AlignHCenter
            spacing: 2
            Button{
                text: qsTr("Set Home")
                Material.background: Material.Green
                Layout.fillHeight: true
                Layout.fillWidth: true
                onClicked: {
                    server.uiButtonSetHomeClicked()
                }
            }
            Button{
                id: goHome
                text: qsTr("Go Home")
                Material.background: Material.Green
                Layout.fillHeight: true
                Layout.fillWidth: true
                enabled: false
                onClicked: {
                    server.uiButtonNavigateHomeClicked()
                }

                Connections {
                    target: server
                    function onUiButtonNavigateHomeSetEnabled(){
                        goHome.enabled = true
                    }
                }
            }
        }
    }
}
