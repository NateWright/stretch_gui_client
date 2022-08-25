import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

RowLayout {
    property bool cameraPause: true
    property string ip
    ImageLoader {
        id: camera
        Layout.fillHeight: true
        Layout.fillWidth: true
        initialSource: "http://" + parent.ip +":8080/snapshot?topic=/stretch_gui/image"
        pause: parent.cameraPause
    }
    ColumnLayout{
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
