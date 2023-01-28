#ifndef LOGIC_H
#define LOGIC_H

#include <QObject>
#include <QDebug>
#include <QList>
#include <QScreen>
#include <QSettings>
#include <QStandardPaths>
#include <QGuiApplication>
#include <QTouchDevice>

#include <QBluetoothAddress>
#include <QBluetoothSocket>
#include <QBluetoothLocalDevice>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothUuid>

#include <QGamepad>
#include <QGamepadManager>

#include <QStringList>

#ifdef Q_OS_ANDROID
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#endif

#ifdef Q_OS_LINUX
#include <QProcess>
#endif

class Logic : public QObject
{
    Q_OBJECT
public:
    explicit Logic(QObject *parent = nullptr);
    ~Logic();

    qreal mDensity = 0;

    void getDeviceList();

    Q_INVOKABLE void print(QString text);
    Q_INVOKABLE qreal getDensity();
    Q_INVOKABLE QStringList getBluetoothDevices();
    Q_INVOKABLE void connectToDevice(QString address);
    Q_INVOKABLE void send(QString text);

    Q_INVOKABLE QString getGamepadName(QVariant deviceId);
    Q_INVOKABLE bool hasTouchScreen();

#ifdef Q_OS_ANDROID
    bool checkException(const char* method, const QAndroidJniObject* obj);
#endif
 
public slots:
    void deviceDiscovered(const QBluetoothDeviceInfo& device);

private:
    QStringList addresses;
    QStringList devices;

    QBluetoothDeviceDiscoveryAgent* discoveryAgent = nullptr;
    QBluetoothSocket *socket = nullptr;

    QString getLastConnectedBtDevice();
    void setLastConnectedBtDevice(const QString &value);

signals:
    void deviceConnected();
    void deviceDisconnected();
    void deviceError(QString err);
    void deviceFound();

signals:


};

#endif // LOGIC_H
