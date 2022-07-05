#ifndef PIXMAPPROVIDER_HPP
#define PIXMAPPROVIDER_HPP

#include <QDebug>
#include <QImage>
#include <QQuickImageProvider>
#include <regex>

class PixmapProvider : public QQuickImageProvider {
    Q_OBJECT
   public:
    PixmapProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

   private:
    QImage map_;
    uint mapId_;
    std::regex mapRegex_;
    QImage cameraFeed_;
    uint cameraFeedId_;
    std::regex cameraFeedRegex_;
    QImage objectFeed_;
    uint objectFeedId_;
    std::regex objectFeedRegex_;
   signals:
    void newMap(uint);
    void newCameraFeed(uint);
    void newObjectFeed(uint);
   public slots:
    void setMap(QImage);
    void setCameraFeed(QImage);
    void setObjectFeed(QImage);
};

#endif  // PIXMAPPROVIDER_HPP
