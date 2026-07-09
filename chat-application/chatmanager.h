#pragma once

#include <QObject>
#include <QStringList>
#include <QMap>
#include <QTimer>
#include "messagemodel.h"

class ChatManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList rooms READ rooms CONSTANT)
    Q_PROPERTY(QString activeRoom READ activeRoom WRITE setActiveRoom NOTIFY activeRoomChanged)
    Q_PROPERTY(QString currentUser READ currentUser CONSTANT)
    Q_PROPERTY(MessageModel* messageModel READ messageModel NOTIFY messageModelChanged)

public:
    explicit ChatManager(QObject *parent = nullptr);
    ~ChatManager();

    QStringList rooms() const;
    QString activeRoom() const;
    QString currentUser() const;
    MessageModel* messageModel() const;

public slots:
    void setActiveRoom(const QString &roomName);
    void sendMessage(const QString &text);
    void simulateIncomingMessage();

signals:
    void activeRoomChanged();
    void messageModelChanged();
    void messageReceived();

private:
    void initializeMockHistory();

    QStringList m_rooms;
    QString m_activeRoom;
    QString m_currentUser;
    QMap<QString, MessageModel*> m_roomModels;
    QTimer *m_simTimer;
    QStringList m_mockSenders;
    QStringList m_mockPhrases;
};
