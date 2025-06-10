cmake_minimum_required(VERSION 3.16)

project(Car_Infotainment VERSION 1.0 LANGUAGES CXX C)

# ---- Find Qt packages FIRST to make Qt's CMake functions available ----
find_package(Qt6 COMPONENTS Core Gui Qml Quick Quick3D WaylandCompositor LinguistTools Core5Compat REQUIRED)

# ---- Use modern Qt6 setup for robust dependency and plugin path handling ----
# This command must come AFTER find_package(Qt6...) and correctly sets up runtime paths.
qt_standard_project_setup()

# Set Qt policies to avoid warnings
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

# ====================================================================
#  HAUPTPROGRAMM: Car_Infotainment
# ====================================================================

# 1. Definiere den Pfad zur Protokolldatei
set(PROTOCOL_FILES ${CMAKE_CURRENT_SOURCE_DIR}/protocol/custom.xml)

# 2. Definiere die erwarteten Pfade der generierten Dateien.
#    Die qt_generate_... Funktion legt sie im CMAKE_CURRENT_BINARY_DIR ab.
set(GEN_WAYLAND_PROTOCOL_C_FILE ${CMAKE_CURRENT_BINARY_DIR}/wayland-custom-protocol.c)
set(GEN_WAYLAND_SERVER_CPP_FILE ${CMAKE_CURRENT_BINARY_DIR}/qwayland-server-custom.cpp)

# Füge dies VOR qt_add_executable hinzu:
qt_add_resources(QRC_SRCS resources.qrc)

add_subdirectory(Generated)

# 3. ERSTELLE DAS ZIEL (Executable) mit ALLEN Quellen
qt_add_executable(Car_Infotainment
        src/main.cpp

        # Eigene Anwendungslogik
        src/languagemanager.cpp
        src/languagemanager.h
        src/climateprovider.cpp
        src/climateprovider.h
        src/volumeprovider.cpp
        src/volumeprovider.h
        src/appprovider.cpp
        src/appprovider.h

        # Compositor-Teil
        compositor/customextension.cpp
        compositor/customextension.h

        # Füge die generierten Dateien hier explizit hinzu
        ${GEN_WAYLAND_PROTOCOL_C_FILE}
        ${GEN_WAYLAND_SERVER_CPP_FILE}
        ${QRC_SRCS} # <--- QRC-Dateien hier einfügen!
)
# 4. Erzeuge eine Regel, die die generierten Dateien als Abhängigkeit für das Ziel setzt
#    Dies stellt sicher, dass sie generiert werden, BEVOR das Ziel versucht, sie zu kompilieren.
qt6_generate_wayland_protocol_server_sources(Car_Infotainment
        FILES ${PROTOCOL_FILES}
)

# 5. KONFIGURIERE DEN REST FÜR DAS ZIEL
# Include-Verzeichnisse für den Compiler setzen
target_include_directories(Car_Infotainment PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/compositor
        ${CMAKE_CURRENT_BINARY_DIR} # Wichtig für alle generierten Header
)

# Qt-Bibliotheken verlinken
target_link_libraries(Car_Infotainment PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::Quick3D
        Qt6::Core5Compat
        Qt6::WaylandCompositor
)

# Internationalisierung (i18n)
set(TS_FILES
        translations/app_de.ts
)
qt_add_translations(Car_Infotainment
        PREFIX "translations"
        TS_FILES ${TS_FILES}
)

set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml)
set(QML_IMPORT_PATH ${QT_QML_OUTPUT_DIRECTORY}
    CACHE STRING "Import paths for Qt Creator's code model"
    FORCE
)

include(GNUInstallDirs)
install(TARGETS Car_Infotainment
  BUNDLE DESTINATION .
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)