#ifndef APPLAUNCHER_H
#define APPLAUNCHER_H

#include <QObject>

class AppLauncher : public QObject
{
    Q_OBJECT
public:
    explicit AppLauncher(QObject *parent = nullptr);

    Q_INVOKABLE void launchApp(QString appName);
};

#endif // APPLAUNCHER_H
