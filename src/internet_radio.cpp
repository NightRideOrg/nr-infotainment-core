#include "internet_radio.h"
#include <QDebug>
#include <QUrlQuery>

// Linux Networking Headers (For the Discovery Logic)
#include <arpa/inet.h>
#include <fcntl.h>
#include <netdb.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>
#include <chrono>
#include <cstring>
#include <limits>
#include <iostream>

InternetRadio::InternetRadio(QObject *parent) : QObject(parent)
{
    m_manager = new QNetworkAccessManager(this);

    // Resolve the server immediately upon creation
    std::string fastest = GetRadioBrowserApiUrl();
    m_baseUrl = QString::fromStdString(fastest);

    qDebug() << "InternetRadio Initialized. API Server:" << m_baseUrl;
    emit baseUrlChanged();
}

InternetRadio::~InternetRadio()
{
    if (m_player) {
        m_player->stop();
    }
}

QString InternetRadio::baseUrl() const {
    return m_baseUrl;
}


// ============================================================================
// API IMPLEMENTATIONS
// ============================================================================

QNetworkRequest InternetRadio::createNetworkRequest(const QUrl &url)
{
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "NightRide/0.1");
    return request;
}

void InternetRadio::searchStations(const QVariantMap &filters)
{
    QUrl url("http://" + m_baseUrl + "/json/stations/search");
    QNetworkRequest request = createNetworkRequest(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QUrlQuery params;
    for(auto it = filters.begin(); it != filters.end(); ++it) {
        params.addQueryItem(it.key(), it.value().toString());
    }

    QNetworkReply *reply = m_manager->post(request, params.toString(QUrl::FullyEncoded).toUtf8());

    handleJsonReply(reply, [this](QJsonDocument doc) {
        if (doc.isArray()) {
            emit stationsDataReceived(doc.array().toVariantList());
        }
    });
}

void InternetRadio::getStationByUuid(const QString &uuid)
{
    QUrl url("http://" + m_baseUrl + "/json/stations/byuuid/" + uuid);
    QNetworkRequest request = createNetworkRequest(url);

    QNetworkReply *reply = m_manager->get(request);

    handleJsonReply(reply, [this](QJsonDocument doc) {
        if (doc.isArray()) {
            emit stationsDataReceived(doc.array().toVariantList());
        }
    });
}

void InternetRadio::getStationStreamUrl(const QString &uuid)
{
    QUrl url("http://" + m_baseUrl + "/json/url/" + uuid);
    QNetworkRequest request = createNetworkRequest(url);
    request.setAttribute(QNetworkRequest::User, uuid);

    QNetworkReply *reply = m_manager->get(request);

    handleJsonReply(reply, [this, reply](QJsonDocument doc) {
        if (doc.isObject()) {
            QString resultUrl = doc.object().value("url").toString();
            QString requestUuid = reply->request().attribute(QNetworkRequest::User).toString();

            if (resultUrl.isEmpty()) {
                emit errorOccurred("Stream URL not found in response");
            } else {
                emit streamUrlReceived(requestUuid, resultUrl);
            }
        }
    });
}

void InternetRadio::getTags(const QString &filter, int limit)
{
    QString path = "/json/tags";
    if (!filter.isEmpty()) path += "/" + filter;

    QUrl url("http://" + m_baseUrl + path);
    QUrlQuery query;
    query.addQueryItem("limit", QString::number(limit));
    query.addQueryItem("order", "stationcount");
    query.addQueryItem("reverse", "true");
    url.setQuery(query);

    QNetworkReply *reply = m_manager->get(createNetworkRequest(url));

    handleJsonReply(reply, [this](QJsonDocument doc) {
        if (doc.isArray()) emit tagsReceived(doc.array().toVariantList());
    });
}

void InternetRadio::getCountries(const QString &filter)
{
    QString path = "/json/countries";
    if (!filter.isEmpty()) path += "/" + filter;

    QUrl url("http://" + m_baseUrl + path);
    QNetworkReply *reply = m_manager->get(createNetworkRequest(url));

    handleJsonReply(reply, [this](QJsonDocument doc) {
        if (doc.isArray()) emit countriesReceived(doc.array().toVariantList());
    });
}

void InternetRadio::getLanguages(const QString &filter)
{
    QString path = "/json/languages";
    if (!filter.isEmpty()) path += "/" + filter;

    QUrl url("http://" + m_baseUrl + path);
    QNetworkReply *reply = m_manager->get(createNetworkRequest(url));

    handleJsonReply(reply, [this](QJsonDocument doc) {
        if (doc.isArray()) emit languagesReceived(doc.array().toVariantList());
    });
}

void InternetRadio::getTopStations(int limit)
{
    QUrl url("http://" + m_baseUrl + "/json/stations/topclick/" + QString::number(limit));
    QNetworkReply *reply = m_manager->get(createNetworkRequest(url));

    handleJsonReply(reply, [this](QJsonDocument doc) {
        if (doc.isArray()) emit stationsDataReceived(doc.array().toVariantList());
    });
}

void InternetRadio::handleJsonReply(QNetworkReply *reply, std::function<void(QJsonDocument)> successCallback)
{
    connect(reply, &QNetworkReply::finished, this, [this, reply, successCallback]() {
        if (reply->error() != QNetworkReply::NoError) {
            emit errorOccurred(reply->errorString());
            reply->deleteLater();
            return;
        }

        QByteArray data = reply->readAll();
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

        if (parseError.error != QJsonParseError::NoError) {
            emit errorOccurred("JSON Parse Error: " + parseError.errorString());
        } else {
            successCallback(doc);
        }

        reply->deleteLater();
    });
}

// ============================================================================
// STATIC DISCOVERY LOGIC (Unchanged)
// ============================================================================

std::string InternetRadio::GetRadioBrowserApiUrl()
{
    std::string baseUrl = "all.api.radio-browser.info";
    std::string searchUrl = "de2.api.radio-browser.info";

    struct addrinfo hints = {};
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    struct addrinfo *result = nullptr;

    if (getaddrinfo(baseUrl.c_str(), "80", &hints, &result) != 0) {
        return searchUrl;
    }

    long lastRoundTripTime = std::numeric_limits<long>::max();

    struct sockaddr_storage bestAddr = {};
    socklen_t bestAddrLen = 0;
    bool foundBetter = false;

    for (struct addrinfo *ptr = result; ptr != nullptr; ptr = ptr->ai_next) {
        long timeTaken = MeasureConnectTime(ptr->ai_addr, ptr->ai_addrlen);

        if (timeTaken != -1 && timeTaken < lastRoundTripTime) {
            lastRoundTripTime = timeTaken;
            std::memcpy(&bestAddr, ptr->ai_addr, ptr->ai_addrlen);
            bestAddrLen = ptr->ai_addrlen;
            foundBetter = true;

            char hostBuf[NI_MAXHOST];
            if (getnameinfo(ptr->ai_addr, ptr->ai_addrlen, hostBuf, sizeof(hostBuf),
                            nullptr, 0, NI_NUMERICHOST) == 0) {
                searchUrl = std::string(hostBuf);
            }
        }
    }

    freeaddrinfo(result);

    if (foundBetter) {
        char hostName[NI_MAXHOST];
        if (getnameinfo((struct sockaddr *) &bestAddr, bestAddrLen,
                        hostName, sizeof(hostName), nullptr, 0, NI_NAMEREQD) == 0) {
            searchUrl = std::string(hostName);
        }
    }

    return searchUrl;
}

long InternetRadio::MeasureConnectTime(const sockaddr *addr, size_t addrlen)
{
    int sockfd = socket(addr->sa_family, SOCK_STREAM, 0);
    if (sockfd < 0) return -1;

    int flags = fcntl(sockfd, F_GETFL, 0);
    fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

    auto start = std::chrono::high_resolution_clock::now();

    int res = ::connect(sockfd, addr, addrlen);

    if (res < 0) {
        if (errno == EINPROGRESS) {
            fd_set myset;
            struct timeval tv;
            FD_ZERO(&myset);
            FD_SET(sockfd, &myset);
            tv.tv_sec = 1;
            tv.tv_usec = 0;

            if (select(sockfd + 1, NULL, &myset, NULL, &tv) > 0) {
                int so_error;
                socklen_t len = sizeof so_error;
                getsockopt(sockfd, SOL_SOCKET, SO_ERROR, &so_error, &len);
                if (so_error == 0) res = 0;
            }
        }
    }

    auto end = std::chrono::high_resolution_clock::now();
    close(sockfd);

    if (res == 0) {
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
        return (long) duration;
    }
    return -1;
}
