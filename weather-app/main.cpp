#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "weathermanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Weather App");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("QtShowcase");

    WeatherManager weatherManager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("weather", &weatherManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("weatherapp", "Main");

    return QGuiApplication::exec();
}
