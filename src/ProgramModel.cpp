#include "ProgramModel.h"
#include <QSqlRecord>
#include <QDebug>
#include <QSqlError>
#include <qsqlquery.h>

ProgramModel::ProgramModel(QObject *parent) : QSqlQueryModel(parent)
{
    refresh();
}

void ProgramModel::refresh()
{
    // A query joining programs with their best frequency (by RSSI)
    // Note: This matches your schema logic
    QString sql = R"(
        SELECT
            p.id,
            p.source,
            p.label,
            p.pi,
            (SELECT frequency FROM fm_frequencies f
             WHERE f.program_id = p.id
             ORDER BY f.rssi DESC LIMIT 1) as best_freq
        FROM programs p
        ORDER BY p.label ASC
    )";

    this->setQuery(sql);

    if (lastError().isValid()) {
        qDebug() << "Model Error:" << lastError();
    }
}

QHash<int, QByteArray> ProgramModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "programId";
    roles[SourceRole] = "source";
    roles[LabelRole] = "label";
    roles[PiRole] = "pi";
    roles[BestFreqRole] = "frequency";
    roles[AllFreqsRole] = "allFrequencies";
    return roles;
}

QVariant ProgramModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return QVariant();

    if (role < Qt::UserRole) {
        return QSqlQueryModel::data(index, role);
    }

    const QSqlRecord sqlRecord = record(index.row());

    // Handle standard single-value roles
    if (role == IdRole) return sqlRecord.value("id");
    if (role == SourceRole) return sqlRecord.value("source");
    if (role == LabelRole) return sqlRecord.value("label");
    if (role == PiRole) return sqlRecord.value("pi");
    if (role == BestFreqRole) return sqlRecord.value("best_freq");

    // Handle the "List" role
    if (role == AllFreqsRole) {
        QString progId = sqlRecord.value("id").toString();
        QVariantList freqList;

        QSqlQuery q;
        q.prepare("SELECT frequency, rssi, snr FROM fm_frequencies WHERE program_id = :id ORDER BY rssi DESC");
        q.bindValue(":id", progId);

        if (q.exec()) {
            while (q.next()) {
                QVariantMap map;
                map["frequency"] = q.value(0).toInt();
                map["rssi"] = q.value(1).toInt();
                map["snr"] = q.value(2).toInt();
                freqList.append(map);
            }
        }
        return freqList;
    }

    return QVariant();
}
