import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

// https://forum.qt.io/topic/42428/refreshing-remote-image-source-without-flickering-resp-empty-image-during-refresh

ColumnLayout {
    RowLayout{
        z: 5
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
            enabled: server.canNavigate_
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
        Button {
            id: placeButton
            text: qsTr("Place")
//            onClicked: () => {
//                           mainLayout.currentIndex = 2
//                           server.uiGrasp()
//                       }
            Connections {
                target: server
//                function onUiPleaseWaitSetVisible(b: Boolean){
//                    graspButton.enabled = !b
//                }
            }
        }
        Item {
            Layout.fillWidth: true
            Label {
                id: info
                anchors.centerIn: parent
                text: qsTr("Click and Drag to Move Stretch")
           }
        }
    }

    StackLayout {
        id: mainLayout
        currentIndex: 1

        Component.onCompleted: server.changeToNavigation()
        function changeTitle(newText) {
            info.text = newText
        }


        // Camera
        CameraPage{
            id: cameraPage

            cameraPause: mainLayout.currentIndex !== 0
            ip: appWindow.ip

            Connections {
                target: mainLayout
                function onCurrentIndexChanged() {
                                           if(mainLayout.currentIndex === 0){
                                                mainLayout.changeTitle(qsTr("Camera Feed"))
                                           }
                                       }
            }
        }


        // Navigate
        MapPage{
            id: navigatePage

            cameraPause: mainLayout.currentIndex !== 1
            ip: appWindow.ip

            Connections {
                target: mainLayout
                function onCurrentIndexChanged(){
                                           if(mainLayout.currentIndex === 1){
                                                mainLayout.changeTitle(qsTr("Click and Drag to Move Stretch"))
                                           }
                                       }
            }
        }

        // Grasp
        GraspPage{
            id: graspPage

            cameraPause: mainLayout.currentIndex !== 2
            ip: appWindow.ip

            Connections{
                target: mainLayout
                function onCurrentIndexChanged(){
                                           if(mainLayout.currentIndex === 2){
                                                mainLayout.changeTitle(graspPage.title)
                                           }
                                       }
            }
            Connections{
                function onTitleChanged(){
                    mainLayout.changeTitle(graspPage.title)
                }
            }
        }


    }

}


