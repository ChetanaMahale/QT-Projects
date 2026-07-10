#include "expensemanager.h"

#include <QtSql/QSqlError>
#include <QDate>
#include <QDebug>

// ─── Category metadata ───────────────────────────────────────────────────────
static const QStringList CATEGORIES = {
    "Food & Dining", "Shopping", "Transport", "Entertainment",
    "Health", "Bills & Utilities", "Education", "Travel",
    "Salary", "Freelance", "Investment", "Other"
};

static const QStringList CAT_COLORS = {
    "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
    "#FECA57", "#FF9FF3", "#54A0FF", "#5F27CD",
    "#1DD1A1", "#00D2D3", "#F8C291", "#A29BFE"
};

static const QStringList CAT_ICONS = {
    "🍔", "🛍️", "🚌", "🎬",
    "💊", "💡", "📚", "✈️",
    "💼", "💻", "📈", "📦"
};

// ─── Constructor ─────────────────────────────────────────────────────────────
ExpenseManager::ExpenseManager(QObject *parent) : QObject(parent)
{
    initDb();
    loadAll();
}

// ─── DB init ─────────────────────────────────────────────────────────────────
void ExpenseManager::initDb()
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName("expenses.db");

    if (!m_db.open()) {
        qWarning() << "Cannot open DB:" << m_db.lastError().text();
        return;
    }

    QSqlQuery q(m_db);
    q.exec(R"(
        CREATE TABLE IF NOT EXISTS transactions (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            title     TEXT    NOT NULL,
            amount    REAL    NOT NULL,
            category  TEXT    NOT NULL,
            type      TEXT    NOT NULL,
            date      TEXT    NOT NULL,
            note      TEXT    DEFAULT ''
        )
    )");
}

// ─── Setters (filters) ───────────────────────────────────────────────────────
void ExpenseManager::setFilterType(const QString &type)
{
    if (m_filterType == type) return;
    m_filterType = type;
    loadAll();
    emit filterChanged();
}

void ExpenseManager::setFilterCategory(const QString &cat)
{
    if (m_filterCategory == cat) return;
    m_filterCategory = cat;
    loadAll();
    emit filterChanged();
}

void ExpenseManager::setSearchText(const QString &text)
{
    if (m_searchText == text) return;
    m_searchText = text;
    loadAll();
    emit filterChanged();
}

// ─── CRUD ────────────────────────────────────────────────────────────────────
bool ExpenseManager::addTransaction(const QString &title, double amount,
                                    const QString &category, const QString &type,
                                    const QString &date, const QString &note)
{
    if (title.trimmed().isEmpty() || amount <= 0.0) {
        emit errorOccurred("Title and a positive amount are required.");
        return false;
    }

    QSqlQuery q(m_db);
    q.prepare("INSERT INTO transactions (title, amount, category, type, date, note) "
               "VALUES (:title, :amount, :category, :type, :date, :note)");
    q.bindValue(":title",    title.trimmed());
    q.bindValue(":amount",   amount);
    q.bindValue(":category", category);
    q.bindValue(":type",     type);
    q.bindValue(":date",     date);
    q.bindValue(":note",     note.trimmed());

    if (!q.exec()) {
        emit errorOccurred("Failed to save: " + q.lastError().text());
        return false;
    }

    loadAll();
    emit dataChanged();
    return true;
}

bool ExpenseManager::deleteTransaction(int id)
{
    QSqlQuery q(m_db);
    q.prepare("DELETE FROM transactions WHERE id = :id");
    q.bindValue(":id", id);
    if (!q.exec()) {
        emit errorOccurred("Failed to delete: " + q.lastError().text());
        return false;
    }
    loadAll();
    emit dataChanged();
    return true;
}

void ExpenseManager::refresh()
{
    loadAll();
    emit dataChanged();
}

QVariantMap ExpenseManager::getTransaction(int id)
{
    QSqlQuery q(m_db);
    q.prepare("SELECT * FROM transactions WHERE id = :id");
    q.bindValue(":id", id);
    if (q.exec() && q.next()) {
        QVariantMap map;
        map["id"]       = q.value("id");
        map["title"]    = q.value("title");
        map["amount"]   = q.value("amount");
        map["category"] = q.value("category");
        map["type"]     = q.value("type");
        map["date"]     = q.value("date");
        map["note"]     = q.value("note");
        return map;
    }
    return {};
}

QVariantList ExpenseManager::getCategories() const
{
    QVariantList list;
    for (int i = 0; i < CATEGORIES.size(); ++i) {
        QVariantMap m;
        m["name"]  = CATEGORIES[i];
        m["color"] = CAT_COLORS[i];
        m["icon"]  = CAT_ICONS[i];
        list.append(m);
    }
    return list;
}

// ─── Internal loaders ────────────────────────────────────────────────────────
void ExpenseManager::loadAll()
{
    // Build WHERE clause
    QStringList conditions;
    if (!m_filterType.isEmpty())     conditions << "type = :type";
    if (!m_filterCategory.isEmpty()) conditions << "category = :category";
    if (!m_searchText.isEmpty())     conditions << "title LIKE :search";

    QString sql = "SELECT * FROM transactions";
    if (!conditions.isEmpty()) sql += " WHERE " + conditions.join(" AND ");
    sql += " ORDER BY date DESC, id DESC";

    QSqlQuery q(m_db);
    q.prepare(sql);
    if (!m_filterType.isEmpty())     q.bindValue(":type",     m_filterType);
    if (!m_filterCategory.isEmpty()) q.bindValue(":category", m_filterCategory);
    if (!m_searchText.isEmpty())     q.bindValue(":search",   "%" + m_searchText + "%");

    m_transactions.clear();
    if (q.exec()) {
        while (q.next()) {
            QString cat = q.value("category").toString();
            int catIdx  = CATEGORIES.indexOf(cat);
            QString color = (catIdx >= 0) ? CAT_COLORS[catIdx] : "#A29BFE";
            QString icon  = (catIdx >= 0) ? CAT_ICONS[catIdx]  : "📦";

            QVariantMap row;
            row["id"]       = q.value("id");
            row["title"]    = q.value("title");
            row["amount"]   = q.value("amount");
            row["category"] = cat;
            row["type"]     = q.value("type");
            row["date"]     = q.value("date");
            row["note"]     = q.value("note");
            row["color"]    = color;
            row["icon"]     = icon;
            m_transactions.append(row);
        }
    }

    computeStats();
    loadCategoryTotals();
    loadMonthlyTrend();
}

void ExpenseManager::computeStats()
{
    // All-time
    {
        QSqlQuery q(m_db);
        q.exec("SELECT type, SUM(amount) FROM transactions GROUP BY type");
        m_totalExpenses = 0; m_totalIncome = 0;
        while (q.next()) {
            if (q.value(0).toString() == "expense") m_totalExpenses = q.value(1).toDouble();
            else m_totalIncome = q.value(1).toDouble();
        }
        m_balance = m_totalIncome - m_totalExpenses;
    }
    // This month
    {
        QString ym = QDate::currentDate().toString("yyyy-MM");
        QSqlQuery q(m_db);
        q.prepare("SELECT type, SUM(amount) FROM transactions WHERE date LIKE :ym GROUP BY type");
        q.bindValue(":ym", ym + "%");
        q.exec();
        m_monthlyExpenses = 0; m_monthlyIncome = 0;
        while (q.next()) {
            if (q.value(0).toString() == "expense") m_monthlyExpenses = q.value(1).toDouble();
            else m_monthlyIncome = q.value(1).toDouble();
        }
    }
}

void ExpenseManager::loadCategoryTotals()
{
    QSqlQuery q(m_db);
    q.exec("SELECT category, SUM(amount) as total FROM transactions WHERE type='expense' "
           "GROUP BY category ORDER BY total DESC");

    m_categoryTotals.clear();
    while (q.next()) {
        QString cat  = q.value("category").toString();
        double  amt  = q.value("total").toDouble();
        int catIdx   = CATEGORIES.indexOf(cat);
        QString color = (catIdx >= 0) ? CAT_COLORS[catIdx] : "#A29BFE";
        QString icon  = (catIdx >= 0) ? CAT_ICONS[catIdx]  : "📦";

        QVariantMap m;
        m["category"] = cat;
        m["total"]    = amt;
        m["color"]    = color;
        m["icon"]     = icon;
        m_categoryTotals.append(m);
    }
}

void ExpenseManager::loadMonthlyTrend()
{
    // Last 6 months
    QSqlQuery q(m_db);
    q.exec(R"(
        SELECT strftime('%Y-%m', date) as month,
               type,
               SUM(amount) as total
        FROM transactions
        WHERE date >= date('now','-6 months')
        GROUP BY month, type
        ORDER BY month
    )");

    QMap<QString, QVariantMap> monthMap;
    while (q.next()) {
        QString month = q.value("month").toString();
        QString type  = q.value("type").toString();
        double  total = q.value("total").toDouble();
        if (!monthMap.contains(month)) {
            monthMap[month]["month"]   = month;
            monthMap[month]["expense"] = 0.0;
            monthMap[month]["income"]  = 0.0;
        }
        monthMap[month][type] = total;
    }

    m_monthlyTrend.clear();
    for (const auto &entry : monthMap) {
        m_monthlyTrend.append(entry);
    }
}
