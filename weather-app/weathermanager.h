#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QTimer>

class WeatherManager : public QObject
{
    Q_OBJECT

    // Current weather
    Q_PROPERTY(QString cityName       READ cityName       NOTIFY weatherUpdated)
    Q_PROPERTY(QString countryCode    READ countryCode    NOTIFY weatherUpdated)
    Q_PROPERTY(int     temperature    READ temperature    NOTIFY weatherUpdated)
    Q_PROPERTY(int     feelsLike      READ feelsLike      NOTIFY weatherUpdated)
    Q_PROPERTY(int     humidity       READ humidity       NOTIFY weatherUpdated)
    Q_PROPERTY(double  windSpeed      READ windSpeed      NOTIFY weatherUpdated)
    Q_PROPERTY(int     pressure       READ pressure       NOTIFY weatherUpdated)
    Q_PROPERTY(int     visibility     READ visibility     NOTIFY weatherUpdated)
    Q_PROPERTY(QString condition      READ condition      NOTIFY weatherUpdated)
    Q_PROPERTY(QString weatherEmoji   READ weatherEmoji   NOTIFY weatherUpdated)
    Q_PROPERTY(QString bgGradientTop  READ bgGradientTop  NOTIFY weatherUpdated)
    Q_PROPERTY(QString bgGradientBot  READ bgGradientBot  NOTIFY weatherUpdated)
    Q_PROPERTY(QString sunriseTime    READ sunriseTime    NOTIFY weatherUpdated)
    Q_PROPERTY(QString sunsetTime     READ sunsetTime     NOTIFY weatherUpdated)

    // UI State
    Q_PROPERTY(bool    isLoading      READ isLoading      NOTIFY loadingChanged)
    Q_PROPERTY(QString errorMessage   READ errorMessage   NOTIFY errorChanged)
    Q_PROPERTY(bool    hasData        READ hasData        NOTIFY weatherUpdated)
    Q_PROPERTY(QString apiKey         READ apiKey   WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(QString lastUpdated    READ lastUpdated    NOTIFY weatherUpdated)

    // Forecast
    Q_PROPERTY(QVariantList forecast READ forecast NOTIFY weatherUpdated)

public:
    explicit WeatherManager(QObject *parent = nullptr);

    QString cityName()      const { return m_cityName; }
    QString countryCode()   const { return m_countryCode; }
    int     temperature()   const { return m_temperature; }
    int     feelsLike()     const { return m_feelsLike; }
    int     humidity()      const { return m_humidity; }
    double  windSpeed()     const { return m_windSpeed; }
    int     pressure()      const { return m_pressure; }
    int     visibility()    const { return m_visibility; }
    QString condition()     const { return m_condition; }
    QString weatherEmoji()  const { return m_weatherEmoji; }
    QString bgGradientTop() const { return m_bgGradientTop; }
    QString bgGradientBot() const { return m_bgGradientBot; }
    QString sunriseTime()   const { return m_sunriseTime; }
    QString sunsetTime()    const { return m_sunsetTime; }
    bool    isLoading()     const { return m_isLoading; }
    QString errorMessage()  const { return m_errorMessage; }
    bool    hasData()       const { return m_hasData; }
    QString apiKey()        const { return m_apiKey; }
    QString lastUpdated()   const { return m_lastUpdated; }
    QVariantList forecast() const { return m_forecast; }

    void setApiKey(const QString &key);

public slots:
    Q_INVOKABLE void fetchWeather(const QString &city);
    Q_INVOKABLE void refreshWeather();

signals:
    void weatherUpdated();
    void loadingChanged();
    void errorChanged();
    void apiKeyChanged();

private slots:
    void onCurrentWeatherReply(QNetworkReply *reply);
    void onForecastReply(QNetworkReply *reply);

private:
    void setLoading(bool loading);
    void setError(const QString &msg);
    void applyWeatherTheme(const QString &iconCode);
    QString emojiForIcon(const QString &iconCode) const;
    QString formatUnixTime(qint64 unixTime, int offsetSecs) const;

    QNetworkAccessManager *m_networkManager;
    QNetworkAccessManager *m_forecastManager;

    QString m_cityName;
    QString m_countryCode;
    int     m_temperature   = 0;
    int     m_feelsLike     = 0;
    int     m_humidity      = 0;
    double  m_windSpeed     = 0.0;
    int     m_pressure      = 0;
    int     m_visibility    = 0;
    QString m_condition;
    QString m_weatherEmoji  = "🌤️";
    QString m_bgGradientTop = "#1e3a5f";
    QString m_bgGradientBot = "#0d1b2a";
    QString m_sunriseTime;
    QString m_sunsetTime;
    bool    m_isLoading     = false;
    QString m_errorMessage;
    bool    m_hasData       = false;
    QString m_apiKey;
    QString m_lastUpdated;
    QString m_lastCity;
    QVariantList m_forecast;
};
