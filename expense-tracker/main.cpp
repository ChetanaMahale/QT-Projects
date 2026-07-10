#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "expensemanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Expense Tracker");
    app.setApplicationVersion("1.0");
    app.setOrganizationName("QtShowcase");

    ExpenseManager expenseManager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("expense", &expenseManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("expensetracker", "Main");

    return QGuiApplication::exec();
}
