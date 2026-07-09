#include "animationcontroller.h"
#include <QDebug>

AnimationController::AnimationController(QObject *parent)
    : QObject(parent)
    , m_baseDuration(500)
    , m_speedMultiplier(1.0)
    , m_lastLog("System initialized.")
{
}

int AnimationController::baseDuration() const
{
    return m_baseDuration;
}

void AnimationController::setBaseDuration(int duration)
{
    if (m_baseDuration != duration) {
        m_baseDuration = duration;
        emit baseDurationChanged();
    }
}

double AnimationController::speedMultiplier() const
{
    return m_speedMultiplier;
}

void AnimationController::setSpeedMultiplier(double multiplier)
{
    if (qFuzzyCompare(m_speedMultiplier, multiplier)) return;
    m_speedMultiplier = multiplier;
    emit speedMultiplierChanged();
}

QString AnimationController::lastLog() const
{
    return m_lastLog;
}

void AnimationController::logAnimationStart(const QString &category, const QString &type)
{
    m_lastLog = QString("[%1] Started %2 animation").arg(category, type);
    qDebug() << m_lastLog;
    emit lastLogChanged();
}

void AnimationController::logAnimationComplete(const QString &category, const QString &type)
{
    m_lastLog = QString("[%1] Completed %2 animation").arg(category, type);
    qDebug() << m_lastLog;
    emit lastLogChanged();
}

int AnimationController::getCalculatedDuration(int originalDuration) const
{
    if (m_speedMultiplier <= 0.0) return 0;
    return static_cast<int>(originalDuration / m_speedMultiplier);
}
