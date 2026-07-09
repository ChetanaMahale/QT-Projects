#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QString>

// ── Single task data structure ────────────────────────────────────────────────
struct TodoItem {
    int      id;
    QString  title;
    bool     completed;
    int      priority;   // 0=Low, 1=Medium, 2=High
    QDateTime createdAt;
};

// ── List model exposed to QML ─────────────────────────────────────────────────
class TodoManager : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int totalCount     READ totalCount     NOTIFY countsChanged)
    Q_PROPERTY(int activeCount    READ activeCount    NOTIFY countsChanged)
    Q_PROPERTY(int completedCount READ completedCount NOTIFY countsChanged)
    Q_PROPERTY(int filterMode     READ filterMode     WRITE setFilterMode NOTIFY filterModeChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        CompletedRole,
        PriorityRole,
        CreatedAtRole,
        CreatedAtTextRole
    };
    Q_ENUM(Roles)

    explicit TodoManager(QObject *parent = nullptr);

    // QAbstractListModel interface
    int      rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool     setData(const QModelIndex &index, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

    // Properties
    int totalCount()     const;
    int activeCount()    const;
    int completedCount() const;
    int filterMode()     const;
    void setFilterMode(int mode);

public slots:
    void addTodo(const QString &title, int priority = 1);
    void removeTodo(int id);
    void toggleTodo(int id);
    void editTodo(int id, const QString &newTitle);
    void clearCompleted();

signals:
    void countsChanged();
    void filterModeChanged();

private:
    void rebuildFiltered();
    int  indexOfId(int id) const;          // index in m_all
    int  filteredIndexOfId(int id) const;  // index in m_filtered

    QList<TodoItem> m_all;
    QList<int>      m_filtered;   // indices into m_all
    int             m_filterMode; // 0=All 1=Active 2=Completed
    int             m_nextId;
};
