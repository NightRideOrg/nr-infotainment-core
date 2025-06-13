#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QMatrix4x4>
#include <QDebug>

#include <QtCore/QUrl>
#include <QtCore/QDebug>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>

#include <QtQml/qqml.h>
#include <QtQml/QQmlEngine>

#include "customextension.h"
#include "languagemanager.h"
#include "volumeprovider.h"
#include "climateprovider.h"
#include "appprovider.h"
#include "applauncher.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts, true);
    qDebug() << "Application starting...";
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("MaizeShark");
    QCoreApplication::setOrganizationDomain("maizeshark.com");
    QCoreApplication::setApplicationName("CarInfotainmentApp");
    qDebug() << "App info set.";

    QQmlApplicationEngine engine;
    qDebug() << "QML Engine created.";

    // QML-Typ für CustomExtension registrieren (MUSS VOR engine.load() erfolgen!)
    qmlRegisterType<CustomExtension>("io.qt.examples.customextension", 1, 0, "CustomExtension");

    AppLauncher launcher;
    engine.rootContext()->setContextProperty("appLauncher", &launcher);

    LanguageManager* languageManager = new LanguageManager(&engine, &app);
    engine.rootContext()->setContextProperty("languageManager", languageManager);

    ClimateProvider* climateProvider = new ClimateProvider(&app);
    engine.rootContext()->setContextProperty("climateProvider", climateProvider);

    VolumeProvider* volumeProvider = new VolumeProvider(&app);
    engine.rootContext()->setContextProperty("volumeProvider", volumeProvider);

    AppProvider* appProvider = new AppProvider(&app);
    engine.rootContext()->setContextProperty("appProvider", appProvider);

    // Update these paths to match the QML module resources
    appProvider->addApp("Map", "qrc:/Car_infotainmentContent/icons/map.png", "red");
    appProvider->addApp("Spotify", "qrc:/Car_infotainmentContent/icons/Spotify.png", "limegreen");

    languageManager->setCurrentLanguage("de");

    // Load the main QML file from the QML module
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
