#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QString>
#include <QList>

struct Message {
    QString sender;
    QString text;
    QDateTime timestamp;
    bool isMe;
};

class MessageModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        SenderRole = Qt::UserRole + 1,
        TextRole,
        TimestampRole,
        IsMeRole,
        TimeTextRole
    };
    Q_ENUM(Roles)

    explicit MessageModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addMessage(const QString &sender, const QString &text, bool isMe);
    void clear();

private:
    QList<Message> m_messages;
};
