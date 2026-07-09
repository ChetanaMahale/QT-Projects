#include "chatmanager.h"
#include <QRandomGenerator>

ChatManager::ChatManager(QObject *parent)
    : QObject(parent)
    , m_activeRoom("#general")
    , m_currentUser("You")
{
    m_rooms = { "#general", "#qt-dev", "#design-critique", "#random" };

    // Setup models for each room
    for (const QString &room : m_rooms) {
        m_roomModels[room] = new MessageModel(this);
    }

    // Mock senders
    m_mockSenders = { "Sarah Connor", "John Doe", "Alice Smith", "Linus T.", "Ada Lovelace" };

    // Mock response pool
    m_mockPhrases = {
        "Awesome! That works perfectly.",
        "Wait, did you check the QML compilation logs?",
        "I really like the dark mode theme we added to the dashboard.",
        "Has anyone tried deploying this using CMake directly on macOS?",
        "No problem! Glad I could help.",
        "Are we still on schedule for the Qt 6.8 release showcase?",
        "Wow, that glow effect on the UI looks premium.",
        "Check out this documentation: https://doc.qt.io",
        "Indeed. C++ logic combined with QML view makes it very modular."
    };

    initializeMockHistory();

    // Setup simulator timer
    m_simTimer = new QTimer(this);
    connect(m_simTimer, &QTimer::timeout, this, &ChatManager::simulateIncomingMessage);
    m_simTimer->start(6500); // Trigger a mock message every 6.5 seconds
}

ChatManager::~ChatManager()
{
}

QStringList ChatManager::rooms() const { return m_rooms; }
QString ChatManager::activeRoom() const { return m_activeRoom; }
QString ChatManager::currentUser() const { return m_currentUser; }
MessageModel* ChatManager::messageModel() const { return m_roomModels[m_activeRoom]; }

void ChatManager::setActiveRoom(const QString &roomName)
{
    if (m_rooms.contains(roomName) && m_activeRoom != roomName) {
        m_activeRoom = roomName;
        emit activeRoomChanged();
        emit messageModelChanged();
    }
}

void ChatManager::sendMessage(const QString &text)
{
    if (text.trimmed().isEmpty()) return;

    MessageModel *model = m_roomModels[m_activeRoom];
    model->addMessage(m_currentUser, text.trimmed(), true);
    emit messageReceived();

    // Trigger an immediate mock reaction after user replies (sometimes)
    if (QRandomGenerator::global()->bounded(10) > 4) {
        QTimer::singleShot(1500, this, &ChatManager::simulateIncomingMessage);
    }
}

void ChatManager::simulateIncomingMessage()
{
    // Choose a random room
    int roomIdx = QRandomGenerator::global()->bounded(m_rooms.size());
    QString targetRoom = m_rooms[roomIdx];

    // Pick random sender & phrase
    int senderIdx = QRandomGenerator::global()->bounded(m_mockSenders.size());
    int phraseIdx = QRandomGenerator::global()->bounded(m_mockPhrases.size());

    QString sender = m_mockSenders[senderIdx];
    QString text = m_mockPhrases[phraseIdx];

    MessageModel *model = m_roomModels[targetRoom];
    model->addMessage(sender, text, false);

    if (targetRoom == m_activeRoom) {
        emit messageReceived();
    }
}

void ChatManager::initializeMockHistory()
{
    m_roomModels["#general"]->addMessage("Ada Lovelace", "Welcome to the showcase general chat!", false);
    m_roomModels["#general"]->addMessage("Sarah Connor", "Hey folks, the calculator app is pushing to git successfully.", false);
    m_roomModels["#general"]->addMessage("Linus T.", "Make sure to clean build when switching toolchains.", false);

    m_roomModels["#qt-dev"]->addMessage("John Doe", "How do I implement custom QAbstractListModel roles?", false);
    m_roomModels["#qt-dev"]->addMessage("Ada Lovelace", "Define roleNames() and map enum values to string labels.", false);

    m_roomModels["#design-critique"]->addMessage("Alice Smith", "The glowing equals button on the calculator looks great.", false);
    m_roomModels["#design-critique"]->addMessage("Sarah Connor", "Agreed, glassmorphic card widgets fit dark mode perfectly.", false);

    m_roomModels["#random"]->addMessage("Linus T.", "Why is coffee a developer requirement? ☕", false);
}
