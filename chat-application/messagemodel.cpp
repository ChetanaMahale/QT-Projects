#include "messagemodel.h"

MessageModel::MessageModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int MessageModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_messages.size();
}

QVariant MessageModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_messages.size())
        return {};

    const Message &msg = m_messages[index.row()];

    switch (role) {
    case SenderRole:    return msg.sender;
    case TextRole:      return msg.text;
    case TimestampRole: return msg.timestamp;
    case IsMeRole:      return msg.isMe;
    case TimeTextRole:  return msg.timestamp.toString("hh:mm");
    default:            return {};
    }
}

QHash<int, QByteArray> MessageModel::roleNames() const
{
    return {
        { SenderRole,    "sender"    },
        { TextRole,      "text"      },
        { TimestampRole, "timestamp" },
        { IsMeRole,      "isMe"      },
        { TimeTextRole,  "timeText"  }
    };
}

void MessageModel::addMessage(const QString &sender, const QString &text, bool isMe)
{
    beginInsertRows({}, m_messages.size(), m_messages.size());
    Message msg;
    msg.sender = sender;
    msg.text = text;
    msg.timestamp = QDateTime::currentDateTime();
    msg.isMe = isMe;
    m_messages.append(msg);
    endInsertRows();
}

void MessageModel::clear()
{
    beginResetModel();
    m_messages.clear();
    endResetModel();
}
