import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts

ColumnLayout {
    id: startPage
    anchors.fill: parent
    property alias errorConnectionVisible: errorConnection.visible
    property alias errrorLostConnectionVisible: errorLostConnection.visible

    function submit() {
        appWindow.ip = ip.text
        client.initiateServer(ip.text)
    }

    Label {
        id: label
        Layout.fillWidth: true
        text: qsTr("Please enter IP for stretch")
    }
    Pane {
        id: errorConnection
        Layout.fillWidth: true
        visible: false
        Material.background: Material.Red

        Label {
            text: qsTr("Could not connect to this IP")
        }
    }
    Pane {
        id: errorLostConnection
        Layout.fillWidth: true
        visible: false
        Material.background: Material.Red

        Label {
            text: qsTr("Lost connection to server")
        }
    }
    RowLayout{
        Label {
            id: ipLabel
            text: qsTr("IP:")
        }
        TextField {
            focus: true
            id: ip
            KeyNavigation.tab: Button
            Keys.onReturnPressed: startPage.submit()
            Layout.fillWidth: true
        }
    }
//    RowLayout {
//        Label {
//            id: portLabel
//            text: qsTr("Port:")
//        }
//        TextField {
//            id: port
//            Material.background: Material.Grey
//            Layout.fillWidth: true
//            KeyNavigation.tab: Button
//        }
//    }

    Button {
        Layout.alignment: Qt.AlignTop
        text: qsTr("Submit")

        onClicked: startPage.submit()
        Keys.onReturnPressed: startPage.submit()
    }

}
