#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "filehandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Text Editor");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("QtShowcase");

    FileHandler fileHandler;

    QQmlApplicationEngine qmlEngine;
    qmlEngine.rootContext()->setContextProperty("fileHandler", &fileHandler);

    QObject::connect(
        &qmlEngine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    qmlEngine.loadFromModule("texteditor", "Main");

    return QGuiApplication::exec();
}
