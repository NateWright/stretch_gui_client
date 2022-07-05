import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts

// https://forum.qt.io/topic/42428/refreshing-remote-image-source-without-flickering-resp-empty-image-during-refresh

Window {
    id: appWindow
    visible: true
    property var server
    property var component
    property var sprite

        Connections {
            target: client
            function onServer(obj) {
                console.log("got it")
                server = obj

                sprite.destroy()

                component = Qt.createComponent("pages.qml")
                sprite = component.createObject(appWindow)

            }
        }
        function createHomeScreen() {
            component = Qt.createComponent("start.qml");
            sprite = component.createObject(appWindow);
        }

        Component.onCompleted: createHomeScreen();

}
