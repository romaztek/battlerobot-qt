#pragma once

#include <QObject>
#include <QQmlEngine>

class Enums : public QObject
{
    Q_GADGET
public:
    enum class SteeringIntensity {
        NONE,
        LOW,
        NORMAL,
        HIGH,
        TURN
    };
    Q_ENUM(SteeringIntensity)

    enum class ControlType {
        NONE,
        TOUCH,
        GAMEPAD
    };
    Q_ENUM(ControlType)

    static void init();
};
