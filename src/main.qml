import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts

// https://forum.qt.io/topic/42428/refreshing-remote-image-source-without-flickering-resp-empty-image-during-refresh

ApplicationWindow {
    id: appWindow
    width: 1280
    height: 720
    visible: true
    property var server
    property var component
    property var sprite
    Material.theme: Material.Light

        Connections {
            target: client
            function onServerFailure() {
                loader.item.errorConnectionVisible = true;
            }

            function onServerSuccess(obj) {
                server = obj
                loader.setSource("pages.qml")
            }
            function onDisconnected() {
                server = null
                loader.setSource("start.qml")
                loader.item.errrorLostConnectionVisible = true
            }
        }
        function createHomeScreen() {
            component = Qt.createComponent("start.qml");
            sprite = component.createObject(appWindow);
        }

        Loader {
            id: loader
            source: "start.qml"
            anchors.fill: parent
            focus: true
            anchors.margins: 5
        }

}
