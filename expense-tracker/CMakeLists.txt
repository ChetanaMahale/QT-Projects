cmake_minimum_required(VERSION 3.16)

project(expensetracker VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Sql Charts)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appexpensetracker
    main.cpp
    expensemanager.h
    expensemanager.cpp
)

qt_add_qml_module(appexpensetracker
    URI expensetracker
    VERSION 1.0
    QML_FILES
        Main.qml
        components/AddExpenseDialog.qml
        components/ExpenseCard.qml
        components/StatCard.qml
        components/CategoryBadge.qml
        components/DonutChart.qml
)

set_target_properties(appexpensetracker PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appexpensetracker
    PRIVATE
        Qt6::Quick
        Qt6::Sql
        Qt6::Charts
)

install(TARGETS appexpensetracker
    BUNDLE  DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
