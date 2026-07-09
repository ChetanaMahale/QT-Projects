#include "playermanager.h"
#include <QDebug>

PlayerManager::PlayerManager(QObject *parent)
    : QObject(parent)
    , m_currentTrackIndex(0)
    , m_isPlaying(false)
    , m_playbackPosition(0)
    , m_volume(75)
    , m_isMuted(false)
{
    // Seed playlist metadata
    m_tracks = {
        { "Retro Waves", "Sunset Drive", 192, "🌆" },
        { "Summer Breeze", "Lofi Chill Out", 145, "🏖️" },
        { "Cyber Ambient", "Ada System", 240, "👾" },
        { "Mountain Peak", "Acoustic Horizon", 178, "🏔️" },
        { "Midnight Train", "City Jazz Quartet", 215, "🎷" }
    };

    m_playbackTimer = new QTimer(this);
    m_playbackTimer->setInterval(1000); // 1 second tick
    connect(m_playbackTimer, &QTimer::timeout, this, &PlayerManager::handlePlaybackTick);
}

QVariantList PlayerManager::playlist() const
{
    QVariantList list;
    for (int i = 0; i < m_tracks.size(); ++i) {
        QVariantMap map;
        map["index"] = i;
        map["title"] = m_tracks[i].title;
        map["artist"] = m_tracks[i].artist;
        map["duration"] = m_tracks[i].duration;
        map["durationText"] = formatTime(m_tracks[i].duration);
        map["cover"] = m_tracks[i].cover;
        list.append(map);
    }
    return list;
}

int PlayerManager::currentTrackIndex() const { return m_currentTrackIndex; }

void PlayerManager::setCurrentTrackIndex(int index)
{
    if (index >= 0 && index < m_tracks.size() && m_currentTrackIndex != index) {
        m_currentTrackIndex = index;
        m_playbackPosition = 0;
        emit currentTrackIndexChanged();
        emit currentTrackChanged();
        emit playbackPositionChanged();
    }
}

bool PlayerManager::isPlaying() const { return m_isPlaying; }
int PlayerManager::playbackPosition() const { return m_playbackPosition; }

void PlayerManager::setPlaybackPosition(int position)
{
    int maxDuration = currentDuration();
    int boundPos = qBound(0, position, maxDuration);
    if (m_playbackPosition != boundPos) {
        m_playbackPosition = boundPos;
        emit playbackPositionChanged();
    }
}

int PlayerManager::volume() const { return m_volume; }

void PlayerManager::setVolume(int volume)
{
    int boundVol = qBound(0, volume, 100);
    if (m_volume != boundVol) {
        m_volume = boundVol;
        emit volumeChanged();
    }
}

bool PlayerManager::isMuted() const { return m_isMuted; }

void PlayerManager::setIsMuted(bool muted)
{
    if (m_isMuted != muted) {
        m_isMuted = muted;
        emit isMutedChanged();
    }
}

// Metadata getters
QString PlayerManager::currentTitle() const { return m_tracks[m_currentTrackIndex].title; }
QString PlayerManager::currentArtist() const { return m_tracks[m_currentTrackIndex].artist; }
int PlayerManager::currentDuration() const { return m_tracks[m_currentTrackIndex].duration; }
QString PlayerManager::currentCover() const { return m_tracks[m_currentTrackIndex].cover; }

// Playback slots
void PlayerManager::play()
{
    if (!m_isPlaying) {
        m_isPlaying = true;
        m_playbackTimer->start();
        emit playbackStateChanged();
    }
}

void PlayerManager::pause()
{
    if (m_isPlaying) {
        m_isPlaying = false;
        m_playbackTimer->stop();
        emit playbackStateChanged();
    }
}

void PlayerManager::stop()
{
    if (m_isPlaying || m_playbackPosition != 0) {
        m_isPlaying = false;
        m_playbackTimer->stop();
        m_playbackPosition = 0;
        emit playbackStateChanged();
        emit playbackPositionChanged();
    }
}

void PlayerManager::next()
{
    int nextIndex = (m_currentTrackIndex + 1) % m_tracks.size();
    setCurrentTrackIndex(nextIndex);
}

void PlayerManager::previous()
{
    int prevIndex = (m_currentTrackIndex - 1 + m_tracks.size()) % m_tracks.size();
    setCurrentTrackIndex(prevIndex);
}

void PlayerManager::togglePlay()
{
    if (m_isPlaying) pause();
    else play();
}

void PlayerManager::toggleMute()
{
    setIsMuted(!m_isMuted);
}

QString PlayerManager::formatTime(int seconds) const
{
    int m = seconds / 60;
    int s = seconds % 60;
    return QString("%1:%2").arg(m).arg(s, 2, 10, QChar('0'));
}

void PlayerManager::handlePlaybackTick()
{
    int maxDuration = currentDuration();
    if (m_playbackPosition >= maxDuration) {
        // Track finished, skip to next
        next();
    } else {
        m_playbackPosition++;
        emit playbackPositionChanged();
    }
}
