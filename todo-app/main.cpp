#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "todomanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("ToDo App");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("QtShowcase");

    TodoManager todoManager;

    QQmlApplicationEngine qmlEngine;
    qmlEngine.rootContext()->setContextProperty("todoManager", &todoManager);

    QObject::connect(
        &qmlEngine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    qmlEngine.loadFromModule("todoapp", "Main");

    return QGuiApplication::exec();
}
