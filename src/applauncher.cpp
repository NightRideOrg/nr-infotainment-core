#include "applauncher.h"
#include <QProcess>
#include <QDebug>

AppLauncher::AppLauncher(QObject *parent) : QObject(parent) {}

void AppLauncher::launchApp(QString appName)
{
    QString program;
    QStringList arguments;
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();

    if (appName == "spotify") {
        program = "spotify";
        arguments << "--enable-features=UseOzonePlatform" << "--ozone-platform=wayland";
    } else if (appName == "pure-maps") {
        // Option 1: direkt
        program = "pure-maps";
        env.insert("QT_QPA_PLATFORM", "wayland");
        env.insert("QT_PLUGIN_PATH", "/usr/local/qml");
        env.insert("QML2_IMPORT_PATH", "/usr/lib/qml");

        // Option 2: mit Flatpak
        // program = "flatpak";
        // arguments << "run" << "io.github.rinigus.PureMaps";
    } else {
        qWarning() << "Unbekannte App:" << appName;
        return;
    }

    QProcess *process = new QProcess();
    process->setProcessEnvironment(env);
    process->startDetached(program, arguments);
}
