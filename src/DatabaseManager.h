#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    Q_INVOKABLE void connect();
    Q_INVOKABLE void upsertProgram(const QString &id, const QString &source, const QString &label, int pi);
    Q_INVOKABLE void upsertFrequency(const QString &programId, int freq, int rssi, int snr);

public slots:
    void processRdsJson(const QString &jsonString, int frequencyHz);

private:
    QSqlDatabase m_database;
    void initSchema();
};

#endif // DATABASEMANAGER_H
