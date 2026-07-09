#include "weathermanager.h"

#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDateTime>
#include <QTimeZone>
#include <QDebug>
#include <QUrl>
#include <QUrlQuery>

static const QString BASE_URL = "https://api.openweathermap.org/data/2.5/";

WeatherManager::WeatherManager(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_forecastManager(new QNetworkAccessManager(this))
{
    connect(m_networkManager, &QNetworkAccessManager::finished,
            this, &WeatherManager::onCurrentWeatherReply);
    connect(m_forecastManager, &QNetworkAccessManager::finished,
            this, &WeatherManager::onForecastReply);
}

void WeatherManager::setApiKey(const QString &key)
{
    if (m_apiKey != key) {
        m_apiKey = key;
        emit apiKeyChanged();
    }
}

void WeatherManager::fetchWeather(const QString &city)
{
    if (m_apiKey.trimmed().isEmpty()) {
        setError("Please enter your OpenWeatherMap API key first.");
        return;
    }
    if (city.trimmed().isEmpty()) {
        setError("Please enter a city name.");
        return;
    }

    m_lastCity = city.trimmed();
    setLoading(true);
    m_errorMessage.clear();

    // Current weather request
    QUrl currentUrl(BASE_URL + "weather");
    QUrlQuery currentQuery;
    currentQuery.addQueryItem("q",     m_lastCity);
    currentQuery.addQueryItem("appid", m_apiKey.trimmed());
    currentQuery.addQueryItem("units", "metric");
    currentUrl.setQuery(currentQuery);
    m_networkManager->get(QNetworkRequest(currentUrl));

    // 5-day / 3-hour forecast request
    QUrl forecastUrl(BASE_URL + "forecast");
    QUrlQuery forecastQuery;
    forecastQuery.addQueryItem("q",     m_lastCity);
    forecastQuery.addQueryItem("appid", m_apiKey.trimmed());
    forecastQuery.addQueryItem("units", "metric");
    forecastQuery.addQueryItem("cnt",   "40");
    forecastUrl.setQuery(forecastQuery);
    m_forecastManager->get(QNetworkRequest(forecastUrl));
}

void WeatherManager::refreshWeather()
{
    if (!m_lastCity.isEmpty()) {
        fetchWeather(m_lastCity);
    }
}

void WeatherManager::onCurrentWeatherReply(QNetworkReply *reply)
{
    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError) {
        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if (statusCode == 404) {
            setError("City not found. Please check the spelling.");
        } else if (statusCode == 401) {
            setError("Invalid API key. Check your OpenWeatherMap key.");
        } else {
            setError("Network error: " + reply->errorString());
        }
        setLoading(false);
        return;
    }

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject()) {
        setError("Invalid response from server.");
        setLoading(false);
        return;
    }

    QJsonObject root = doc.object();

    m_cityName    = root["name"].toString();
    m_countryCode = root["sys"].toObject()["country"].toString();

    QJsonObject main = root["main"].toObject();
    m_temperature = qRound(main["temp"].toDouble());
    m_feelsLike   = qRound(main["feels_like"].toDouble());
    m_humidity    = main["humidity"].toInt();
    m_pressure    = main["pressure"].toInt();

    m_windSpeed   = root["wind"].toObject()["speed"].toDouble();
    m_visibility  = root["visibility"].toInt() / 1000; // m → km

    QJsonArray weather = root["weather"].toArray();
    if (!weather.isEmpty()) {
        QJsonObject w = weather[0].toObject();
        m_condition    = w["description"].toString();
        // Capitalize first letter
        if (!m_condition.isEmpty())
            m_condition[0] = m_condition[0].toUpper();
        QString iconCode = w["icon"].toString();
        m_weatherEmoji = emojiForIcon(iconCode);
        applyWeatherTheme(iconCode);
    }

    int tzOffset = root["timezone"].toInt();
    QJsonObject sys = root["sys"].toObject();
    m_sunriseTime = formatUnixTime(sys["sunrise"].toVariant().toLongLong(), tzOffset);
    m_sunsetTime  = formatUnixTime(sys["sunset"].toVariant().toLongLong(), tzOffset);

    m_hasData = true;
    m_lastUpdated = QDateTime::currentDateTime().toString("hh:mm AP");

    setLoading(false);
    emit weatherUpdated();
}

void WeatherManager::onForecastReply(QNetworkReply *reply)
{
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) return;

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject()) return;

    QJsonArray list = doc.object()["list"].toArray();

    // Build daily summaries — pick one entry per day (noon-ish)
    m_forecast.clear();
    QSet<QString> seenDays;
    int tzOffset = doc.object()["city"].toObject()["timezone"].toInt();

    for (const QJsonValue &val : list) {
        QJsonObject entry = val.toObject();
        qint64 dt = entry["dt"].toVariant().toLongLong();
        QDateTime utc = QDateTime::fromSecsSinceEpoch(dt, Qt::UTC);
        QDateTime local = utc.addSecs(tzOffset);
        QString dayKey = local.toString("yyyy-MM-dd");
        int hour = local.time().hour();

        // Skip today and pick 11:00-14:00 slots
        if (seenDays.contains(dayKey)) continue;
        if (hour < 11 || hour > 14) continue;

        seenDays.insert(dayKey);

        QJsonObject main = entry["main"].toObject();
        QJsonArray weather = entry["weather"].toArray();
        QString iconCode;
        QString desc;
        if (!weather.isEmpty()) {
            iconCode = weather[0].toObject()["icon"].toString();
            desc     = weather[0].toObject()["description"].toString();
        }

        QVariantMap day;
        day["dayName"]  = local.toString("ddd");
        day["date"]     = local.toString("MMM d");
        day["tempHigh"] = qRound(main["temp_max"].toDouble());
        day["tempLow"]  = qRound(main["temp_min"].toDouble());
        day["emoji"]    = emojiForIcon(iconCode);
        day["desc"]     = desc;
        day["humidity"] = main["humidity"].toInt();
        m_forecast.append(day);

        if (m_forecast.size() >= 5) break;
    }

    emit weatherUpdated();
}

void WeatherManager::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit loadingChanged();
    }
}

void WeatherManager::setError(const QString &msg)
{
    m_errorMessage = msg;
    emit errorChanged();
}

QString WeatherManager::emojiForIcon(const QString &iconCode) const
{
    if (iconCode.startsWith("01")) return iconCode.endsWith("n") ? "🌙" : "☀️";
    if (iconCode.startsWith("02")) return "🌤️";
    if (iconCode.startsWith("03")) return "🌥️";
    if (iconCode.startsWith("04")) return "☁️";
    if (iconCode.startsWith("09")) return "🌧️";
    if (iconCode.startsWith("10")) return iconCode.endsWith("n") ? "🌧️" : "🌦️";
    if (iconCode.startsWith("11")) return "⛈️";
    if (iconCode.startsWith("13")) return "❄️";
    if (iconCode.startsWith("50")) return "🌫️";
    return "🌤️";
}

void WeatherManager::applyWeatherTheme(const QString &iconCode)
{
    bool isNight = iconCode.endsWith("n");

    if (iconCode.startsWith("01")) {
        m_bgGradientTop = isNight ? "#0f0c29" : "#1a6fa8";
        m_bgGradientBot = isNight ? "#302b63" : "#0a3d62";
    } else if (iconCode.startsWith("02") || iconCode.startsWith("03")) {
        m_bgGradientTop = isNight ? "#1c1c2e" : "#4a6fa5";
        m_bgGradientBot = isNight ? "#16213e" : "#2c3e50";
    } else if (iconCode.startsWith("04")) {
        m_bgGradientTop = "#2d3436";
        m_bgGradientBot = "#636e72";
    } else if (iconCode.startsWith("09") || iconCode.startsWith("10")) {
        m_bgGradientTop = "#1e3c72";
        m_bgGradientBot = "#2a5298";
    } else if (iconCode.startsWith("11")) {
        m_bgGradientTop = "#0f0c29";
        m_bgGradientBot = "#24243e";
    } else if (iconCode.startsWith("13")) {
        m_bgGradientTop = "#a8c0cc";
        m_bgGradientBot = "#3f4c6b";
    } else if (iconCode.startsWith("50")) {
        m_bgGradientTop = "#757f9a";
        m_bgGradientBot = "#d7dde8";
    } else {
        m_bgGradientTop = "#1e3a5f";
        m_bgGradientBot = "#0d1b2a";
    }
}

QString WeatherManager::formatUnixTime(qint64 unixTime, int offsetSecs) const
{
    QDateTime utc = QDateTime::fromSecsSinceEpoch(unixTime, Qt::UTC);
    QDateTime local = utc.addSecs(offsetSecs);
    return local.toString("h:mm AP");
}
