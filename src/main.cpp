#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QMatrix4x4>
#include <QDebug>
#include <QtCore/QUrl>
#include <QtQml/qqml.h>
#include <QtQml/QQmlEngine>
#include <QtGui/QSurfaceFormat>

// #include "customextension.h"
#include "languagemanager.h"
#include "volumeprovider.h"
#include "climateprovider.h"
#include "appprovider.h"
#include "applauncher.h"
#include "settingsProvider.h"
#include "DatabaseManager.h"
#include "ProgramModel.h"
#include "sdr/rtlsdr.h"

int main(int argc, char *argv[])
{
    qputenv("QT_XCB_GL_INTEGRATION", "xcb_egl");
    // Enable context sharing (Required for QtQuick3D + Wayland)
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts, true);

    QSurfaceFormat format;
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);
    QSurfaceFormat::setDefaultFormat(format);

    qDebug() << "Application starting...";
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("MaizeShark");
    QCoreApplication::setOrganizationDomain("maizeshark.com");
    QCoreApplication::setApplicationName("CarInfotainmentApp");
    qDebug() << "App info set.";

    QQmlApplicationEngine engine;
    qDebug() << "QML Engine created.";

    DatabaseManager* dbManager = new DatabaseManager(&app);
    dbManager->connect();
    engine.rootContext()->setContextProperty("dbManager", dbManager);

    SettingsProvider* settingsProvider = new SettingsProvider(&app);
    engine.rootContext()->setContextProperty("settingsProvider", settingsProvider);

    AppLauncher* launcher = new AppLauncher(&app);
    engine.rootContext()->setContextProperty("appLauncher", launcher);

    LanguageManager* languageManager = new LanguageManager(&engine, &app);
    engine.rootContext()->setContextProperty("languageManager", languageManager);

    ClimateProvider* climateProvider = new ClimateProvider(&app);
    engine.rootContext()->setContextProperty("climateProvider", climateProvider);

    VolumeProvider* volumeProvider = new VolumeProvider(&app);
    engine.rootContext()->setContextProperty("volumeProvider", volumeProvider);

    AppProvider* appProvider = new AppProvider(&app);
    engine.rootContext()->setContextProperty("appProvider", appProvider);

    RtlSdr *radio = new RtlSdr(&app);

    QObject::connect(radio, &RtlSdr::rdsDataAvailable,
                     dbManager, &DatabaseManager::processRdsJson);

    radio->startRadio(105.9);

    appProvider->addApp("Map", "qrc:/Car_infotainmentContent/icons/map.png", "red");
    appProvider->addApp("Spotify", "qrc:/Car_infotainmentContent/icons/Spotify.png", "limegreen");
    appProvider->addApp("Settings", "qrc:/Car_infotainmentContent/icons/settings.svg", "grey");

    languageManager->setCurrentLanguage("de");

    qmlRegisterType<ProgramModel>("Main", 1, 0, "ProgramModel");

    const QUrl url(QStringLiteral("qrc:/Car_infotainmentContent/Main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qDebug() << "Fehler: Keine Root-Objekte in QML geladen!";
        return -1;
    }
    return app.exec();
}
