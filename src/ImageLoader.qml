import QtQuick 2.0

Rectangle{
    id: imageLoader
    property int imageVisible: 1
    property string initialSource
    property int fillmode: Image.PreserveAspectFit
    property int paintedWidth: displayImage1.paintedWidth
    property int paintedHeight: displayImage1.paintedHeight
    property int sourceWidth: 0
    property int sourceHeight: 0
    property bool pause: false

    color: "transparent"

    signal done()

    Image{
        id: displayImage1
        anchors.fill: parent
        fillMode: imageLoader.fillmode
        asynchronous: true
        cache: false
        visible: imageLoader.imageVisible === 1
        horizontalAlignment: Image.AlignLeft
    }
    Image{
        id: displayImage2
        anchors.fill: parent
        fillMode: imageLoader.fillmode
        asynchronous: true
        cache: false
        visible: imageLoader.imageVisible === 2
        horizontalAlignment: Image.AlignLeft
    }

    function setSource(source){
        var imageNew = imageVisible === 1 ? displayImage2 : displayImage1;
        var imageOld = imageVisible === 2 ? displayImage2 : displayImage1;

        imageNew.source = source;

        function finishImage(){
            if(imageNew.status === Component.Ready) {
                imageNew.statusChanged.disconnect(finishImage);
                imageVisible = imageVisible === 1 ? 2 : 1;
                imageOld.source = ""

                if(sourceWidth !== imageNew.sourceSize.width){
                    sourceWidth = imageNew.sourceSize.width
                    sourceHeight = imageNew.sourceSize.height
                }

                done()
            }
        }

        if (imageNew.status === Component.Loading){
            imageNew.statusChanged.connect(finishImage);
        }
        else {
            finishImage();
        }
    }
    Component.onCompleted: setSource(initialSource)
    Connections {
        target: imageLoader
        function onDone() {
            if(!pause){
                imageLoader.setSource(initialSource)
            }
        }
    }

    function pauseFeed() {
        pause = true
    }
    function unpauseFeed() {
        pause = false
        imageLoader.setSource(initialSource)
    }
}
