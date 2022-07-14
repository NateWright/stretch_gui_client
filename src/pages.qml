import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts

// https://forum.qt.io/topic/42428/refreshing-remote-image-source-without-flickering-resp-empty-image-during-refresh
StackLayout{
    id: pages
    anchors.fill:parent

    Component.onCompleted: () => {
                               switch (server.pageNumber_){
                                   case 0: {
                                       pages.changeToPage1()
                                       break;
                                   }
                                   case 1: {
                                       pages.changeToPage2()
                                       break;
                                   }
                                   case 2: {
                                       pages.changeToPage3()
                                       break;
                                   }
                                   case 3: {
                                       pages.changeToPage4()
                                       break;
                                   }
                                   case 4: {
                                       pages.changeToPage5()
                                       break;
                                   }
                               }
                           }

    currentIndex: server.pageNumber_

    function changeToPage1() {
        pages.currentIndex = 0
        backToGrasp.visible = false
        buttonGrasp.visible = true
    }
    function changeToPage2() {
        errorNanPoint.opacity = 0
        errorOutOfRange.opacity = 0
        pointPleaseWait.opacity = 0
        pages.currentIndex = 1
    }
    function changeToPage3() {
        pages.currentIndex = 2
    }
    function changeToPage4() {
        pages.currentIndex = 3
    }
    function changeToPage5() {
        pages.currentIndex = 0
        backToGrasp.visible = true
        buttonGrasp.visible = false
    }

    RowLayout{
        id: page1
        Layout.fillHeight: true
        Layout.fillWidth: true
        ColumnLayout{
            id: page1column1
            Label{
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Click a Point to Move Stretch")
            }
            Rectangle{
                id: displayMap
                Layout.fillHeight: true
                Layout.fillWidth: true
                property var press: Qt.point(0,0)
                property int imageVisible: 1
                property string initialSource
                Layout.margins: 5

                color: "transparent"

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
                    arrow(ctx, displayMap.press.x, displayMap.press.y, ma.mouseX, ma.mouseY)
                  }
                }

                Image{
                    id: displayMapImage1
                    anchors.fill: parent
                    fillMode: Image.Stretch
                    asynchronous: true
                    visible: displayMap.imageVisible === 1
                }
                Image{
                    id: displayMapImage2
                    anchors.fill: parent
                    fillMode: Image.Stretch
                    asynchronous: true
                    visible: displayMap.imageVisible === 2
                }

                function setSource(source){
                    var imageNew = imageVisible === 1 ? displayMapImage2 : displayMapImage1;
                    var imageOld = imageVisible === 2 ? displayMapImage2 : displayMapImage1;

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
                    function onNewMap(num: uint){
                        displayMap.setSource("image://service/map" + num)
                    }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    onPressed: (mouse)=> {
                        displayMap.press = Qt.point(mouse.x, mouse.y)
                        canvas.visible = true
                    }
                    onMouseXChanged: canvas.requestPaint()
                    onMouseYChanged: canvas.requestPaint()
                    onReleased: (mouse)=> {
                        server.uiDisplayMapMouseClick(displayMap.press, Qt.point(mouse.x, mouse.y), Qt.size(parent.width, parent.height))
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
            Button{
                id: beginGrasp
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: qsTr("Begin Grasp")
                Material.background: Material.Green
                onClicked:{
                    server.uiButtonGraspClicked()
                    pages.changeToPage2()

                }
                Connections {
                    target: server
                    function onUiPleaseWaitSetVisible(b: Boolean){
                        beginGrasp.enabled = !b
                    }
                }
            }
            Button{
                id: backToGrasp
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: qsTr("Back")
                Material.background: Material.Red
                visible: false
                onClicked:{
                    changeToPage4()
                    server.uiButtonBackToGraspClicked()
                }
                Connections {
                    target: server
                    function onUiPleaseWaitSetVisible(b: Boolean){
                        beginGrasp.enabled = !b
                    }
                }
            }
        }
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

                MouseArea {
                    anchors.fill: parent

                    onClicked: (mouse)=> {
                                   errorNanPoint.opacity = 0
                                   errorOutOfRange.opacity = 0
                                   server.uiDisplayCameraMouseClicked(Qt.point(mouse.x, mouse.y), Qt.point(mouse.x, mouse.y), Qt.size(cameraFeed1.paintedWidth, cameraFeed1.paintedHeight))
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
            Button{
                Layout.alignment: Qt.AlignHCenter
                Material.background: Material.Red
                Layout.minimumHeight: Layout.minimumWidth
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: qsTr("Back")
                onClicked:{
                    pages.changeToPage1()
                    server.uiButtonBackClicked()
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
            function onUiChangeToPage3() {
                pages.changeToPage3()
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
                    pages.changeToPage4()
                }
            }
            Button {
                text: qsTr("No")
                Material.background: Material.Red
                Layout.fillHeight: true
                Layout.fillWidth: true
                onClicked: {
                    server.uiConfirmButtonNoClicked();
                    pages.changeToPage2()
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
                        text: qsTr("Return\nHome")
                        Material.background: Material.Green
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        onClicked: {
                            server.uiButtonReturnObjectClicked()
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
                Button {
                    text: qsTr("Navigate")
                    Material.background: Material.Green
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    onClicked: {
                        server.uiButtonNavigateClicked()
                        pages.changeToPage5()
                    }
                }
            }
            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Back")
                Material.background: Material.Red
                Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked: {
                    server.uiButtonBack_2Clicked()
                    pages.changeToPage3()
                }
            }
        }
    }
}
