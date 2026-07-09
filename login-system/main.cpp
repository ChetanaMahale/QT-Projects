#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "authmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Login System");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("QtShowcase");

    AuthManager authManager;

    QQmlApplicationEngine qmlEngine;
    qmlEngine.rootContext()->setContextProperty("authManager", &authManager);

    QObject::connect(
        &qmlEngine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    qmlEngine.loadFromModule("loginsystem", "Main");

    return QGuiApplication::exec();
}
