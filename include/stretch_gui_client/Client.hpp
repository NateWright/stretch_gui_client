#ifndef CLIENT_HPP
#define CLIENT_HPP

#include <QDebug>
#include <QImage>
#include <QObject>
#include <QSharedPointer>
#include <QString>

#include "ImageProvider.hpp"
#include "rep_Server_replica.h"

class Client : public QObject {
    Q_OBJECT

   public:
    explicit Client(QSharedPointer<ServerReplica> ptr, QSharedPointer<QRemoteObjectNode> repNode, QObject *parent = nullptr);
    QSharedPointer<ImageProvider> getProvider() const { return provider_; }

   private:
    QSharedPointer<ServerReplica> server_;
    QSharedPointer<ImageProvider> provider_;
    QSharedPointer<QRemoteObjectNode> repNode_;

    void initConnections();

   signals:
    void serverSuccess(ServerReplica *);
    void serverFailure();
    void disconnected();

   public slots:
    void initiateServer(QString);
};
#endif  // CLIENT_HPP
