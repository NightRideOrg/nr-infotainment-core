cmake_minimum_required(VERSION 3.22)

project(NightRideInfotainment VERSION 0.1 LANGUAGES CXX C)

# ====================================================================
#  1. GLOBAL SETTINGS
# ====================================================================
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable CTest integration for the CI
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

find_package(Qt6 6.5 COMPONENTS
    Core Gui Network Multimedia Qml Quick Quick3D Sql
    WaylandCompositor LinguistTools Core5Compat
    REQUIRED
)

find_package(LibRTLSDR REQUIRED)

# LibVLC
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBVLC REQUIRED libvlc)
include_directories(${CMAKE_SOURCE_DIR}/deps/libvlcpp)

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
    src/internet_radio.h src/internet_radio.cpp
    src/vlcplayer.h src/vlcplayer.cpp
)

# ====================================================================
#  4. EXECUTABLE
# ====================================================================
# WIN32: Hides the command prompt on Windows
# MACOSX_BUNDLE: Creates a proper .app bundle on macOS
qt_add_executable(nightride-infotainment
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
    target_compile_options(nightride-infotainment PRIVATE /W4)
else()
    target_compile_options(nightride-infotainment PRIVATE -Wall -Wextra -Wpedantic)
endif()

# ====================================================================
#  6. QT 6 QML MODULE
# ====================================================================
qt_add_qml_module(nightride-infotainment
    URI "NightRide.Infotainment"
    VERSION 1.0
    RESOURCE_PREFIX "/"

    # Keeps your path logic flat as requested
    NO_RESOURCE_TARGET_PATH

    QML_FILES
        NightRideContent/Main.qml
        NightRideContent/AppMenuGridView.qml
        NightRideContent/Climate.qml
        NightRideContent/Taskbar.qml
        NightRideContent/Settings.qml
        NightRideContent/Databasetest.qml
        NightRideContent/InternetRadio.qml

    RESOURCES
        qtquickcontrols2.conf
        NightRideContent/qmldir
        Abel/Abel-Regular.ttf
        # Note: Ideally, avoid spaces in filenames for cross-platform safety
        "Images/1239183-3840x2160-desktop-4k-green-forest-background-photo.jpg"
        Images/pure-maps2.png
        Images/pure-maps.png
        NightRideContent/icons/fan.png
        NightRideContent/icons/volume.png
        NightRideContent/icons/Spotify.svg
        NightRideContent/icons/map.png
        NightRideContent/icons/placeholder.png
        NightRideContent/icons/app-drawer.png
        NightRideContent/icons/settings.svg
        NightRideContent/icons/folder.png
        NightRideContent/icons/radio.png
        NightRideContent/icons/NightRide.png
        NightRideContent/images/urban_street_03_2k.hdr
)
# ====================================================================
#  7. LINKING & INCLUDE
# ====================================================================
target_include_directories(nightride-infotainment PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR}
    ${LIBRTLSDR_INCLUDE_DIRS}
)

target_link_libraries(nightride-infotainment PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Network Qt6::Multimedia Qt6::Quick Qt6::Quick3D Qt6::Sql
    Qt6::Core5Compat Qt6::WaylandCompositor
    Generated_QtQuick3D_Volvi
    ${LIBVLC_LIBRARIES}
)

# ====================================================================
#  8. TRANSLATIONS
# ====================================================================
qt_add_translations(nightride-infotainment PREFIX "translations" TS_FILES translations/app_de.ts)

# ====================================================================
#  9. INSTALLATION & DEPLOYMENT (The Magic Part)
# ====================================================================
include(GNUInstallDirs)

# 1. Standard Install
install(TARGETS nightride-infotainment
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
        TARGET nightride-infotainment
        OUTPUT_SCRIPT deploy_script
        NO_UNSUPPORTED_PLATFORM_ERROR
    )
    install(SCRIPT ${deploy_script})
endif()

# Finalize the target (required because we used MANUAL_FINALIZATION)
qt_finalize_executable(nightride-infotainment)
