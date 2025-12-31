cmake_minimum_required(VERSION 3.22)

project(Car_Infotainment VERSION 1.0 LANGUAGES CXX C)

# ====================================================================
#  1. GLOBAL SETTINGS
# ====================================================================
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable CTest integration for the CI
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

find_package(Qt6 6.5 COMPONENTS
    Core Gui Network Qml Quick Quick3D Sql
    WaylandCompositor LinguistTools Core5Compat
    REQUIRED
)

find_package(LibRTLSDR REQUIRED)

qt_standard_project_setup()
qt_policy(SET QTP0004 NEW)

# ====================================================================
#  2. DEPENDENCIES & ASSETS
# ====================================================================
# Assumes this directory exports 'Generated_QtQuick3D_Volvi'
add_subdirectory(Generated)

# ====================================================================
#  3. SOURCE FILES
# ====================================================================
set(PROJECT_SOURCES
    src/main.cpp
    src/applauncher.cpp   src/applauncher.h
    src/appprovider.cpp   src/appprovider.h
    src/climateprovider.cpp src/climateprovider.h
    src/languagemanager.cpp src/languagemanager.h
    src/settingsProvider.cpp src/settingsProvider.h
    src/volumeprovider.cpp src/volumeprovider.h
    src/DatabaseManager.h src/DatabaseManager.cpp
    src/ProgramModel.h src/ProgramModel.cpp
    src/sdr/rtlsdr.h src/sdr/rtlsdr.cpp
)

# ====================================================================
#  4. EXECUTABLE
# ====================================================================
# WIN32: Hides the command prompt on Windows
# MACOSX_BUNDLE: Creates a proper .app bundle on macOS
qt_add_executable(Car_Infotainment_App
    MANUAL_FINALIZATION
    WIN32
    MACOSX_BUNDLE
    ${PROJECT_SOURCES}
)

# ====================================================================
#  5. COMPILER WARNINGS (CI Best Practice)
# ====================================================================
# Ensure code quality by turning on warnings
if(MSVC)
    target_compile_options(Car_Infotainment_App PRIVATE /W4)
else()
    target_compile_options(Car_Infotainment_App PRIVATE -Wall -Wextra -Wpedantic)
endif()

# ====================================================================
#  6. QT 6 QML MODULE
# ====================================================================
qt_add_qml_module(Car_Infotainment_App
    URI "Car_Infotainment"
    VERSION 1.0
    RESOURCE_PREFIX "/"

    # Keeps your path logic flat as requested
    NO_RESOURCE_TARGET_PATH

    QML_FILES
        Car_infotainmentContent/Main.qml
        Car_infotainmentContent/AppMenuGridView.qml
        Car_infotainmentContent/Climate.qml
        Car_infotainmentContent/Taskbar.qml
        Car_infotainmentContent/Settings.qml
        Car_infotainmentContent/Databasetest.qml

    RESOURCES
        qtquickcontrols2.conf
        Car_infotainmentContent/qmldir
        Abel/Abel-Regular.ttf
        # Note: Ideally, avoid spaces in filenames for cross-platform safety
        "Images/1239183-3840x2160-desktop-4k-green-forest-background-photo.jpg"
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
#  7. LINKING & INCLUDE
# ====================================================================
target_include_directories(Car_Infotainment_App PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR}
    ${LIBRTLSDR_INCLUDE_DIRS}
)

target_link_libraries(Car_Infotainment_App PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Network Qt6::Quick Qt6::Quick3D Qt6::Sql
    Qt6::Core5Compat Qt6::WaylandCompositor
    Generated_QtQuick3D_Volvi
)

# ====================================================================
#  8. TRANSLATIONS
# ====================================================================
qt_add_translations(Car_Infotainment_App PREFIX "translations" TS_FILES translations/app_de.ts)

# ====================================================================
#  9. INSTALLATION & DEPLOYMENT (The Magic Part)
# ====================================================================
include(GNUInstallDirs)

# 1. Standard Install
install(TARGETS Car_Infotainment_App
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# 2. Automated Deployment (windeployqt / macdeployqt)
# This generates a script that runs during 'cmake --install'
# It automatically copies required Qt DLLs/Plugins to the build folder
# so the Artifact uploaded by GitHub Actions actually runs!
if(WIN32 OR APPLE)
    qt_generate_deploy_app_script(
        TARGET Car_Infotainment_App
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT ${deploy_script})
endif()

# Finalize the target (required because we used MANUAL_FINALIZATION)
qt_finalize_executable(Car_Infotainment_App)
