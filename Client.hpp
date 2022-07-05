#ifndef CLIENT_HPP
#define CLIENT_HPP

#include <QDebug>
#include <QImage>
#include <QObject>
#include <QSharedPointer>
#include <QString>

#include "PixmapProvider.hpp"
#include "rep_Server_replica.h"

class Client : public QObject {
    Q_OBJECT

   public:
    explicit Client(QSharedPointer<ServerReplica> ptr, QSharedPointer<QRemoteObjectNode> repNode, QObject *parent = nullptr);
    QSharedPointer<PixmapProvider> getProvider() const { return provider_; }

   private:
    QSharedPointer<ServerReplica> server_;
    QSharedPointer<PixmapProvider> provider_;
    QSharedPointer<QRemoteObjectNode> repNode_;

    void initConnections();

   signals:
    void server(ServerReplica*);


   public slots:
    void initiateServer(QString);
};
#endif  // CLIENT_HPP
