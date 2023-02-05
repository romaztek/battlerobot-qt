#include "logic.h"

Logic::Logic(QObject *parent) : QObject(parent)
{
    QScreen *screen = qApp->screens().at(0);
    mDensity = screen->devicePixelRatio();

#if defined  Q_OS_WINDOWS || (defined Q_OS_LINUX && !defined Q_OS_ANDROID)
    discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);

    connect(discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)),
            this, SLOT(deviceDiscovered(QBluetoothDeviceInfo)));
    discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::ClassicMethod);
#elif defined Q_OS_IOS
//    discoveryAgent = new QBluetoothDeviceDiscoveryAgent (this);
//    discoveryAgent->setLowEnergyDiscoveryTimeout(5000);
//    connect(discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)),
//            this, SLOT(deviceDiscovered(QBluetoothDeviceInfo)));
//    discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
#endif

}

Logic::~Logic()
{

}

void Logic::deviceDiscovered(const QBluetoothDeviceInfo& device)
{
#if defined  Q_OS_WINDOWS || (defined Q_OS_LINUX && !defined Q_OS_ANDROID)
    addresses.append(device.address().toString());
    devices.append(device.address().toString() + " " + device.name());
    emit deviceFound();
#elif defined Q_OS_IOS
//    if (device.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration) {
//        addresses.append(device.address().toString());
//        devices.append(device.address().toString() + " " + device.name());
//        emit deviceFound();
//    }
#endif
}

QString Logic::getLastConnectedBtDevice()
{
    const QString AppDataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
#ifdef Q_OS_WINDOWS
    QSettings settings(AppDataLocation + "\\settings.ini", QSettings::IniFormat);
#elif defined Q_OS_ANDROID || defined Q_OS_IOS
    QString path = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    QSettings settings(path + "/settings", QSettings::NativeFormat);
#elif defined Q_OS_LINUX
    QSettings settings(AppDataLocation + "/settings");
#endif

    return settings.value("lastBtDevice", "").toString();
}

void Logic::setLastConnectedBtDevice(const QString &value)
{
    const QString AppDataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
#ifdef Q_OS_WINDOWS
    QSettings settings(AppDataLocation + "\\settings.ini", QSettings::IniFormat);
#elif defined Q_OS_ANDROID || defined Q_OS_IOS
    QString path = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    QSettings settings(path + "/settings", QSettings::NativeFormat);
#elif defined Q_OS_LINUX
    QSettings settings(AppDataLocation + "/settings");
#endif

    settings.setValue("lastBtDevice", value);
    settings.sync();
}

void Logic::print(QString text) {
    qDebug().noquote() << text;
}

qreal Logic::getDensity() {
    return mDensity;
}

void Logic::getDeviceList()
{
#if defined  Q_OS_WINDOWS || (defined Q_OS_LINUX && !defined Q_OS_ANDROID)
    if(discoveryAgent != nullptr)
        discoveryAgent->stop();
#endif
    if(socket != nullptr && socket->isOpen()) {
        socket->close();
    }
}

QStringList Logic::getBluetoothDevices()
{
    QStringList addresses;
    QStringList result;

#ifdef Q_OS_ANDROID
    QString fmt("%1 %2");
    // Query via Android Java API.
    QAndroidJniObject adapter=QAndroidJniObject::callStaticObjectMethod("android/bluetooth/BluetoothAdapter","getDefaultAdapter","()Landroid/bluetooth/BluetoothAdapter;"); // returns a BluetoothAdapter
    if (checkException("BluetoothAdapter.getDefaultAdapter()",&adapter)) {
        return result;
    }
    QAndroidJniObject pairedDevicesSet=adapter.callObjectMethod("getBondedDevices","()Ljava/util/Set;"); // returns a Set<BluetoothDevice>
    if (checkException("BluetoothAdapter.getBondedDevices()",&pairedDevicesSet)) {
        return result;
    }
    jint size=pairedDevicesSet.callMethod<jint>("size");
    //checkException("Set<BluetoothDevice>.size()", size);
    if (size>0) {
        QAndroidJniObject iterator=pairedDevicesSet.callObjectMethod("iterator","()Ljava/util/Iterator;"); // returns an Iterator<BluetoothDevice>
        if (checkException("Set<BluetoothDevice>.iterator()",&iterator)) {
            return result;
        }
        for (int i=0; i<size; i++) {
            QAndroidJniObject dev=iterator.callObjectMethod("next","()Ljava/lang/Object;"); // returns a BluetoothDevice
            if (checkException("Iterator<BluetoothDevice>.next()",&dev)) {
                continue;
            }
            QString address=dev.callObjectMethod("getAddress","()Ljava/lang/String;").toString(); // returns a String
            QString name=dev.callObjectMethod("getName","()Ljava/lang/String;").toString(); // returns a String
            result.append(fmt.arg(address).arg(name));
            addresses.append(address);
        }
    }
#endif

#if defined  Q_OS_WINDOWS || (defined Q_OS_LINUX && !defined Q_OS_ANDROID) || defined Q_OS_IOS
    addresses = this->addresses;
    result = devices;
    //emit deviceConnected();
#endif


    QString lastAddress = getLastConnectedBtDevice();
    int index = -1;

    if(lastAddress.length() != 0) {
        for(const QString &res: qAsConst(addresses)) {
            if(QString::compare(res, lastAddress) == 0) {
                qDebug().noquote() << "LATEST" << res;
                index = addresses.indexOf(res);
                break;
            }
        }
    }

    if(index != -1) {
        QString lastDevice = result.at(index);
        result.removeAt(index);
        result.insert(0, lastDevice);
    }

    return result;
}

void Logic::connectToDevice(QString address)
{
#if defined  Q_OS_WINDOWS || (defined Q_OS_LINUX && !defined Q_OS_ANDROID) || defined Q_OS_IOS
    discoveryAgent->stop();
#endif

    qDebug().noquote() << "connecting to:" << address;

    socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol);

    static const QString serviceUuid(QStringLiteral("00001101-0000-1000-8000-00805F9B34FB"));

    socket->connectToService(QBluetoothAddress(address), QBluetoothUuid(serviceUuid), QIODevice::ReadWrite);

    connect(socket, &QBluetoothSocket::connected, this, [=] {
        setLastConnectedBtDevice(address);
        emit deviceConnected();

        socket->write("@");
    });

    connect(socket, &QBluetoothSocket::disconnected, this, &Logic::deviceDisconnected);

    connect(socket, QOverload<QBluetoothSocket::SocketError>::of(&QBluetoothSocket::error),
            [=](QBluetoothSocket::SocketError error){
        switch (error) {
        case QBluetoothSocket::UnknownSocketError:
            emit deviceError(tr("Unknown Error"));
            break;
        case QBluetoothSocket::HostNotFoundError:
            emit deviceError(tr("Host Not Found"));
            break;
        case QBluetoothSocket::ServiceNotFoundError:
            emit deviceError(tr("Service Not Found"));
            break;
        case QBluetoothSocket::NetworkError:
            emit deviceError(tr("Network Error"));
            break;
        case QBluetoothSocket::UnsupportedProtocolError:
            emit deviceError(tr("Unsupported Protocol"));
            break;
        case QBluetoothSocket::OperationError:
            emit deviceError(tr("Operation Error"));
            break;
//        case QBluetoothSocket::RemoteHostClosedError:
//            emit deviceError(tr("Remote Host Closed"));
//            break;
        case QBluetoothSocket::NoSocketError:
            emit deviceError(tr("No Socket Error"));
            break;
        }
    });

    connect(socket, &QBluetoothSocket::readyRead, this, [=] {
        qDebug().noquote() << "I got:" << QString(socket->readAll());
    });
}

void Logic::send(QString text)
{
    if(socket != nullptr)
        socket->write(text.toStdString().c_str());
}

QString Logic::getGamepadName(QVariant deviceId)
{
    //    QList<int> gamepadIDs = QGamepadManager::instance()->connectedGamepads();
    //    qDebug().noquote() << "gamepad ID:" << gamepadIDs.at(0);

#if QT_VERSION >= QT_VERSION_CHECK(5, 11, 0)
    qDebug().noquote() << "gamepad name:" << QGamepadManager::instance()->gamepadName(deviceId.toInt());
    return QGamepadManager::instance()->gamepadName(deviceId.toInt());
#else
    return QString("");
#endif
}

bool Logic::hasTouchScreen()
{
    QList<const QTouchDevice*> devices = QTouchDevice::devices();

    if(devices.count() == 0)
        return false;
    else {
        for(auto device: devices) {
            if(device->maximumTouchPoints() < 2) {
                return false;
            }
        }
    }

    return true;
}

#ifdef Q_OS_ANDROID
bool Logic::checkException(const char* method, const QAndroidJniObject* obj) {
    static QAndroidJniEnvironment env;
    bool result=false;
    if (env->ExceptionCheck()) {
        qCritical("Exception in %s",method);
        env->ExceptionDescribe();
        env->ExceptionClear();
        result=true;
    }
    if (!(obj==NULL || obj->isValid())) {
        qCritical("Invalid object returned by %s",method);
        result=true;
    }
    return result;
}
#endif
