cmake_minimum_required(VERSION 3.16)

project(BattleRobot VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(ANDROID_BUILD_ABI_arm64-v8a ON)
set(ANDROID_BUILD_ABI_armeabi-v7a ON)
set(ANDROID_BUILD_ABI_x86 ON)

set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android CACHE INTERNAL "" )

# See https://bugreports.qt.io/browse/QTBUG-84302
# Change to your installed SDK Build-tools Version
set(ANDROID_SDK_BUILD_TOOLS_REVISION "28.0.3")

if(ANDROID)
    find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick LinguistTools Bluetooth Gamepad Concurrent AndroidExtras)
    find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick LinguistTools Bluetooth Gamepad Concurrent AndroidExtras)
else()
    find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick LinguistTools Bluetooth Gamepad Concurrent)
    find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick LinguistTools Bluetooth Gamepad Concurrent)
endif()

set(TS_FILES BattleRobot_ru_RU.ts)

set(PROJECT_SOURCES
    main.cpp
    logic.cpp
    qml.qrc
    ${TS_FILES}
    )

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(BattleRobot
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
        )
    qt_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
else()
    if(ANDROID)
        add_library(BattleRobot SHARED
            ${PROJECT_SOURCES}
            )
    else()
        add_executable(BattleRobot
            ${PROJECT_SOURCES}
            )
    endif()

    qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
endif()

if(ANDROID)
    target_link_libraries(BattleRobot
        PRIVATE
        Qt${QT_VERSION_MAJOR}::Core
        Qt${QT_VERSION_MAJOR}::Quick
        Qt${QT_VERSION_MAJOR}::Bluetooth
        Qt${QT_VERSION_MAJOR}::Gamepad
        Qt${QT_VERSION_MAJOR}::Concurrent
        Qt${QT_VERSION_MAJOR}::AndroidExtras)
else()
target_link_libraries(BattleRobot
    PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Bluetooth
    Qt${QT_VERSION_MAJOR}::Gamepad
    Qt${QT_VERSION_MAJOR}::Concurrent)
endif()

set_target_properties(BattleRobot PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    )

install(TARGETS BattleRobot
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(BattleRobot)
    qt_finalize_executable(BattleRobot)
endif()
