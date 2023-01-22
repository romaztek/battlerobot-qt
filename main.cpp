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
    ts << txt << endl;
}


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QLoggingCategory::setFilterRules(QStringLiteral("qt.bluetooth* = true"));

    QGuiApplication app(argc, argv);
    /*
#ifdef Q_OS_WINDOWS
    qInstallMessageHandler(myMessageHandler);
#endif
*/

    QTranslator translator;
#ifdef Q_OS_WINDOWS
    if (translator.load(QLocale(), QLatin1String("TestBt"), QLatin1String("_"), QLatin1String(":/i18n")))
        QCoreApplication::installTranslator(&translator);
#elif defined Q_OS_ANDROID
    if(QLocale::system().name() == "ru_RU") {
        qDebug().noquote() << "Locale:" << QLocale::system().name();
        if(translator.load(QString("TestBt_ru_RU"), QString(":/i18n"))) {
            QCoreApplication::installTranslator(&translator);
        }
        else
            qDebug().noquote() << "Cannot load translation for:" << "ru_RU";
    }
//    if (translator.load(QLocale::system().name(), QLatin1String("TestBt"), QLatin1String("_"), QLatin1String("qrc:/i18n/")))
//        QCoreApplication::installTranslator(&translator);
//    else
//        qDebug().noquote() << "Cannot load translation for:" << QLocale::system().name();
#endif
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

    qDebug().noquote() << "App Data Path: " << AppDataLocation;


    return app.exec();
}
