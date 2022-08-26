import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

StackLayout{
    id: graspPages

    property string ip
    property bool cameraPause
    property var title

    Layout.fillHeight: true
    Layout.fillWidth: true

    Component.onCompleted: changePage()

    function changePage() {
        switch (server.pageNumber_){
            case 0: {
                graspPages.changeToObjectSelection()
                break;
            }
            case 1: {
                graspPages.changeToConfirm()
                break;
            }
            case 2: {
                graspPages.changeToGrasp()
                break;
            }
        }
    }

    function changeToObjectSelection() {
        errorNanPoint.opacity = 0
        errorOutOfRange.opacity = 0
        pointPleaseWait.opacity = 0
        graspPages.currentIndex = 0
        title = qsTr("Please select Object")
    }
    function changeToConfirm() {
        graspPages.currentIndex = 1
        title = qsTr("Is this the correct object?")
    }
    function changeToGrasp() {
        graspPages.currentIndex = 2
        title = qsTr("Stretch Grasping")
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
            ImageLoader {
                id: cameraFeed1
                Layout.fillHeight: true
                Layout.fillWidth: true
                initialSource: "http://" + graspPages.ip +":8080/snapshot?topic=/stretch_gui/image"
                pause: graspPages.cameraPause || graspPages.currentIndex !== 0
                MouseArea {
                    anchors.fill: parent

                    onClicked: (mouse)=> {
                                   var spacing = (cameraFeed1.height - cameraFeed1.paintedHeight)/2
                                   if(mouse.y > spacing && mouse.y <= cameraFeed1.paintedHeight + spacing){
                                       errorNanPoint.opacity = 0
                                       errorOutOfRange.opacity = 0
                                       server.uiDisplayCameraMouseClicked(Qt.point(mouse.x, mouse.y - spacing), Qt.point(0,0), Qt.size(cameraFeed1.paintedWidth, cameraFeed1.paintedHeight))
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
                graspPages.changeToConfirm()
                server.setVertical()
            }
        }

        ColumnLayout{
            id: page3column1
            Layout.fillHeight: true
            Layout.margins: 5
            Rectangle{
                id: objectFeed
                Layout.fillHeight: true
                Layout.fillWidth: true

                color: "transparent"

                Image{
                    id: objectFeedImage
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    horizontalAlignment: Image.AlignLeft
                }

                Connections {
                    target: imgProvider
                    function onNewObjectFeed(num: uint){
                        objectFeedImage.source = "image://service/objectFeed" + num;
                    }
                }
            }
        }
        ColumnLayout {
            Layout.fillHeight: true
            Layout.maximumWidth: parent.width / 4
            Pane {
                Layout.fillWidth: true
                Label {
                    anchors.centerIn: parent
                    text: qsTr("Please Select Orientation")
                }
            }
            Button {
                id: verticalButton
                text: qsTr("Vertical")
                Material.background: Material.Green
                Layout.fillHeight: true
                Layout.fillWidth: true
                onClicked: {
                    verticalButton.Material.background = Material.Green
                    horizontalButton.Material.background = Material.Gray
                    server.setVertical()
                }
            }
            Button {
                id: horizontalButton
                text: qsTr("Horizontal")
                Layout.fillHeight: true
                Layout.fillWidth: true
                onClicked: {
                    Material.background = Material.Green
                    verticalButton.Material.background = Material.Gray
                    server.setHorizontal()
                }
            }
        }

        ColumnLayout{
            id: page3column2
            Layout.fillHeight: true
            Layout.maximumWidth: parent.width / 4
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 5
            Pane {
                Layout.fillWidth: true
                Label{
                    text: qsTr("Yes or No")
                    anchors.centerIn: parent
                }
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
                    graspPages.changeToObjectSelection()
                    objectFeedImage.source = "";
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
            ImageLoader {
                id: cameraFeed2
                Layout.fillHeight: true
                Layout.fillWidth: true
                initialSource: "http://" + graspPages.ip +":8080/snapshot?topic=/stretch_gui/image"
                pause: graspPages.cameraPause || graspPages.currentIndex !== 2
            }
        }
        ColumnLayout {
            id: page4column2
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: 5
            property bool backVisible: true

            Connections{
                target: server
                function onHasObject_Changed(){
                    if(server.hasObject_ === false){
                        page4column2.backVisible = true
                    }
                }
            }

            GridLayout {
                columns: 2
                Button {
                    text: qsTr("Replace\nObject")
                    Material.background: Material.Green
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: server.hasObject_;
                    onClicked: {
                        server.uiButtonReplaceObjectClicked()
                        page4column2.backVisible = false;
                    }
                }
                Button {
                        text: qsTr("Stow\nObject")
                        Material.background: Material.Green
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        enabled: !server.hasObject_;
                        onClicked: {
                            server.uiButtonStowObjectClicked()
                        }
                    }
                Button {
                    text: qsTr("Release\nObject")
                    Material.background: Material.Green
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    enabled: server.hasObject_;
                    onClicked: {
                        server.uiButtonReleaseClicked()
                        page4column2.backVisible = true;
                        pages.changeToObjectSelection()
                    }
                }
            }
            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("STOP OPERATION")
                Material.background: Material.Red
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !page4column2.backVisible
                onClicked: {
                    server.uiButtonStopReplaceClicked()
                    page4column2.backVisible = true;
                }
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Back")
                Material.background: Material.Red
                Layout.fillWidth: true
                Layout.fillHeight: true
                enabled: !server.hasObject_
                visible: page4column2.backVisible
                onClicked: {
                    server.uiButtonBackClicked()
                    pages.changeToObjectSelection()
                }
            }
        }
    }
}
