#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "playermanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Media Player");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("QtShowcase");

    PlayerManager playerManager;

    QQmlApplicationEngine qmlEngine;
    qmlEngine.rootContext()->setContextProperty("playerManager", &playerManager);

    QObject::connect(
        &qmlEngine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    qmlEngine.loadFromModule("mediaplayer", "Main");

    return QGuiApplication::exec();
}
