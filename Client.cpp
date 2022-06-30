#include "Client.hpp"

Client::Client(QSharedPointer<ServerReplica> ptr, QObject *parent) : QObject(parent), server_(ptr), provider_(new PixmapProvider()) {
    // Page 1

    //    ui->ButtonNavigateHome->setEnabled(false);

    //    ui->ButtonBackToGrasp->setEnabled(false);
    //    ui->ButtonBackToGrasp->hide();

    //    ui->PleaseWait->setVisible(false);

    // Page 2

    //    ui->DisplayCamera->setScaledContents(false);

    // Page 3

    //    ui->DisplayImage->setScaledContents(false);

    // Page 4

    //    ui->DisplayGrasp->setScaledContents(false);

    initConnections();
}

void Client::initConnections() {
    // Page 1

    connect(server_.data(), &ServerReplica::newMap, provider_.data(), &PixmapProvider::setMap);

    // Page 2

    //    connect(ui->ButtonBack, &QPushButton::clicked, server_.data(), &ServerReplica::uiButtonBackClicked);  // Both
    //    connect(ui->ButtonBack, &QPushButton::clicked, this, &MainWindow::changeToPage1);

    //    connect(ui->CameraMoveButtonUp, &QPushButton::clicked, server_.data(), &ServerReplica::uiCameraMoveButtonUpClicked);        // MainWindow to server
    //    connect(ui->CameraMoveButtonDown, &QPushButton::clicked, server_.data(), &ServerReplica::uiCameraMoveButtonDownClicked);    // MainWindow to server
    //    connect(ui->CameraMoveButtonLeft, &QPushButton::clicked, server_.data(), &ServerReplica::uiCameraMoveButtonLeftClicked);    // MainWindow to server
    //    connect(ui->CameraMoveButtonRight, &QPushButton::clicked, server_.data(), &ServerReplica::uiCameraMoveButtonRightClicked);  // MainWindow to server
    //    connect(ui->CameraMoveButtonHome, &QPushButton::clicked, server_.data(), &ServerReplica::uiCameraMoveButtonHomeClicked);    // MainWindow to server

    //    // Find point in Camera
    //    connect(ui->DisplayCamera, &SceneViewer::mouseClick, server_.data(), &ServerReplica::uiDisplayCameraMouseClicked);  // MainWindow to server
    //    connect(ui->DisplayCamera, &SceneViewer::mouseClick, ui->ErrorNanPoint, &QTextBrowser::hide);                       // MainWindow only
    //    connect(ui->DisplayCamera, &SceneViewer::mouseClick, ui->ErrorOutOfRange, &QTextBrowser::hide);                     // MainWindow only

    //    connect(server_.data(), &ServerReplica::uiPointPleaseWaitShow, ui->PointPleaseWait, &QTextBrowser::show);  // Sever to MainWindow

    //    // Camera feed
    connect(server_.data(), &ServerReplica::uiDisplayCameraSetCamera, provider_.data(), &PixmapProvider::setCameraFeed);
    //    // Server to MainWindow
    //    // Error: Displays if NaN point was selected
    //    connect(server_.data(), &ServerReplica::uiErrorNanPointShow, ui->ErrorNanPoint, &QTextBrowser::show);      // Server to MainWindow
    //    connect(server_.data(), &ServerReplica::uiPointPleaseWaitHide, ui->PointPleaseWait, &QTextBrowser::hide);  // Server to MainWindow

    //    // True
    //    connect(server_.data(), &ServerReplica::uiChangeToPage3, this, &MainWindow::changeToPage3);  // Both
    //    // False
    //    connect(server_.data(), &ServerReplica::uiErrorOutOfRangeShow, ui->ErrorOutOfRange, &QTextBrowser::show);  // Server to MainWindow
    //    connect(server_.data(), &ServerReplica::uiPointPleaseWaitHide, ui->PointPleaseWait, &QTextBrowser::hide);  // Server to MainWindow

    //    // Page 3

    //    connect(ui->ConfirmButtonNo, &QPushButton::clicked, this, &MainWindow::changeToPage2);  // MainWindow to Both
    //    connect(ui->ConfirmButtonNo, &QPushButton::clicked, server_.data(), &ServerReplica::uiConfirmButtonNoClicked);
    //    connect(ui->ConfirmButtonYes, &QPushButton::clicked, this, &MainWindow::changeToPage4);                           // MainWindow to Both
    //    connect(ui->ConfirmButtonYes, &QPushButton::clicked, server_.data(), &ServerReplica::uiConfirmButtonYesClicked);  // MainWindow to Both

    connect(server_.data(), &ServerReplica::uiDisplayImageSetCamera, provider_.data(), &PixmapProvider::setObjectFeed);  // Server to ui

    //    // Page 4

    //    connect(ui->ButtonBack_2, &QPushButton::clicked, server_.data(), &ServerReplica::uiButtonBack_2Clicked);                // MainWindow to Server
    //    connect(ui->ButtonBack_2, &QPushButton::clicked, this, &MainWindow::changeToPage2);                                     // MainWindow to Both
    //    connect(ui->ButtonReturnObject, &QPushButton::clicked, server_.data(), &ServerReplica::uiButtonReturnObjectClicked);    // MainWindow to server
    //    connect(ui->ButtonRelease, &QPushButton::clicked, server_.data(), &ServerReplica::uiButtonReleaseClicked);              // MainWindow to server
    //    connect(ui->ButtonReplaceObject, &QPushButton::clicked, server_.data(), &ServerReplica::uiButtonReplaceObjectClicked);  // MainWindow to server
    //    connect(ui->ButtonNavigate, &QPushButton::clicked, this, &MainWindow::changeToPage5);
    //    connect(ui->ButtonNavigate, &QPushButton::clicked, server_.data(), &ServerReplica::uiButtonNavigateClicked);  // MainWindow to both

    //    // Server to MainWindow

    //    connect(server_.data(), &ServerReplica::uiButtonReturnObjectSetEnabled, ui->ButtonReturnObject, &QPushButton::setEnabled);

    //    // Page 5

    //    connect(ui->ButtonBackToGrasp, &QPushButton::clicked, server_.data(), &ServerReplica::uiButtonBackToGraspClicked);

    // Page 6
}

// void Client::changeToPage1() {
//     ui->PagesStackedWidget->setCurrentWidget(ui->page_1);
//     ui->ButtonGrasp->show();
//     ui->ButtonGrasp->setEnabled(true);
//     ui->ButtonBackToGrasp->hide();
//     ui->ButtonBackToGrasp->setEnabled(false);
//     QObject::disconnect(DisplayFeedOne_);
//     QObject::disconnect(DisplayFeedTwo_);
// }

// void Client::changeToPage2() {
//     DisplayFeedOne_ = connect(server_.data(), &ServerReplica::uiDisplayCameraSetCamera, ui->DisplayCamera, &SceneViewer::setCameraQImage);
//     QObject::disconnect(DisplayFeedTwo_);
//     ui->ErrorNanPoint->setVisible(false);
//     ui->ErrorOutOfRange->setVisible(false);
//     ui->PointPleaseWait->setVisible(false);
//     ui->PagesStackedWidget->setCurrentWidget(ui->page_2);
// }

// void Client::changeToPage3() {
//     QObject::disconnect(DisplayFeedOne_);
//     QObject::disconnect(DisplayFeedTwo_);
//     ui->PagesStackedWidget->setCurrentWidget(ui->page_3);
// }

// void Client::changeToPage4() {
//     DisplayFeedTwo_ = connect(server_.data(), &ServerReplica::uiDisplayCameraSetCamera, ui->DisplayGrasp, &SceneViewer::setCameraQImage);
//     ui->ButtonReturnObject->setDisabled(true);
//     ui->PagesStackedWidget->setCurrentWidget(ui->page_4);
// }

// void Client::changeToPage5() {
//     ui->ButtonGrasp->hide();
//     ui->ButtonGrasp->setEnabled(false);
//     ui->ButtonBackToGrasp->show();
//     ui->ButtonBackToGrasp->setEnabled(true);
//     ui->PagesStackedWidget->setCurrentWidget(ui->page_1);
// }

// void Client::changeToPage6() {
//     ui->PagesStackedWidget->setCurrentWidget(ui->page_6);
// }

// void Client::showButtonNavigateHome() {
//     ui->ButtonNavigateHome->setEnabled(true);
// }
