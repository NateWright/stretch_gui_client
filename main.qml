import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts

// https://forum.qt.io/topic/42428/refreshing-remote-image-source-without-flickering-resp-empty-image-during-refresh

Window {
    visible: true

    StackLayout{
        id: pages
        anchors.fill:parent
        currentIndex: 0

        function changeToPage1() {
            pages.currentIndex = 0
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
                    property var press
                    property int imageVisible: 1
                    property string initialSource

                    color: "transparent"

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
//                            displayMap.source = "image://service/map" + num
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: (mouse)=> {
                            displayMap.press = Qt.point(mouse.x, mouse.y)
                            server.uiDisplayMapMousePressInitiated(displayMap.press, Qt.size(parent.width, parent.height))
                        }
                        onPositionChanged: (mouse)=> {
                            server.uiDisplayMapMousePressCurrentLocation(Qt.point(mouse.x, mouse.y), Qt.size(parent.width, parent.height))
                        }
                        onReleased: (mouse)=> {
                            server.uiDisplayMapMouseClick(displayMap.press, Qt.point(mouse.x, mouse.y), Qt.size(parent.width, parent.height))
                        }
                    }
                }
            }
            ColumnLayout{
                id: page1column2
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 5
                Pane{
                    id: pleaseWait
                    Material.elevation: 6
                    Material.background: Material.Red
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0
                    Label{
                        text: qsTr("Please Wait for Robot to Move")
                    }
                    Connections {
                        target: server
                        function onUiPleaseWaitSetVisible(b: Boolean){
                            if(b){
                                pleaseWait.opacity = 1
                            }else{
                                pleaseWait.opacity = 0
                            }
                        }
                    }
                }
                Button{
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Toggle Navigation Type")
                    Material.background: Material.Green
                    onClicked: {
                        server.uiButtonToggleNavTypeClicked()
                    }
                }
                Button{
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("STOP")
                    Material.background: Material.Red
                    onClicked: {
                        server.uiButtonStopClicked()
                    }
                }
                Row{
                    Layout.alignment: Qt.AlignHCenter
                    Button{
                        text: qsTr("Set Home")
                        Material.background: Material.Green
                        onClicked: {
                            server.uiButtonSetHomeClicked()
                        }
                    }
                    Button{
                        id: goHome
                        text: qsTr("Go Home")
                        Material.background: Material.Green
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
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Begin Grasp")
                    Material.background: Material.Green
                    onClicked:{
                        server.uiButtonGraspClicked()
                        pages.changeToPage2()

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
                Label{
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Please select Object")
                }
                Rectangle{
                    id: cameraFeed1
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    property var press
                    property int imageVisible: 1
                    property string initialSource
                    property int fillmode: Image.PreserveAspectFit

                    color: "transparent"

                    Image{
                        id: cameraFeed1Image1
                        anchors.fill: parent
                        fillMode: cameraFeed1.fillmode
                        asynchronous: true
                        visible: cameraFeed1.imageVisible === 1
                        horizontalAlignment: Image.AlignLeft
                    }
                    Image{
                        id: cameraFeed1Image2
                        anchors.fill: parent
                        fillMode: cameraFeed1.fillmode
                        asynchronous: true
                        visible: cameraFeed1.imageVisible === 2
                        horizontalAlignment: Image.AlignLeft
                    }

                    function setSource(source){
                        var imageNew = imageVisible === 1 ? cameraFeed1Image2 : cameraFeed1Image1;
                        var imageOld = imageVisible === 2 ? cameraFeed1Image2 : cameraFeed1Image1;

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
                        function onNewCameraFeed(num: uint){
                            cameraFeed1.setSource("image://service/cameraFeed" + num)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: (mouse)=> {
                                       errorNanPoint.opacity = 0
                                       errorOutOfRange.opacity = 0
                                       server.uiDisplayCameraMouseClicked(Qt.point(mouse.x, mouse.y), Qt.point(mouse.x, mouse.y), Qt.size(cameraFeed1Image1.paintedWidth, cameraFeed1Image1.paintedHeight))
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
                        text: qsTr("Point out of Range")
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
                        text: qsTr("Please Select Another Point")
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
                Label{
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Move Camera")
                }
                RowLayout{
                    Layout.alignment: Qt.AlignHCenter
                    Button{
                        text: qsTr("Up")
                        onClicked: {
                            server.uiCameraMoveButtonUpClicked()
                        }
                    }
                }
                RowLayout{
                    Layout.alignment: Qt.AlignHCenter
                    Button{
                        text: qsTr("Left")
                        onClicked: {
                            server.uiCameraMoveButtonLeftClicked()
                        }
                    }
                    Button{
                        text: qsTr("Home")
                        onClicked: {
                            server.uiCameraMoveButtonHomeClicked()
                        }
                    }
                    Button{
                        text: qsTr("Right")
                        onClicked: {
                            server.uiCameraMoveButtonRightClicked()
                        }
                    }
                }

                RowLayout{
                    Layout.alignment: Qt.AlignHCenter
                    Button{
                        text: qsTr("Down")
                        onClicked: {
                            server.uiCameraMoveButtonDownClicked()
                        }
                    }
                }
                Button{
                    Layout.alignment: Qt.AlignHCenter
                    Material.background: Material.Red
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
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 5
                Label{
                    text: qsTr("Yes or No")
                }
                Button {
                    text: qsTr("Yes")
                    Material.background: Material.Green
                    onClicked: {
                        server.uiConfirmButtonYesClicked();
                        pages.changeToPage4()
                    }
                }
                Button {
                    text: qsTr("No")
                    Material.background: Material.Red
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
//                Layout.fillWidth: true
                Label{
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("StretchGrasping")
                }
                Rectangle{
                    id: cameraFeed2
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    property var press
                    property int imageVisible: 1
                    property string initialSource
                    property int fillmode: Image.PreserveAspectFit

                    color: "transparent"

                    Image{
                        id: cameraFeed2Image1
                        anchors.fill: parent
                        fillMode: cameraFeed2.fillmode
                        asynchronous: true
                        visible: cameraFeed2.imageVisible === 1
                        horizontalAlignment: Image.AlignLeft
                    }
                    Image{
                        id: cameraFeed2Image2
                        anchors.fill: parent
                        fillMode: cameraFeed2.fillmode
                        asynchronous: true
                        visible: cameraFeed2.imageVisible === 2
                        horizontalAlignment: Image.AlignLeft
                    }

                    function setSource(source){
                        var imageNew = imageVisible === 1 ? cameraFeed2Image2 : cameraFeed2Image1;
                        var imageOld = imageVisible === 2 ? cameraFeed2Image2 : cameraFeed2Image1;

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
                        function onNewCameraFeed(num: uint){
                            cameraFeed2.setSource("image://service/cameraFeed" + num)
                        }
                    }
                }
            }
            ColumnLayout {
                id: page4column2
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.width / 2
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 5
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Button {
                        Layout.preferredWidth: page4column2.width/3
                        Layout.preferredHeight: page4column2.height/4
                        text: qsTr("Replace\nObject")
                        Material.background: Material.Green
                        onClicked: {
                            server.uiButtonReplaceObjectClicked()
                        }
                    }
                    Button {
                        Layout.preferredWidth: page4column2.width/3
                        Layout.preferredHeight: page4column2.height/4
                        text: qsTr("Return\nHome")
                        Material.background: Material.Green
                        onClicked: {
                            server.uiButtonReturnObjectClicked()
                        }
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Button {
                        Layout.preferredWidth: page4column2.width/3
                        Layout.preferredHeight: page4column2.height/4
                        text: qsTr("Release\nObject")
                        Material.background: Material.Green
                        onClicked: {
                            server.uiButtonReleaseClicked()
                        }
                    }
                    Button {
                        Layout.preferredWidth: page4column2.width/3
                        Layout.preferredHeight: page4column2.height/4
                        text: qsTr("Navigate")
                        Material.background: Material.Green
                        onClicked: {
                            server.uiButtonNavigateClicked()
                        }
                    }
                }
                Button {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: page4column2.width/3
                    Layout.preferredHeight: page4column2.height/4
                    text: qsTr("Back")
                    Material.background: Material.Red
                    onClicked: {
                        server.uiButtonBack_2Clicked()
                        pages.changeToPage3()
                    }
                }
            }
        }
    }
}
