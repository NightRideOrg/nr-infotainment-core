#include <QDebug>
#include <QGuiApplication>
#include <QIcon>
#include <QMatrix4x4>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtCore/QUrl>
#include <QtGui/QSurfaceFormat>
#include <QtQml/QQmlEngine>
#include <QtQml/qqml.h>
#include <cstdlib>

#include "DatabaseManager.h"
#include "ProgramModel.h"
#include "applauncher.h"
#include "appprovider.h"
#include "climateprovider.h"
#include "internet_radio.h"
#include "languagemanager.h"
#include "sdr/rtlsdr.h"
#include "settingsProvider.h"
#include "vlcplayer.h"
#include "volumeprovider.h"

int main(int argc, char *argv[])
{
    qputenv("QT_XCB_GL_INTEGRATION", "xcb_egl");
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts, true);

    QSurfaceFormat format;
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);
    QSurfaceFormat::setDefaultFormat(format);

    qDebug() << "Application starting...";
    QGuiApplication app(argc, argv);

    app.setApplicationVersion("0.1");
    app.setWindowIcon(QIcon("qrc:/NightRideContent/icons/NightRide.png"));

    qDebug() << app.windowIcon();

    QCoreApplication::setOrganizationName("NightRideOrg");
    QCoreApplication::setOrganizationDomain("night-ride.com");
    QCoreApplication::setApplicationName("NightRideInfotainment");

    qmlRegisterType<VlcPlayer>("NightRide.Multimedia", 1, 0, "VlcPlayer");

    QQmlApplicationEngine engine;

    // --- Instantiate Internet Radio Class ---
    // This will automatically find the fastest server in its constructor
    InternetRadio *internetRadio = new InternetRadio(&app);
    // Expose to QML as "internetRadio"
    engine.rootContext()->setContextProperty("internetRadio", internetRadio);

    DatabaseManager *dbManager = new DatabaseManager(&app);
    dbManager->connect();
    engine.rootContext()->setContextProperty("dbManager", dbManager);

    SettingsProvider *settingsProvider = new SettingsProvider(&app);
    engine.rootContext()->setContextProperty("settingsProvider", settingsProvider);

    AppLauncher *launcher = new AppLauncher(&app);
    engine.rootContext()->setContextProperty("appLauncher", launcher);

    LanguageManager *languageManager = new LanguageManager(&engine, &app);
    engine.rootContext()->setContextProperty("languageManager", languageManager);

    ClimateProvider *climateProvider = new ClimateProvider(&app);
    engine.rootContext()->setContextProperty("climateProvider", climateProvider);

    VolumeProvider *volumeProvider = new VolumeProvider(&app);
    engine.rootContext()->setContextProperty("volumeProvider", volumeProvider);

    AppProvider *appProvider = new AppProvider(&app);
    engine.rootContext()->setContextProperty("appProvider", appProvider);

    RtlSdr *radio = new RtlSdr(&app);
    QObject::connect(radio, &RtlSdr::rdsDataAvailable, dbManager, &DatabaseManager::processRdsJson);
    engine.rootContext()->setContextProperty("sdrRadio", radio);

    appProvider->addApp("Map", "qrc:/NightRideContent/icons/map.png", "red");
    appProvider->addApp("Spotify", "qrc:/NightRideContent/icons/Spotify.svg", "limegreen");
    appProvider->addApp("Settings", "qrc:/NightRideContent/icons/settings.svg", "grey");

    languageManager->setCurrentLanguage("de");

    qmlRegisterType<ProgramModel>("Main", 1, 0, "ProgramModel");

    const QUrl url(QStringLiteral("qrc:/NightRideContent/Main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qDebug() << "Fehler: Keine Root-Objekte in QML geladen!";
        return -1;
    }
    return app.exec();
}
