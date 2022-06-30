#ifndef CLIENT_HPP
#define CLIENT_HPP

#include <QDebug>
#include <QImage>
#include <QObject>
#include <QSharedPointer>

#include "PixmapProvider.hpp"
#include "rep_Server_replica.h"

class Client : public QObject {
    Q_OBJECT

   public:
    explicit Client(QSharedPointer<ServerReplica> ptr, QObject *parent = nullptr);
    QSharedPointer<PixmapProvider> getProvider() const { return provider_; }

   private:
    QSharedPointer<ServerReplica> server_;
    QSharedPointer<PixmapProvider> provider_;

    void initConnections();

   signals:
    void ButtonToggleNavigationType();
    void ButtonStop();
    void ButtonSetHome();
    void ButtonGoHome();
    void ButtonGrasp();


   private slots:
//    void changeToPage1();
//    void changeToPage2();
//    void changeToPage3();
//    void changeToPage4();
//    void changeToPage5();
//    void changeToPage6();
//    void showButtonNavigateHome();
};
#endif  // CLIENT_HPP
