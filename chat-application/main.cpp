#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "chatmanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Chat Application");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("QtShowcase");

    ChatManager chatManager;

    QQmlApplicationEngine qmlEngine;
    qmlEngine.rootContext()->setContextProperty("chatManager", &chatManager);

    QObject::connect(
        &qmlEngine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    qmlEngine.loadFromModule("chatapplication", "Main");

    return QGuiApplication::exec();
}
