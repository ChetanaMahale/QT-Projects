cmake_minimum_required(VERSION 3.16)

project(weatherapp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Network)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appweatherapp
    main.cpp
    weathermanager.h
    weathermanager.cpp
)

qt_add_qml_module(appweatherapp
    URI weatherapp
    VERSION 1.0
    QML_FILES
        Main.qml
)

set_target_properties(appweatherapp PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appweatherapp
    PRIVATE
        Qt6::Quick
        Qt6::Network
)

install(TARGETS appweatherapp
    BUNDLE  DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
