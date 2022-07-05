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
    QSharedPointer<ServerReplica> ptr;
    QSharedPointer<QRemoteObjectNode> repNode;
    repNode.reset(new QRemoteObjectNode());
    Client c(ptr, repNode);
    engine.addImageProvider(QLatin1String("service"), c.getProvider().data());
    engine.rootContext()->setContextProperty("client", &c);
    engine.rootContext()->setContextProperty("imgProvider", c.getProvider().data());
    engine.load(url);

    return app.exec();
}
