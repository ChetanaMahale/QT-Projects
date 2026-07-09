cmake_minimum_required(VERSION 3.16)

project(chatapplication VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appchatapplication
    main.cpp
    messagemodel.h
    messagemodel.cpp
    chatmanager.h
    chatmanager.cpp
)

qt_add_qml_module(appchatapplication
    URI chatapplication
    VERSION 1.0
    QML_FILES
        Main.qml
)

set_target_properties(appchatapplication PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appchatapplication
    PRIVATE Qt6::Quick
)

install(TARGETS appchatapplication
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
