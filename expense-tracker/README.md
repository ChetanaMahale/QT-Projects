# 💰 Expense Tracker

A full-featured **personal finance tracker** built with **Qt 6 / QML** and **SQLite**. Track income and expenses, visualise spending by category with an interactive donut chart, and monitor monthly trends with an animated bar chart — all stored persistently in a local database.

---

## ✨ Features

| Feature | Details |
|---|---|
| 📊 **Dashboard** | Live stat cards (total expenses, income, balance, monthly summary) |
| 📋 **Transactions** | Full list with search, type filter (All / Expenses / Income) |
| 🍩 **Analytics** | Interactive donut chart by category + animated 6-month bar chart |
| ➕➖ **Add / Delete** | Animated dialog to add income or expenses with category picker |
| 💾 **SQLite backend** | All data persisted via `Qt Sql` — survives app restarts |
| 🎨 **Dark theme** | Catppuccin-inspired dark UI with glassmorphism cards |

---

## 🗂️ Project Structure

```
expense-tracker/
├── CMakeLists.txt          # Qt 6 build (Quick + Sql + Charts)
├── main.cpp                # App entry point
├── expensemanager.h/.cpp   # C++ backend: SQLite CRUD, stats, filters
├── Main.qml                # 3-page app shell (Dashboard, Transactions, Analytics)
└── components/
    ├── AddExpenseDialog.qml  # Add income/expense dialog
    ├── ExpenseCard.qml       # Transaction list row
    ├── StatCard.qml          # Summary metric card
    ├── CategoryBadge.qml     # Pill badge for categories
    └── DonutChart.qml        # Pure QML Canvas donut chart
```

---

## 🛠️ Tech Stack

- **Qt 6.5+** — Quick, Sql, Charts
- **QML** — declarative UI, animations, Canvas 2D
- **C++** — `QObject` backend, `QSqlDatabase`, `QSqlQuery`
- **SQLite** — embedded database via `QSQLITE` driver

---

## 🚀 Getting Started

1. Open `expense-tracker/` in **Qt Creator**
2. Select **Desktop Qt 6.8.x MSVC2022 64bit** kit
3. Click **Configure Project** → **▶ Run**

> The SQLite database is created automatically in your OS user-data directory on first launch.

---

## 📸 Pages

### Dashboard
- Live balance, income vs. expense stats
- Donut chart (by category) + recent transactions list

### Transactions
- Full filterable/searchable transaction log
- Delete any entry with a single click

### Analytics
- Category breakdown with animated progress bars
- 6-month income vs. expense bar chart

---

## 📄 License

MIT License — free to use and distribute.
