#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

class AnimationController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int baseDuration READ baseDuration WRITE setBaseDuration NOTIFY baseDurationChanged)
    Q_PROPERTY(double speedMultiplier READ speedMultiplier WRITE setSpeedMultiplier NOTIFY speedMultiplierChanged)
    Q_PROPERTY(QString lastLog READ lastLog NOTIFY lastLogChanged)

public:
    explicit AnimationController(QObject *parent = nullptr);
    int baseDuration() const;
    double speedMultiplier() const;
    QString lastLog() const;

public slots:
    void setBaseDuration(int duration);
    void setSpeedMultiplier(double multiplier);
    void logAnimationStart(const QString &category, const QString &type);
    void logAnimationComplete(const QString &category, const QString &type);
    int getCalculatedDuration(int originalDuration) const;

signals:
    void baseDurationChanged();
    void speedMultiplierChanged();
    void lastLogChanged();

private:
    int m_baseDuration;
    double m_speedMultiplier;
    QString m_lastLog;
};
