#include <QApplication>
#include <QCoreApplication>
#include <QObject>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QStringList>
#include <QStringLiteral>
#include <QUrl>

#include "ApplicationInfo.h"
#include "SettingsManager.h"

#define MODULE_URI "BleHelper"
#define MODULE_VERSION_MAJOR 1
#define MODULE_VERSION_MINOR 0

#ifdef WIN32
#  include <windows.h>
// 程序崩溃回调函数
LONG WINAPI ExceptionHandler(EXCEPTION_POINTERS *ExceptionInfo)
{
    QStringList arguments;
    arguments << "-crashed=";
    QProcess::startDetached(QGuiApplication::applicationFilePath(), arguments);
    return EXCEPTION_EXECUTE_HANDLER;
}
#endif // WIN32

int main(int argc, char *argv[])
{
#ifdef WIN32
    SetUnhandledExceptionFilter(ExceptionHandler);
    qputenv("QT_QPA_PLATFORM", "windows:darkmode=2");
#endif // WIN32

    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    SettingsManager::getInstance()->initTranslator(&engine);

    qmlRegisterSingletonType<ApplicationInfo>(
            MODULE_URI, MODULE_VERSION_MAJOR, MODULE_VERSION_MINOR, "ApplicationInfo",
            [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                Q_UNUSED(engine)
                Q_UNUSED(scriptEngine)
                return ApplicationInfo::getInstance();
            });

    qmlRegisterSingletonType<SettingsManager>(
            MODULE_URI, MODULE_VERSION_MAJOR, MODULE_VERSION_MINOR, "SettingsManager",
            [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                Q_UNUSED(engine)
                Q_UNUSED(scriptEngine)
                return SettingsManager::getInstance();
            });

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(
            &engine, &QQmlApplicationEngine::objectCreated, &app,
            [url](QObject *obj, const QUrl &objUrl) {
                if (!obj && url == objUrl)
                    QCoreApplication::exit(-1);
            },
            Qt::QueuedConnection);
    engine.load(url);
    const int exec = QApplication::exec();
    if (exec == 931) {
        QProcess::startDetached(qApp->applicationFilePath(), qApp->arguments());
    }
    return exec;
}
