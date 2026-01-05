#ifndef VLCPLAYER_H
#define VLCPLAYER_H

#include <QObject>
#include <QTimer>
#include <vlcpp/vlc.hpp> // The header-only wrapper

class VlcPlayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY isPlayingChanged)
    Q_PROPERTY(QString currentTitle READ currentTitle NOTIFY currentTitleChanged)

public:
    explicit VlcPlayer(QObject *parent = nullptr);
    ~VlcPlayer();

    Q_INVOKABLE void playUrl(const QString &url);
    Q_INVOKABLE void stop();
    Q_INVOKABLE void setVolume(int volume);
    Q_INVOKABLE void pause();
    Q_INVOKABLE void play();

    bool isPlaying() const;
    QString currentTitle() const;

signals:
    void isPlayingChanged();
    void currentTitleChanged();

private slots:
    void updateMetadata();

private:
    // VLC Objects wrapped in smart pointers by libvlcpp
    VLC::Instance *m_instance = nullptr;
    VLC::MediaPlayer *m_player = nullptr;
    VLC::Media *m_media = nullptr;

    QTimer *m_metaTimer;
    QString m_currentTitle;
    bool m_isPlaying = false;
};

#endif // VLCPLAYER_H
