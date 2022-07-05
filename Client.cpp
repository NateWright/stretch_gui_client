#include "Client.hpp"

Client::Client(QSharedPointer<ServerReplica> ptr, QSharedPointer<QRemoteObjectNode> repNode, QObject *parent) : QObject(parent), server_(ptr), repNode_(repNode), provider_(new PixmapProvider()) {
}

void Client::initiateServer(QString url){
    url = "tcp://" + url;
    qDebug() << "url: " << url;
    repNode_->connectToNode(QUrl(url));  // connect with remote host node
    server_.reset(repNode_->acquire<ServerReplica>());  // acquire replica of source from host node
    emit server(server_.data());
    initConnections();
}

void Client::initConnections() {
    // Page 1

    connect(server_.data(), &ServerReplica::newMap, provider_.data(), &PixmapProvider::setMap);

    // Page 2

    connect(server_.data(), &ServerReplica::uiDisplayCameraSetCamera, provider_.data(), &PixmapProvider::setCameraFeed);

    // Page 3

    connect(server_.data(), &ServerReplica::uiDisplayImageSetCamera, provider_.data(), &PixmapProvider::setObjectFeed);  // Server to ui
}
