#include "todomanager.h"

TodoManager::TodoManager(QObject *parent)
    : QAbstractListModel(parent)
    , m_filterMode(0)
    , m_nextId(1)
{
    // Seed with a couple of sample tasks
    addTodo("Buy groceries", 1);
    addTodo("Read Qt documentation", 2);
    addTodo("Fix calculator bug", 2);
    addTodo("Go for a walk", 0);
}

// ── QAbstractListModel interface ──────────────────────────────────────────────

int TodoManager::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_filtered.size();
}

QVariant TodoManager::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_filtered.size())
        return {};

    const TodoItem &item = m_all[m_filtered[index.row()]];

    switch (role) {
    case IdRole:           return item.id;
    case TitleRole:        return item.title;
    case CompletedRole:    return item.completed;
    case PriorityRole:     return item.priority;
    case CreatedAtRole:    return item.createdAt;
    case CreatedAtTextRole:
        return item.createdAt.toString("MMM d, hh:mm");
    default:               return {};
    }
}

bool TodoManager::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() >= m_filtered.size())
        return false;

    TodoItem &item = m_all[m_filtered[index.row()]];

    if (role == CompletedRole) {
        item.completed = value.toBool();
        emit dataChanged(index, index, {role});
        emit countsChanged();
        return true;
    }
    if (role == TitleRole) {
        item.title = value.toString();
        emit dataChanged(index, index, {role});
        return true;
    }
    return false;
}

QHash<int, QByteArray> TodoManager::roleNames() const
{
    return {
        { IdRole,           "todoId"       },
        { TitleRole,        "title"        },
        { CompletedRole,    "completed"    },
        { PriorityRole,     "priority"     },
        { CreatedAtRole,    "createdAt"    },
        { CreatedAtTextRole,"createdAtText"},
    };
}

// ── Properties ────────────────────────────────────────────────────────────────

int TodoManager::totalCount() const     { return m_all.size(); }
int TodoManager::activeCount() const
{
    int c = 0;
    for (const auto &t : m_all) if (!t.completed) ++c;
    return c;
}
int TodoManager::completedCount() const { return m_all.size() - activeCount(); }
int TodoManager::filterMode()     const { return m_filterMode; }

void TodoManager::setFilterMode(int mode)
{
    if (m_filterMode == mode) return;
    m_filterMode = mode;
    beginResetModel();
    rebuildFiltered();
    endResetModel();
    emit filterModeChanged();
}

// ── Slots ─────────────────────────────────────────────────────────────────────

void TodoManager::addTodo(const QString &title, int priority)
{
    if (title.trimmed().isEmpty()) return;

    TodoItem item;
    item.id        = m_nextId++;
    item.title     = title.trimmed();
    item.completed = false;
    item.priority  = qBound(0, priority, 2);
    item.createdAt = QDateTime::currentDateTime();

    // Determine if visible under current filter (filter 0=All, 1=Active)
    bool visible = (m_filterMode == 0 || m_filterMode == 1);

    if (visible) {
        beginInsertRows({}, 0, 0);
        m_all.prepend(item);
        rebuildFiltered();
        endInsertRows();
    } else {
        m_all.prepend(item);
        rebuildFiltered();
    }
    emit countsChanged();
}

void TodoManager::removeTodo(int id)
{
    int allIdx = indexOfId(id);
    if (allIdx < 0) return;

    int filtIdx = filteredIndexOfId(id);
    if (filtIdx >= 0) {
        beginRemoveRows({}, filtIdx, filtIdx);
        m_all.removeAt(allIdx);
        rebuildFiltered();
        endRemoveRows();
    } else {
        m_all.removeAt(allIdx);
        rebuildFiltered();
    }
    emit countsChanged();
}

void TodoManager::toggleTodo(int id)
{
    int allIdx = indexOfId(id);
    if (allIdx < 0) return;

    m_all[allIdx].completed = !m_all[allIdx].completed;

    // In filtered views (Active/Completed), item may disappear after toggle
    if (m_filterMode == 0) {
        // All view — just update in place
        int filtIdx = filteredIndexOfId(id);
        if (filtIdx >= 0) {
            QModelIndex mi = createIndex(filtIdx, 0);
            emit dataChanged(mi, mi, {CompletedRole});
        }
    } else {
        // Item leaves the current filter — remove it from view
        int filtIdx = filteredIndexOfId(id);
        if (filtIdx >= 0) {
            beginRemoveRows({}, filtIdx, filtIdx);
            rebuildFiltered();
            endRemoveRows();
        } else {
            rebuildFiltered();
        }
    }
    emit countsChanged();
}

void TodoManager::editTodo(int id, const QString &newTitle)
{
    if (newTitle.trimmed().isEmpty()) return;
    int allIdx = indexOfId(id);
    if (allIdx < 0) return;

    m_all[allIdx].title = newTitle.trimmed();

    int filtIdx = filteredIndexOfId(id);
    if (filtIdx >= 0) {
        QModelIndex mi = createIndex(filtIdx, 0);
        emit dataChanged(mi, mi, {TitleRole});
    }
}

void TodoManager::clearCompleted()
{
    // Remove all completed items
    beginResetModel();
    m_all.removeIf([](const TodoItem &t) { return t.completed; });
    rebuildFiltered();
    endResetModel();
    emit countsChanged();
}

// ── Private helpers ───────────────────────────────────────────────────────────

void TodoManager::rebuildFiltered()
{
    m_filtered.clear();
    for (int i = 0; i < m_all.size(); ++i) {
        const auto &t = m_all[i];
        if (m_filterMode == 0) {
            m_filtered.append(i);
        } else if (m_filterMode == 1 && !t.completed) {
            m_filtered.append(i);
        } else if (m_filterMode == 2 && t.completed) {
            m_filtered.append(i);
        }
    }
}

int TodoManager::indexOfId(int id) const
{
    for (int i = 0; i < m_all.size(); ++i)
        if (m_all[i].id == id) return i;
    return -1;
}

int TodoManager::filteredIndexOfId(int id) const
{
    for (int i = 0; i < m_filtered.size(); ++i)
        if (m_all[m_filtered[i]].id == id) return i;
    return -1;
}
