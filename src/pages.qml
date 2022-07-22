import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts
import QtMultimedia 5.0

// https://forum.qt.io/topic/42428/refreshing-remote-image-source-without-flickering-resp-empty-image-during-refresh

ColumnLayout {
    RowLayout {
        Button {
            id: cameraButton
            text: qsTr("Camera")
            onClicked: () => {
                           mainLayout.currentIndex = 0
                       }
        }
        Button {
            id: navigateButton
            text: qsTr("Navigate")
            onClicked: () => {
                           mainLayout.currentIndex = 1
                           server.changeToNavigation()
                       }
        }
        Button {
            id: graspButton
            text: qsTr("Grasp")
            onClicked: () => {
                           mainLayout.currentIndex = 2
                           server.uiGrasp()
                       }
            Connections {
                target: server
                function onUiPleaseWaitSetVisible(b: Boolean){
                    graspButton.enabled = !b
                }
            }

        }
    }

    StackLayout {
        id: mainLayout
        currentIndex: 1

        Component.onCompleted: server.changeToNavigation()


        // Camera
        ImageLoader {
            id: camera
            Layout.fillHeight: true
            Layout.fillWidth: true
            initialSource: "http://" + appWindow.ip +":8080/snapshot?topic=/stretch_gui/image"
            pause: true

            Connections {
                target: mainLayout
                function onCurrentIndexChanged() {
                                            if(mainLayout.currentIndex === 0){
                                                camera.unpauseFeed()
                                            } else {
                                                camera.pauseFeed()
                                            }
                                       }
            }
        }

        // Navigate
        RowLayout {
            id: page1
            Layout.fillHeight: true
            Layout.fillWidth: true

            ColumnLayout{
                id: page1column1
                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Click a Point to Move Stretch")
                }

                ImageLoader {
                    id: map
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: 5
                    initialSource: "http://" + appWindow.ip +":8080/snapshot?topic=/stretch_gui/map"
                    pause: false
                    fillmode: Image.Stretch

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
                    }

                    Connections {
                        target: mainLayout
                        function onCurrentIndexChanged() {
                                                    if(mainLayout.currentIndex === 1){
                                                        map.unpauseFeed()
                                                    } else {
                                                        map.pauseFeed()
                                                    }
                                               }
                    }
                    Connections {
                        target: server
                        function onRobotPose(point, rotation) {
                            robot.x = point.x * (map.paintedWidth / map.sourceWidth)
                            robot.y = point.y * (map.paintedHeight / map.sourceHeight)
                            robot.rotation = -(rotation * 180 / Math.PI) - 90
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
//                Rectangle {
//                    id: displayMap
//                    Layout.fillHeight: true
//                    Layout.fillWidth: true
//                    property var press: Qt.point(0,0)
//                    property int imageVisible: 1
//                    property string initialSource
//                    Layout.margins: 5

//                    color: "transparent"

//                    // https://stackoverflow.com/questions/65803655/paint-arrow-with-qml
//                    Canvas {
//                      id: canvas
//                      anchors.fill: parent
//                      z: 5
//                      // Code to draw a simple arrow on TypeScript canvas got from https://stackoverflow.com/a/64756256/867349
//                      function arrow(context, fromx, fromy, tox, toy) {
//                        context.strokeStyle = "#FF00FF";
//                        context.lineWidth = 5;
//                        const dx = tox - fromx;
//                        const dy = toy - fromy;
//                        const headlen = Math.sqrt(dx * dx + dy * dy) * 0.3; // length of head in pixels
//                        const angle = Math.atan2(dy, dx);
//                        context.beginPath();
//                        context.moveTo(fromx, fromy);
//                        context.lineTo(tox, toy);
//                        context.stroke();
//                        context.beginPath();
//                        context.moveTo(tox - headlen * Math.cos(angle - Math.PI / 6), toy - headlen * Math.sin(angle - Math.PI / 6));
//                        context.lineTo(tox, toy );
//                        context.lineTo(tox - headlen * Math.cos(angle + Math.PI / 6), toy - headlen * Math.sin(angle + Math.PI / 6));
//                        context.stroke();
//                      }

//                      onPaint: {
//                        // Get the canvas context
//                        var ctx = getContext("2d");
//                        ctx.reset()
//                        arrow(ctx, displayMap.press.x, displayMap.press.y, ma.mouseX, ma.mouseY)
//                      }
//                    }

//                    Image{
//                        id: displayMapImage1
//                        anchors.fill: parent
//                        fillMode: Image.Stretch
//                        asynchronous: true
//                        visible: displayMap.imageVisible === 1
//                    }
//                    Image{
//                        id: displayMapImage2
//                        anchors.fill: parent
//                        fillMode: Image.Stretch
//                        asynchronous: true
//                        visible: displayMap.imageVisible === 2
//                    }

//                    function setSource(source){
//                        var imageNew = imageVisible === 1 ? displayMapImage2 : displayMapImage1;
//                        var imageOld = imageVisible === 2 ? displayMapImage2 : displayMapImage1;

//                        imageNew.source = source;

//                        function finishImage(){
//                            if(imageNew.status === Component.Ready) {
//                                imageNew.statusChanged.disconnect(finishImage);
//                                imageVisible = imageVisible === 1 ? 2 : 1;
//                            }
//                        }

//                        if (imageNew.status === Component.Loading){
//                            imageNew.statusChanged.connect(finishImage);
//                        }
//                        else {
//                            finishImage();
//                        }
//                    }

//                    Connections {
//                        target: imgProvider
//                        function onNewMap(num: uint){
//                            displayMap.setSource("image://service/map" + num)
//                        }
//                    }
//                    PinchHandler {
//                        id: pinch
//                        target: displayMap
//                        minimumPointCount: 2
//                        onActiveChanged: () => {
//                                             if(pinch.active){
//                                                 canvas.visible = false
//                                             }
//                                         }
//                    }

//                    MouseArea {
//                        id: ma
//                        anchors.fill: parent
//                        enabled: !pinch.active
//                        onPressed: (mouse)=> {
//                            displayMap.press = Qt.point(mouse.x, mouse.y)
//                            canvas.visible = true
//                        }
//                        onMouseXChanged: canvas.requestPaint()
//                        onMouseYChanged: canvas.requestPaint()
//                        onReleased: (mouse)=> {
//                            server.uiDisplayMapMouseClick(displayMap.press, Qt.point(mouse.x, mouse.y), Qt.size(parent.width, parent.height))
//                            canvas.visible = false
//                        }
//                    }
//                }
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

        // Grasp
        StackLayout{
            id: pages
            Layout.fillHeight: true
            Layout.fillWidth: true

            Component.onCompleted: changePage()

            function changePage() {
                switch (server.pageNumber_){
                    case 0: {
                        pages.changeToObjectSelection()
                        break;
                    }
                    case 1: {
                        pages.changeToConfirm()
                        break;
                    }
                    case 2: {
                        pages.changeToGrasp()
                        break;
                    }
                }
            }

            function changeToObjectSelection() {
                errorNanPoint.opacity = 0
                errorOutOfRange.opacity = 0
                pointPleaseWait.opacity = 0
                pages.currentIndex = 0
            }
            function changeToConfirm() {
                pages.currentIndex = 1
            }
            function changeToGrasp() {
                pages.currentIndex = 2
            }
            RowLayout{
                id: page2
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout{
                    id: page2column1
                    Layout.margins: 5
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Label{
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Please select Object")
                    }
                    ImageLoader {
                        id: cameraFeed1
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        initialSource: "http://" + appWindow.ip +":8080/snapshot?topic=/stretch_gui/image"
                        pause: true

                        MouseArea {
                            anchors.fill: parent

                            onClicked: (mouse)=> {
                                           errorNanPoint.opacity = 0
                                           errorOutOfRange.opacity = 0
                                           server.uiDisplayCameraMouseClicked(Qt.point(mouse.x, mouse.y), Qt.point(mouse.x, mouse.y), Qt.size(cameraFeed1.paintedWidth, cameraFeed1.paintedHeight))
                                       }
                        }
                        Connections {
                            target: mainLayout
                            function onCurrentIndexChanged() {
                                                        if(mainLayout.currentIndex === 2 && pages.currentIndex === 0){
                                                            cameraFeed1.unpauseFeed()
                                                        } else {
                                                            cameraFeed1.pauseFeed()
                                                        }
                                                   }
                        }
                        Connections {
                            target: pages
                            function onCurrentIndexChanged() {
                                                        if(mainLayout.currentIndex === 2 && pages.currentIndex === 0){
                                                            cameraFeed1.unpauseFeed()
                                                        } else {
                                                            cameraFeed1.pauseFeed()
                                                        }
                                                   }
                        }
                    }
                }
                ColumnLayout{
                    id: page2column2
                    Layout.fillHeight: true
        //                Layout.alignment: Qt.AlignRight
                    Pane {
                        id: pointPleaseWait
                        Layout.alignment: Qt.AlignHCenter
                        Material.background: Material.Blue
                        opacity: 0
                        Label{
                            text: qsTr("Please Wait")

                        }
                        Connections {
                            target: server
                            function onUiPointPleaseWaitShow(){
                                pointPleaseWait.opacity = 1
                            }
                            function onUiPointPleaseWaitHide(){
                                pointPleaseWait.opacity = 0
                            }
                        }
                    }
                    Pane {
                        id: errorOutOfRange
                        Material.background: Material.Red
                        Layout.alignment: Qt.AlignHCenter
                        opacity: 0
                        Label{
                            text: qsTr("Point out\nof Range")
                        }
                        Connections {
                            target: server
                            function onUiErrorOutOfRangeShow(){
                                errorOutOfRange.opacity = 1
                            }
                        }
                    }
                    Pane {
                        id: errorNanPoint
                        Material.background: Material.Red
                        Layout.alignment: Qt.AlignHCenter
                        opacity: 0
                        Label{
                            text: qsTr("Please Select\nAnother Point")
                        }
                        Connections {
                            target: server
                            function onUiErrorNanPointShow(){
                                errorNanPoint.opacity = 1
                            }
                        }
                    }
                }

                ColumnLayout{
                    id: page2column3
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 5
                    Layout.fillHeight: true
                    Layout.maximumWidth: parent.width / 3
                    Label{
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Move Camera")
                    }
                    GridLayout {
                        columns: 3
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                        Button{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: qsTr("Up")
                            onClicked: {
                                server.uiCameraMoveButtonUpClicked()
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                        Button{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: qsTr("Left")
                            onClicked: {
                                server.uiCameraMoveButtonLeftClicked()
                            }
                        }
                        Button{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: qsTr("Home")
                            onClicked: {
                                server.uiCameraMoveButtonHomeClicked()
                            }
                        }
                        Button{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: qsTr("Right")
                            onClicked: {
                                server.uiCameraMoveButtonRightClicked()
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                        Button{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: qsTr("Down")
                            onClicked: {
                                server.uiCameraMoveButtonDownClicked()
                            }
                        }
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                    }
                }
            }
            RowLayout{
                id: page3
                Layout.fillHeight: true
                Layout.fillWidth: true

                Connections {
                    target: server
                    function onUiChangeToConfirmObject() {
                        pages.changeToConfirm()
                    }
                }

                ColumnLayout{
                    id: page3column1
                    Layout.fillHeight: true
                    Layout.margins: 5
                    Label{
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Is this the correct object?")
                    }
                    Rectangle{
                        id: objectFeed
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        property var press
                        property int imageVisible: 1
                        property string initialSource
                        property int fillmode: Image.PreserveAspectFit

                        color: "transparent"

                        Image{
                            id: objectFeedImage1
                            anchors.fill: parent
                            fillMode: objectFeed.fillmode
                            asynchronous: true
                            visible: objectFeed.imageVisible === 1
                            horizontalAlignment: Image.AlignLeft
                        }
                        Image{
                            id: objectFeedImage2
                            anchors.fill: parent
                            fillMode: objectFeed.fillmode
                            asynchronous: true
                            visible: objectFeed.imageVisible === 2
                            horizontalAlignment: Image.AlignLeft
                        }

                        function setSource(source){
                            var imageNew = imageVisible === 1 ? objectFeedImage2 : objectFeedImage1;
                            var imageOld = imageVisible === 2 ? objectFeedImage2 : objectFeedImage1;

                            imageNew.source = source;

                            function finishImage(){
                                if(imageNew.status === Component.Ready) {
                                    imageNew.statusChanged.disconnect(finishImage);
                                    imageVisible = imageVisible === 1 ? 2 : 1;
                                }
                            }

                            if (imageNew.status === Component.Loading){
                                imageNew.statusChanged.connect(finishImage);
                            }
                            else {
                                finishImage();
                            }
                        }

                        Connections {
                            target: imgProvider
                            function onNewObjectFeed(num: uint){
                                objectFeed.setSource("image://service/objectFeed" + num)
                            }
                        }
                    }
                }
                ColumnLayout{
                    id: page3column2
                    Layout.fillHeight: true
                    Layout.maximumWidth: parent.width / 4
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: 5
                    Label{
                        text: qsTr("Yes or No")
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Button {
                        text: qsTr("Yes")
                        Material.background: Material.Green
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        onClicked: {
                            server.uiConfirmButtonYesClicked();
                            pages.changeToGrasp()
                        }
                    }
                    Button {
                        text: qsTr("No")
                        Material.background: Material.Red
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        onClicked: {
                            server.uiConfirmButtonNoClicked();
                            pages.changeToObjectSelection()
                        }
                    }
                }
            }
            RowLayout{
                id: page4
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout {
                    id: page4column1
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 2
                    Layout.margins: 5
                    Label{
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Stretch Grasping")
                    }
                    ImageLoader {
                        id: cameraFeed2
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        initialSource: "http://" + appWindow.ip +":8080/snapshot?topic=/stretch_gui/image"
                        pause: true

                        Connections {
                            target: mainLayout
                            function onCurrentIndexChanged() {
                                                        if(mainLayout.currentIndex === 2 && pages.currentIndex === 2){
                                                            cameraFeed2.unpauseFeed()
                                                        } else {
                                                            cameraFeed2.pauseFeed()
                                                        }
                                                   }
                        }
                        Connections {
                            target: pages
                            function onCurrentIndexChanged() {
                                                        if(mainLayout.currentIndex === 2 && pages.currentIndex === 2){
                                                            cameraFeed2.unpauseFeed()
                                                        } else {
                                                            cameraFeed2.pauseFeed()
                                                        }
                                                   }
                        }
                    }
                }
                ColumnLayout {
                    id: page4column2
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 5
                    GridLayout {
                        columns: 2
                        Button {
                            text: qsTr("Replace\nObject")
                            Material.background: Material.Green
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            onClicked: {
                                server.uiButtonReplaceObjectClicked()
                            }
                        }
                        Button {
                                text: qsTr("Stow\nObject")
                                Material.background: Material.Green
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                onClicked: {
                                    server.uiButtonStowObjectClicked()
                                }
                            }
                        Button {
                            text: qsTr("Release\nObject")
                            Material.background: Material.Green
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            onClicked: {
                                server.uiButtonReleaseClicked()
                            }
                        }
                    }
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Back")
                        Material.background: Material.Red
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        enabled: !server.hasObject_;
                        onClicked: {
                            server.uiButtonBackClicked()
                            pages.changeToObjectSelection()
                        }
                    }
                }
            }
        }

    }

}


