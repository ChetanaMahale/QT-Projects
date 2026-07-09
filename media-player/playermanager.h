#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantMap>
#include <QList>
#include <QTimer>

struct Track {
    QString title;
    QString artist;
    int duration; // in seconds
    QString cover;
};

class PlayerManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList playlist READ playlist CONSTANT)
    Q_PROPERTY(int currentTrackIndex READ currentTrackIndex WRITE setCurrentTrackIndex NOTIFY currentTrackIndexChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY playbackStateChanged)
    Q_PROPERTY(int playbackPosition READ playbackPosition WRITE setPlaybackPosition NOTIFY playbackPositionChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(bool isMuted READ isMuted WRITE setIsMuted NOTIFY isMutedChanged)

    // Helper properties for current track metadata
    Q_PROPERTY(QString currentTitle READ currentTitle NOTIFY currentTrackChanged)
    Q_PROPERTY(QString currentArtist READ currentArtist NOTIFY currentTrackChanged)
    Q_PROPERTY(int currentDuration READ currentDuration NOTIFY currentTrackChanged)
    Q_PROPERTY(QString currentCover READ currentCover NOTIFY currentTrackChanged)

public:
    explicit PlayerManager(QObject *parent = nullptr);

    QVariantList playlist() const;
    int currentTrackIndex() const;
    void setCurrentTrackIndex(int index);

    bool isPlaying() const;
    int playbackPosition() const;
    void setPlaybackPosition(int position);

    int volume() const;
    void setVolume(int volume);

    bool isMuted() const;
    void setIsMuted(bool muted);

    // Metadata getters
    QString currentTitle() const;
    QString currentArtist() const;
    int currentDuration() const;
    QString currentCover() const;

public slots:
    void play();
    void pause();
    void stop();
    void next();
    void previous();
    void togglePlay();
    void toggleMute();
    Q_INVOKABLE QString formatTime(int seconds) const;

signals:
    void currentTrackIndexChanged();
    void playbackStateChanged();
    void playbackPositionChanged();
    void volumeChanged();
    void isMutedChanged();
    void currentTrackChanged();

private:
    void handlePlaybackTick();

    QList<Track> m_tracks;
    int m_currentTrackIndex;
    bool m_isPlaying;
    int m_playbackPosition; // in seconds
    int m_volume;
    bool m_isMuted;
    QTimer *m_playbackTimer;
};
