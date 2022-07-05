import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts

ColumnLayout {
    id: startPage
    Layout.fillWidth: true
    Layout.fillHeight: true
    Pane {
        Layout.fillWidth: true

        Text {
            id: label
            text: qsTr("Please enter IP and Port")
        }
    }
    RowLayout{
        Text {
            id: ipLabel
            text: qsTr("IP:")
        }
        TextInput {
            id: ip
            Layout.fillWidth: true
        }
    }
    RowLayout {
        Text {
            id: portLabel
            text: qsTr("Port:")
        }
        TextInput {
            id: port
            Layout.fillWidth: true
        }
    }

    Button {
        text: qsTr("Submit")

        onClicked: {
            client.initiateServer(ip.text + ":" + port.text)
        }
    }

}
