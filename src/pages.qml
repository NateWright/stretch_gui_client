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
                           mainLayout.changeTitle()
                       }
        }
        Button {
            id: navigateButton
            text: qsTr("Navigate")
            onClicked: () => {
                           mainLayout.currentIndex = 1
                           server.changeToNavigation()
                           mainLayout.changeTitle()
                       }
            enabled: server.canNavigate_
        }
        Button {
            id: graspButton
            text: qsTr("Grasp")
            onClicked: () => {
                           mainLayout.currentIndex = 2
                           server.uiGrasp()
                           mainLayout.changeTitle()
                       }
            Connections {
                target: server
                function onUiPleaseWaitSetVisible(b: Boolean){
                    graspButton.enabled = !b
                }
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
        function changeTitle() {
            switch(mainLayout.currentIndex){
            case 0: {
                info.text = qsTr("")
                break
            }
            case 1: {
                info.text = qsTr("Click and Drag to Move Stretch")
                break
            }
            case 2: {
                switch(pages.currentIndex){
                case 0: {
                    info.text = qsTr("Please select Object")
                    break
                }
                case 1: {
                    info.text = qsTr("Is this the correct object?")
                    break
                }
                case 2: {
                    info.text = qsTr("Stretch Grasping")
                    break
                }
                }
                break
            }

            }
        }


        // Camera
        CameraPage{
            id: cameraPage

            cameraPause: mainLayout.currentIndex !== 0
            ip: appWindow.ip
        }


        // Navigate
        MapPage{
            id: navigatePage

            cameraPause: mainLayout.currentIndex !== 1
            ip: appWindow.ip
        }

        // Grasp
        GraspPage{
            id: graspPage

            cameraPause: mainLayout.currentIndex !== 2
            ip: appWindow.ip
        }


    }

}


