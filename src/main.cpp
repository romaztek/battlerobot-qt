#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QLoggingCategory>
#include <QtDebug>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>

#include <iostream>

#ifdef Q_OS_ANDROID
#include <QtAndroidExtras>
#endif

#include "logic.h"
#include "enums.h"


#ifdef Q_OS_WINRT
void myMessageHandler(QtMsgType type, const QMessageLogContext&, const QString& msg)
{
    QString txt;
    switch (type) {
    case QtInfoMsg:
        txt = QString("Info: %1").arg(msg);
        break;
    case QtDebugMsg:
        txt = QString("Debug: %1").arg(msg);
        break;
    case QtWarningMsg:
        txt = QString("Warning: %1").arg(msg);
        break;
    case QtCriticalMsg:
        txt = QString("Critical: %1").arg(msg);
        break;
    case QtFatalMsg:
        txt = QString("Fatal: %1").arg(msg);
        abort();
    }

    const QString AppDataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    QFile outFile(AppDataLocation + "/log.txt");
    outFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream ts(&outFile);
    ts << txt << std::endl;
}
#endif

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

#if defined Q_OS_MACOS && !defined Q_OS_IOS
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
#endif

    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("romankartashev");
    QCoreApplication::setOrganizationDomain("romankartashev.ru");
    QCoreApplication::setApplicationName("BattleRobot");

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "BattleRobot_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    //    QLoggingCategory::setFilterRules(QStringLiteral("qt.bluetooth* = true"));

#ifdef Q_OS_WINRT
    qInstallMessageHandler(myMessageHandler);
#endif

#ifdef Q_OS_ANDROID
    if(QtAndroid::androidSdkVersion() >= 31) {
        auto result = QtAndroid::checkPermission(QString("android.permission.BLUETOOTH_CONNECT"));
        if(result == QtAndroid::PermissionResult::Denied){
            QtAndroid::PermissionResultMap resultHash = QtAndroid::requestPermissionsSync(QStringList({"android.permission.BLUETOOTH_CONNECT"}));
            if(resultHash["android.permission.BLUETOOTH_CONNECT"] == QtAndroid::PermissionResult::Denied)
                return 0;
        }
    }

    QAndroidJniObject::callStaticMethod<void>("ru/romankartashev/battlerobot/MyActivity", "enableBluetooth");
#endif

    Logic::init();
    Enums::init();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    const QString AppDataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    qDebug().noquote() << "App Data Location: " << AppDataLocation;

    return app.exec();
}
