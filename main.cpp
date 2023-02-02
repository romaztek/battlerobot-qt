#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QLoggingCategory>
#include <QtDebug>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>

#include "logic.h"

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
    ts << txt << Qt::endl;
}

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("romankartashev");
    QCoreApplication::setOrganizationDomain("romankartashev.ru");
    QCoreApplication::setApplicationName("battlerobot");

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

//    QTranslator translator;
//#ifdef Q_OS_WINDOWS
//    if (translator.load(QLocale(), QLatin1String("BattleRobot"), QLatin1String("_"), QLatin1String(":/i18n")))
//        QCoreApplication::installTranslator(&translator);
//#elif defined Q_OS_ANDROID || defined Q_OS_LINUX
//    if(QLocale::system().name() == "ru_RU") {
//        qDebug().noquote() << "Locale:" << QLocale::system().name();
//        if(translator.load(QString("BattleRobot_ru_RU"), QString(":/i18n"))) {
//            QCoreApplication::installTranslator(&translator);
//        }
//        else
//            qDebug().noquote() << "Cannot load translation for:" << "ru_RU";
//    }
//#endif
    qmlRegisterType<Logic>("ru.romanlenz.logic", 1, 0, "Logic");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
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
