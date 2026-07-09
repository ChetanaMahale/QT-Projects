#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "calculatorengine.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Calculator");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("QtShowcase");

    QQmlApplicationEngine qmlEngine;

    // Register CalculatorEngine accessible in QML as "calc"
    CalculatorEngine calcEngine;
    qmlEngine.rootContext()->setContextProperty("calc", &calcEngine);

    QObject::connect(
        &qmlEngine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    qmlEngine.loadFromModule("calculator", "Main");

    return QGuiApplication::exec();
}
