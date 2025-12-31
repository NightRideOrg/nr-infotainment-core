#ifndef PROGRAMMODEL_H
#define PROGRAMMODEL_H

#include <QSqlQueryModel>

class ProgramModel : public QSqlQueryModel
{
    Q_OBJECT
public:
    explicit ProgramModel(QObject *parent = nullptr);

    // QML calls this to reload data
    Q_INVOKABLE void refresh();

    // Define role names to be used in QML (e.g., model.label)
    QHash<int, QByteArray> roleNames() const override;

    // The data function that will make the roles available to QML
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    // We define an enum for our columns
    enum Roles {
        IdRole = Qt::UserRole + 1,
        SourceRole,
        LabelRole,
        PiRole,
        BestFreqRole,
        AllFreqsRole
    };
};

#endif // PROGRAMMODEL_H
