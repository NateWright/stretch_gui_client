#include "PixmapProvider.hpp"

PixmapProvider::PixmapProvider() : QQuickImageProvider(QQuickImageProvider::Image) {
    mapRegex_ = std::regex("map");
    cameraFeedRegex_ = std::regex("cameraFeed");
    objectFeedRegex_ = std::regex("objectFeed");
    //    qDebug() << "initiated";
    mapId_ = 0;
    cameraFeedId_ = 0;
    objectFeedId_ = 0;
}

QImage PixmapProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize) {
    //    qDebug() << "new request";
    if (std::regex_search(id.toStdString(), mapRegex_)) {
        return map_;
    } else if (std::regex_search(id.toStdString(), cameraFeedRegex_)) {
        return cameraFeed_;
    } else if (std::regex_search(id.toStdString(), objectFeedRegex_)) {
        return objectFeed_;
    }
    QImage img(50, 50, QImage::Format_RGB888);
    img.fill(Qt::red);
    return img;
}

void PixmapProvider::setMap(QImage q) {
    map_ = q;
    mapId_++;
    emit newMap(mapId_);
}

void PixmapProvider::setCameraFeed(QImage q) {
    cameraFeed_ = q;
    cameraFeedId_++;
    emit newCameraFeed(cameraFeedId_);
}
void PixmapProvider::setObjectFeed(QImage q) {
    objectFeed_ = q;
    objectFeedId_++;
    emit newObjectFeed(objectFeedId_);
}
