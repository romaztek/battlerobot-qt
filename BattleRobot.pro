QT += quick bluetooth gamepad

CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000

TEMPLATE = app
TARGET = BattleRobot

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

HEADERS += \
	logic.h

SOURCES += \
        logic.cpp \
        main.cpp

RESOURCES += qml.qrc

TRANSLATIONS += \
    BattleRobot_ru_RU.ts

lupdate_only{
SOURCES = main.qml \
	ControlWindow.qml \
	ConnectWindow.qml \
	Line.qml \
	LoadingCircleIndicator.qml \
	MoveButton.qml \
	MyIconButton.qml \
	MyIconLabel.qml \
	MyIconRadioButtonLabel.qml
}

CONFIG(debug, debug|release) {
    CONFIG += qml_debug
    message("Debug")
}
CONFIG(release, debug|release) {
    CONFIG -= qml_debug
    message("Release")
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

android {
    QT += androidextras
}

win32:RC_ICONS += app_icon.ico

win32:VERSION = 0.0.4

DISTFILES += \
	android/AndroidManifest.xml \
	android/build.gradle \
	android/gradle/wrapper/gradle-wrapper.jar \
	android/gradle/wrapper/gradle-wrapper.properties \
	android/gradlew \
	android/gradlew.bat \
	android/res/mipmap-anydpi-v26/ic_launcher.xml \
	android/res/mipmap-hdpi/ic_launcher.png \
	android/res/mipmap-hdpi/ic_launcher_adaptive_back.png \
	android/res/mipmap-hdpi/ic_launcher_adaptive_fore.png \
	android/res/mipmap-mdpi/ic_launcher.png \
	android/res/mipmap-mdpi/ic_launcher_adaptive_back.png \
	android/res/mipmap-mdpi/ic_launcher_adaptive_fore.png \
	android/res/mipmap-xhdpi/ic_launcher.png \
	android/res/mipmap-xhdpi/ic_launcher_adaptive_back.png \
	android/res/mipmap-xhdpi/ic_launcher_adaptive_fore.png \
	android/res/mipmap-xxhdpi/ic_launcher.png \
	android/res/mipmap-xxhdpi/ic_launcher_adaptive_back.png \
	android/res/mipmap-xxhdpi/ic_launcher_adaptive_fore.png \
	android/res/mipmap-xxxhdpi/ic_launcher.png \
	android/res/mipmap-xxxhdpi/ic_launcher_adaptive_back.png \
	android/res/mipmap-xxxhdpi/ic_launcher_adaptive_fore.png \
	android/res/values/libs.xml \
	android/res/values/themes.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android