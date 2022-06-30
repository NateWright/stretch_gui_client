#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "Client.hpp"

int main(int argc, char *argv[]) {
    QQuickStyle::setStyle("Material");
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/test/main.qml"_qs);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);


    QSharedPointer<ServerReplica> ptr;  // shared pointer to hold source replica

    QRemoteObjectNode repNode;                                                 // create remote object node
    repNode.connectToNode(QUrl(QStringLiteral("tcp://192.168.86.157:9999")));  // connect with remote host node
    // repNode.connectToNode(QUrl(QStringLiteral("local:switch")));
    ptr.reset(repNode.acquire<ServerReplica>());  // acquire replica of source from host node
    Client c(ptr);
    engine.addImageProvider(QLatin1String("service"), c.getProvider().data());
    engine.rootContext()->setContextProperty("client", &c);
    engine.rootContext()->setContextProperty("server", ptr.data());
    engine.rootContext()->setContextProperty("imgProvider", c.getProvider().data());
    engine.load(url);

    return app.exec();
}
