# 💬 Qt Chat & Simulation Sandbox

A beautiful **Chat Application showcase** built with **Qt 6 + QML**, demonstrating multi-model data mapping, C++ event loop simulation timers, and a state-of-the-art interactive glassmorphism UI.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Multi-room Channels** | Dynamic switching between channels (`#general`, `#qt-dev`, `#design-critique`, `#random`) |
| **Model Isolation** | Each chat room owns an independent C++ list model (`MessageModel`) |
| **Live Simulator** | Active background timers periodically broadcast mock responses from other users |
| **Bubble Layouts** | Color-coded and formatted chat bubbles (Me 🟣 vs Others 🌑) |
| **Autoscroll** | Automatically positions lists at the newest message upon receipt |
| **Input Overlay** | Floating place-holders, enter-key integrations, and scaling send icons |

---

## 🏗️ Architecture

```
chat-application/
├── main.cpp            # Registers the ChatManager state to the QML context property
├── chatmanager.h       # Aggregates room list, controls active room index, handles simulation timer
├── chatmanager.cpp     # Dispatches replies, manages simulated reaction intervals, seeds history
├── messagemodel.h      # QAbstractListModel schema for lists (sender, body text, isMe flags, timestamps)
├── messagemodel.cpp    # Appends new messages and notifies QML lists via begin/endInsertRows
├── Main.qml            # Layout splits, room delegates, message bubbles, list auto-scrollers
└── CMakeLists.txt      # Custom Qt Quick module compilation setup
```

### Design Pattern
- **`MessageModel`** inherits `QAbstractListModel`, ensuring memory-safe list indexing and optimized rendering in the `ListView`.
- **`ChatManager`** acts as a controller coordinating multiple models and handling background simulation loops.

---

## 🚀 Build & Run

### Prerequisites
- **Qt 6.5+** (including Quick modules)
- **CMake 3.16+**

### Compilation Steps

```bash
# Generate compilation binaries directory
cmake -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/msvc2022_64"

# Compile release files
cmake --build build --config Release

# Run Chat Sandbox
./build/Release/appchatapplication.exe
```

---

## 📄 License

MIT License — free to use and distribute.
