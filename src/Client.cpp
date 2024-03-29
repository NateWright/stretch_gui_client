#include "include/stretch_gui_client/Client.hpp"

Client::Client(QSharedPointer<ServerReplica> ptr, QSharedPointer<QRemoteObjectNode> repNode, QObject *parent) : QObject(parent), server_(ptr), repNode_(repNode), provider_(new ImageProvider()) {
}

void Client::initiateServer(QString url) {
    url = "tcp://" + url + ":stretch";
//    qDebug() << "url: " << url;
    repNode_->connectToNode(QUrl(url));
    server_.reset(repNode_->acquire<ServerReplica>());  // acquire replica of source from host node
    if (!server_->waitForSource()) {                    // connect with remote host node
        emit serverFailure();
        server_.clear();
        return;
    }
    emit serverSuccess(server_.data());
    initConnections();
}

void Client::initConnections() {
    connect(server_.data(), &ServerReplica::stateChanged, this, [this](auto info) {if(info == QRemoteObjectReplica::Suspect){
            emit disconnected();
//            server_.clear();
        } });
    // Page 1

    // Page 3

    connect(server_.data(), &ServerReplica::uiDisplayImageSetCamera, provider_.data(), &ImageProvider::setObjectFeed);  // Server to ui
}
