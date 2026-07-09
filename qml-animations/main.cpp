#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "animationcontroller.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("QML Animations");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("QtShowcase");

    AnimationController animController;

    QQmlApplicationEngine qmlEngine;
    qmlEngine.rootContext()->setContextProperty("animController", &animController);

    QObject::connect(
        &qmlEngine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    qmlEngine.loadFromModule("qmlanimations", "Main");

    return QGuiApplication::exec();
}
