#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>

class ExpenseManager : public QObject
{
    Q_OBJECT

    // Summary stats
    Q_PROPERTY(double totalExpenses     READ totalExpenses     NOTIFY dataChanged)
    Q_PROPERTY(double totalIncome       READ totalIncome       NOTIFY dataChanged)
    Q_PROPERTY(double balance           READ balance           NOTIFY dataChanged)
    Q_PROPERTY(double monthlyExpenses   READ monthlyExpenses   NOTIFY dataChanged)
    Q_PROPERTY(double monthlyIncome     READ monthlyIncome     NOTIFY dataChanged)

    // Lists
    Q_PROPERTY(QVariantList transactions    READ transactions    NOTIFY dataChanged)
    Q_PROPERTY(QVariantList categoryTotals  READ categoryTotals  NOTIFY dataChanged)
    Q_PROPERTY(QVariantList monthlyTrend    READ monthlyTrend    NOTIFY dataChanged)

    // Filters
    Q_PROPERTY(QString filterType      READ filterType      WRITE setFilterType      NOTIFY filterChanged)
    Q_PROPERTY(QString filterCategory  READ filterCategory  WRITE setFilterCategory  NOTIFY filterChanged)
    Q_PROPERTY(QString searchText      READ searchText      WRITE setSearchText      NOTIFY filterChanged)

public:
    explicit ExpenseManager(QObject *parent = nullptr);

    double       totalExpenses()    const { return m_totalExpenses; }
    double       totalIncome()      const { return m_totalIncome; }
    double       balance()          const { return m_balance; }
    double       monthlyExpenses()  const { return m_monthlyExpenses; }
    double       monthlyIncome()    const { return m_monthlyIncome; }
    QVariantList transactions()     const { return m_transactions; }
    QVariantList categoryTotals()   const { return m_categoryTotals; }
    QVariantList monthlyTrend()     const { return m_monthlyTrend; }
    QString      filterType()       const { return m_filterType; }
    QString      filterCategory()   const { return m_filterCategory; }
    QString      searchText()       const { return m_searchText; }

    void setFilterType(const QString &type);
    void setFilterCategory(const QString &cat);
    void setSearchText(const QString &text);

public slots:
    Q_INVOKABLE bool addTransaction(const QString &title,
                                    double amount,
                                    const QString &category,
                                    const QString &type,       // "expense" | "income"
                                    const QString &date,
                                    const QString &note);

    Q_INVOKABLE bool deleteTransaction(int id);
    Q_INVOKABLE void refresh();
    Q_INVOKABLE QVariantMap getTransaction(int id);
    Q_INVOKABLE QVariantList getCategories() const;

signals:
    void dataChanged();
    void filterChanged();
    void errorOccurred(const QString &message);

private:
    void initDb();
    void loadAll();
    void computeStats();
    void loadCategoryTotals();
    void loadMonthlyTrend();

    QSqlDatabase  m_db;
    double        m_totalExpenses   = 0.0;
    double        m_totalIncome     = 0.0;
    double        m_balance         = 0.0;
    double        m_monthlyExpenses = 0.0;
    double        m_monthlyIncome   = 0.0;
    QVariantList  m_transactions;
    QVariantList  m_categoryTotals;
    QVariantList  m_monthlyTrend;
    QString       m_filterType;
    QString       m_filterCategory;
    QString       m_searchText;
};
