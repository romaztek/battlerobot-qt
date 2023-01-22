#include "logic.h"

Logic::Logic(QObject *parent) : QObject(parent)
{
    QScreen *screen = qApp->screens().at(0);
    mDensity = screen->devicePixelRatio();

    /*QStringList devices = getBluetoothDevices();
    qDebug().noquote() << devices;*/

#ifdef Q_OS_WINDOWS
    QBluetoothLocalDevice localDevice;
    QString localDeviceName;

    discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);

    connect(discoveryAgent, SIGNAL(deviceDiscovered(QBluetoothDeviceInfo)),
        this, SLOT(deviceDiscovered(QBluetoothDeviceInfo)));

    // Start a discovery
    discoveryAgent->start(QBluetoothDeviceDiscoveryAgent::ClassicMethod);
#endif


}

Logic::~Logic()
{

}

void Logic::deviceDiscovered(const QBluetoothDeviceInfo& device)
{
    devices.append(device.address().toString() + " " + device.name());
    emit deviceFound();
}

void Logic::print(QString text) {
    qDebug().noquote() << text;
}

qreal Logic::getDensity() {
    return mDensity;
}

void Logic::getDeviceList()
{

#ifdef Q_OS_WINDOWS
    if(discoveryAgent != nullptr)
        discoveryAgent->stop();
#endif
    if(socket != nullptr && socket->isOpen()) {
        socket->close();
    }
}

QStringList Logic::getBluetoothDevices()
{
    QStringList result;
    QString fmt("%1 %2");

#ifdef Q_OS_ANDROID
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
        }
    }

#elif defined Q_OS_LINUX
    // Query via the Linux command bt-device.
    QProcess command;
    command.start("bt-device -l");
    command.waitForFinished(3000);
    if (command.error()==QProcess::FailedToStart) {
        qWarning("Cannot execute the command 'bt-device': %s",qPrintable(command.errorString()));
    }
    else {
        // Parse the output, example: HC-06 (20:13:11:15:16:08)
        QByteArray output=command.readAllStandardOutput();
        QRegExp regexp("(.*) \\((.*)\\)");
        foreach(QByteArray line, output.split('\n')) {
            if (regexp.indexIn(line)>=0) {
                result.append(fmt.arg(regexp.cap(2)).arg(regexp.cap(1)));
            }
        }
    }

#elif defined Q_OS_WINDOWS
    result = devices;
    //emit deviceConnected();
#endif

    return result;
}

void Logic::connectToDevice(QString address)
{
#ifdef Q_OS_WINDOWS
    discoveryAgent->stop();
#endif

    qDebug().noquote() << "connecting to:" << address;

    socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol);

    static const QString serviceUuid(QStringLiteral("00001101-0000-1000-8000-00805F9B34FB"));

    socket->connectToService(QBluetoothAddress(address), QBluetoothUuid(serviceUuid), QIODevice::ReadWrite);

    connect(socket, &QBluetoothSocket::connected, this, [=] {
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
        case QBluetoothSocket::RemoteHostClosedError:
            emit deviceError(tr("Remote Host Closed"));
            break;
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
//    qDebug().noquote() << "gamepad name:" << QGamepadManager::instance()->gamepadName(gamepadIDs.at(0));
    return QGamepadManager::instance()->gamepadName(deviceId.toInt());
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
