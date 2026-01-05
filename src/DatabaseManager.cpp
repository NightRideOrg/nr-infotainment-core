#include "DatabaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <utility>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent) {}

DatabaseManager::~DatabaseManager() {
    if (m_database.isOpen()) m_database.close();
}

void DatabaseManager::connect() {
    // 1. Setup SQLite
    m_database = QSqlDatabase::addDatabase("QSQLITE");
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path);
    if (!dir.exists()) dir.mkpath(".");

    m_database.setDatabaseName(path + "/radio_data.db");

    if (m_database.open()) {
        qDebug() << "DB Connected at:" << path;
        initSchema();
    } else {
        qDebug() << "DB Connect Fail:" << m_database.lastError();
    }
}

void DatabaseManager::initSchema() {
    QSqlQuery query;

    // 1. Programs Table
    query.exec("CREATE TABLE IF NOT EXISTS programs ("
               "id TEXT PRIMARY KEY, "
               "source TEXT NOT NULL, "
               "label TEXT, "
               "pi INTEGER, "
               "last_seen INTEGER)");

    // 2. FM Frequencies Table
    query.exec("CREATE TABLE IF NOT EXISTS fm_frequencies ("
               "program_id TEXT, "
               "frequency INTEGER, "
               "rssi INTEGER, "
               "snr INTEGER, "
               "last_seen INTEGER, "
               "PRIMARY KEY(program_id, frequency))");

    // 3. RDS State Table
    query.exec("CREATE TABLE IF NOT EXISTS fm_rds_state ("
               "program_id TEXT PRIMARY KEY, "
               "pty INTEGER, "
               "tp BOOLEAN, "
               "ta BOOLEAN)");
}

void DatabaseManager::upsertProgram(const QString &id, const QString &source, const QString &label, int pi) {
    QSqlQuery query;
    // SQLite upsert syntax: INSERT OR REPLACE
    query.prepare("INSERT OR REPLACE INTO programs (id, source, label, pi, last_seen) "
                  "VALUES (:id, :src, :lbl, :pi, :time)");

    query.bindValue(":id", id);
    query.bindValue(":src", source);
    query.bindValue(":lbl", label);
    query.bindValue(":pi", pi);
    query.bindValue(":time", QDateTime::currentSecsSinceEpoch());

    if (!query.exec()) qDebug() << "Upsert Program Error:" << query.lastError();
}

void DatabaseManager::upsertFrequency(const QString &programId, int freq, int rssi, int snr) {
    QSqlQuery query;
    query.prepare("INSERT OR REPLACE INTO fm_frequencies (program_id, frequency, rssi, snr, last_seen) "
                  "VALUES (:pid, :freq, :rssi, :snr, :time)");

    query.bindValue(":pid", programId);
    query.bindValue(":freq", freq);
    query.bindValue(":rssi", rssi);
    query.bindValue(":snr", snr);
    query.bindValue(":time", QDateTime::currentSecsSinceEpoch());

    if (!query.exec()) qDebug() << "Upsert Freq Error:" << query.lastError();
}

void DatabaseManager::processRdsJson(const QString &jsonString, int frequencyHz)
{
    QJsonDocument doc = QJsonDocument::fromJson(jsonString.toUtf8());
    if (doc.isNull() || !doc.isObject()) return;

    QJsonObject obj = doc.object();

    // 1. PI is the unique ID. If we don't have this, we can't do anything.
    if (!obj.contains("pi")) return;

    QString piStr = obj["pi"].toString();
    bool ok;
    int piVal = piStr.toInt(&ok, 16);
    if(!ok) piVal = 0;

    // 2. Handle Station Name (PS)
    if (obj.contains("ps")) {
        QString ps = obj["ps"].toString().trimmed();
        if (!ps.isEmpty()) {
            // Update the name. Because it's an "upsert", it will
            // overwrite "Unknown" with the real name once it's found.
            upsertProgram(piStr, "fm", ps, piVal);
        }
    }

    // 3. Update Frequency Table
    int freqKhz = frequencyHz / 1000;
    upsertFrequency(piStr, freqKhz, 20, 20);

    // 4. Handle AF (Alternative Frequencies)
    QJsonArray afList;

    // Method A: Direct array
    if (obj.contains("alt_frequencies_a")) {
        afList = obj["alt_frequencies_a"].toArray();
    }
    // Method B: Nested object (alt_frequencies_b -> same_programme)
    else if (obj.contains("alt_frequencies_b")) {
        QJsonObject afB = obj["alt_frequencies_b"].toObject();
        if (afB.contains("same_programme")) {
            afList = afB["same_programme"].toArray();
        }
    }

    // Process whichever list was found
    for (const QJsonValue &val : std::as_const(afList)) {
        int afFreqKhz = val.toInt();
        // Zero check prevents invalid frequencies
        if (afFreqKhz > 0) {
            // upsert with 0 RSSI/SNR to indicate we know the freq exists
            // but we aren't currently tuned to it
            upsertFrequency(piStr, afFreqKhz, 0, 0);
        }
    }
}
