#include "vlcplayer.h"
#include <QDebug>

VlcPlayer::VlcPlayer(QObject *parent) : QObject(parent)
{
    // 1. Initialize VLC Instance (Passing 0 args)
    m_instance = new VLC::Instance(0, nullptr);

    // Set user agent and app ID
    m_instance->setUserAgent( "Car-Infotainment/1.0", "Car-Infotainment" );


    // 2. Create an empty Media Player
    m_player = new VLC::MediaPlayer(*m_instance);

    // 3. Timer to poll metadata (Every 1 second)
    m_metaTimer = new QTimer(this);
    connect(m_metaTimer, &QTimer::timeout, this, &VlcPlayer::updateMetadata);
}

VlcPlayer::~VlcPlayer()
{
    stop();
    delete m_metaTimer;
    if (m_media) delete m_media;
    delete m_player;
    delete m_instance;
}

void VlcPlayer::playUrl(const QString &url)
{
    // Create new media from URL
    if (m_media) delete m_media;
    m_media = new VLC::Media(*m_instance, url.toStdString(), VLC::Media::FromLocation);

    // Assign to player
    m_player->setMedia(*m_media);

    // Play
    m_player->play();

    m_isPlaying = true;
    emit isPlayingChanged();

    // Start checking for metadata
    m_metaTimer->start(1000);
}

void VlcPlayer::stop()
{
    m_player->stop();
    m_metaTimer->stop();
    m_isPlaying = false;
    m_currentTitle = "";
    emit isPlayingChanged();
    emit currentTitleChanged();
}

void VlcPlayer::pause()
{
    m_player->pause();
    m_isPlaying = false;
    emit isPlayingChanged();
}

void VlcPlayer::play()
{
    if (m_player) {
        m_player->play();
        m_isPlaying = true;
        emit isPlayingChanged();
    }
}

void VlcPlayer::setVolume(int volume)
{
    m_player->setVolume(volume);
}

bool VlcPlayer::isPlaying() const { return m_isPlaying; }
QString VlcPlayer::currentTitle() const { return m_currentTitle; }

void VlcPlayer::updateMetadata()
{
    if (!m_media) return;

    std::string titleStr = m_media->meta(libvlc_meta_NowPlaying);

    // Fallback if NowPlaying is empty (some stations use Title)
    if (titleStr.empty()) {
        titleStr = m_media->meta(libvlc_meta_Title);
    }

    QString newTitle = QString::fromStdString(titleStr);

    if (newTitle != m_currentTitle && !newTitle.isEmpty()) {
        m_currentTitle = newTitle;
        emit currentTitleChanged();
    }
}
