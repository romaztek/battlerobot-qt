#include "enums.h"

void Enums::init()
{
    //qmlRegisterUncreatableType<Enums>("ru.romankartashev.enums", 1, 0, "SteeringIntensity", "Enum");
    qRegisterMetaType<Enums::SteeringIntensity>("Enums::SteeringIntensity");
    qmlRegisterType<Enums>("ru.romankartashev.enums", 1, 0, "SteeringIntensity");
    qRegisterMetaType<Enums::ControlType>("Enums::ControlType");
    qmlRegisterType<Enums>("ru.romankartashev.enums", 1, 0, "ControlType");
}
