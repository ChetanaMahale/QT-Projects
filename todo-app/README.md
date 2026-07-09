# ✅ Qt ToDo App

A feature-rich **To-Do List application** built with **Qt 6 + QML**, demonstrating proper use of `QAbstractListModel`, C++/QML integration, and a polished animated dark UI.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Add Tasks** | Collapsible panel with title input and priority selector |
| **Priority Levels** | High 🔴 / Medium 🟡 / Low 🔵 — colour-coded badge + left stripe |
| **Complete Tasks** | Click the circle checkbox to toggle completion |
| **Inline Edit** | Double-click any task title to edit it in place |
| **Delete Tasks** | Hover a card to reveal the × delete button |
| **Filter Tabs** | All / Active / Done — with live counts |
| **Clear Completed** | One-click remove all finished tasks |
| **Animations** | Cards slide in on add, fade+slide on remove, displace smoothly |
| **Empty States** | Context-aware messages for each filter view |

---

## 🏗️ Architecture

```
todo-app/
├── main.cpp           # Entry point — registers TodoManager as QML context property
├── todomanager.h      # QAbstractListModel subclass with roles, filters, CRUD slots
├── todomanager.cpp    # Full model implementation with proper begin/endInsertRows
├── Main.qml           # Complete UI — 380+ lines of declarative QML
└── CMakeLists.txt     # Qt 6 CMake build configuration
```

### Design Pattern
- **`TodoManager`** extends `QAbstractListModel` — the *correct* Qt way to expose lists to QML
- Roles: `todoId`, `title`, `completed`, `priority`, `createdAtText`
- Filter applied server-side in C++ — QML `ListView` sees only relevant items
- QML is purely declarative — **zero business logic** in the UI layer

---

## 🚀 Build & Run

### Prerequisites
- **Qt 6.5+** with Quick module
- **CMake 3.16+**, C++17 compiler

### Qt Creator (Easiest)
1. Open `CMakeLists.txt` in Qt Creator
2. Press **▶ Run**

### Command Line
```bash
cmake -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/msvc2022_64"
cmake --build build --config Release
./build/Release/apptodoapp.exe
```

---

## 🎨 UI Highlights

- Deep dark theme (`#0d0d0f`) with **violet accent** (`#a78bfa`)
- Radial gradient background blobs via `Canvas`
- **Priority stripe** on left edge of each card
- Smooth `add/remove/displaced` transitions on `ListView`
- Inline `TextInput` edit — double-click to activate, Enter/Escape/blur to confirm
- Delete button appears **on hover** — clean and uncluttered

---

## 🛠️ Tech Stack

- **Qt 6** — `QtQuick`, `QtQuick.Controls`, `QtQuick.Layouts`
- **QML** — Inline components, `Loader`, property bindings, `Transition` animations
- **C++17** — `QAbstractListModel`, `Q_PROPERTY`, signals/slots
- **CMake** — Cross-platform build

---

## 📄 License

MIT License — free to use, modify, and distribute.
