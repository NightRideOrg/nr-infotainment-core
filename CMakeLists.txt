cmake_minimum_required(VERSION 3.20)

project(Car_Infotainment VERSION 1.0 LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS
    Core Gui Qml Quick Quick3D
    WaylandCompositor LinguistTools Core5Compat
    REQUIRED
)

qt_standard_project_setup()

# Fixes the QTP0004 warning
qt_policy(SET QTP0004 NEW)

# ====================================================================
#  1. ASSETS
# ====================================================================
add_subdirectory(Generated)

# ====================================================================
#  2. EXECUTABLE
# ====================================================================
qt_add_executable(Car_Infotainment_App
    src/main.cpp

    # C++ Logic
    src/applauncher.cpp   src/applauncher.h
    src/appprovider.cpp   src/appprovider.h
    src/climateprovider.cpp src/climateprovider.h
    src/languagemanager.cpp src/languagemanager.h
    src/settingsProvider.cpp src/settingsProvider.h
    src/volumeprovider.cpp src/volumeprovider.h
)

# ====================================================================
#  3. QT 6 QML MODULE
# ====================================================================
qt_add_qml_module(Car_Infotainment_App
    URI "Car_Infotainment"
    VERSION 1.0
    RESOURCE_PREFIX "/"

    # CRITICAL FIX: This prevents CMake from adding "/Car_Infotainment"
    # to your file paths. Now "qrc:/Car_infotainmentContent/Main.qml" will work.
    NO_RESOURCE_TARGET_PATH

    QML_FILES
        Car_infotainmentContent/Main.qml
        Car_infotainmentContent/AppMenuGridView.qml
        Car_infotainmentContent/Climate.qml
        Car_infotainmentContent/Taskbar.qml
        Car_infotainmentContent/Settings.qml

    # Moved conf and qmldir files here to fix CMake Warnings
    RESOURCES
        qtquickcontrols2.conf
        Car_infotainmentContent/qmldir

        Abel/Abel-Regular.ttf
        Images/1239183-3840x2160-desktop-4k-green-forest-background-photo.jpg
        Images/pure-maps2.png
        Images/pure-maps.png
        Car_infotainmentContent/icons/fan.png
        Car_infotainmentContent/icons/volume.png
        Car_infotainmentContent/icons/Spotify.png
        Car_infotainmentContent/icons/map.png
        Car_infotainmentContent/icons/placeholder.png
        Car_infotainmentContent/icons/app-drawer.png
        Car_infotainmentContent/icons/settings.svg
        Car_infotainmentContent/images/urban_street_03_2k.hdr
)

# ====================================================================
#  5. CONFIGURATION
# ====================================================================
target_include_directories(Car_Infotainment_App PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR}
)

target_link_libraries(Car_Infotainment_App PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::Quick3D
    Qt6::Core5Compat Qt6::WaylandCompositor
    Generated_QtQuick3D_Volvi
)

# ====================================================================
#  6. TRANSLATIONS & INSTALL
# ====================================================================
qt_add_translations(Car_Infotainment_App PREFIX "translations" TS_FILES translations/app_de.ts)

set(QML_IMPORT_PATH ${CMAKE_BINARY_DIR}/qml CACHE STRING "" FORCE)

include(GNUInstallDirs)
install(TARGETS Car_Infotainment_App
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
