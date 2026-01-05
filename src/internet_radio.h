#ifndef INTERNET_RADIO_H
#define INTERNET_RADIO_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QString>
#include <QVariantMap>

// --- New Includes for Metadata ---
#include <QMediaPlayer>
#include <QMediaMetaData>

// Keep standard includes for the raw socket discovery logic
#include <string>
#include <sys/socket.h>

class InternetRadio : public QObject
{
    Q_OBJECT
    // Allow the base URL to be read from QML if needed
    Q_PROPERTY(QString baseUrl READ baseUrl NOTIFY baseUrlChanged)
public:
    explicit InternetRadio(QObject *parent = nullptr);
    ~InternetRadio();

    // --- Static Server Discovery (Existing Logic) ---
    static std::string GetRadioBrowserApiUrl();

    // --- QML Invokable API Methods ---

    // 1. Search stations
    Q_INVOKABLE void searchStations(const QVariantMap &filters);

    // 2. Get station by UUID
    Q_INVOKABLE void getStationByUuid(const QString &uuid);

    // 3. Resolve Stream URL
    Q_INVOKABLE void getStationStreamUrl(const QString &uuid);

    // 4. Optional Lists
    Q_INVOKABLE void getTags(const QString &filter = "", int limit = 100);
    Q_INVOKABLE void getCountries(const QString &filter = "");
    Q_INVOKABLE void getLanguages(const QString &filter = "");
    Q_INVOKABLE void getTopStations(int limit = 20);

    QString baseUrl() const;
    QString currentSongTitle() const;

signals:
    void baseUrlChanged();
    void stationsDataReceived(QVariantList stations);
    void streamUrlReceived(QString stationUuid, QString url);
    void tagsReceived(QVariantList tags);
    void countriesReceived(QVariantList countries);
    void languagesReceived(QVariantList languages);
    void errorOccurred(QString message);


private:
    // Helper for the raw socket logic
    static long MeasureConnectTime(const struct sockaddr* addr, size_t addrlen);

    // Qt Network Manager
    QNetworkAccessManager *m_manager;
    QString m_baseUrl;

    // Helper to process network replies
    void handleJsonReply(QNetworkReply *reply, std::function<void(QJsonDocument)> successCallback);

    // Helper to create QNetworkRequest with User-Agent
    QNetworkRequest createNetworkRequest(const QUrl &url);

    // --- NEW: Player Pointer and Title Storage ---
    QMediaPlayer *m_player = nullptr;
    QString m_currentSongTitle;
};

#endif // INTERNET_RADIO_H
