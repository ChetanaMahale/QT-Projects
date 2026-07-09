# 📝 Qt Text Editor

A sleek, responsive, and performance-oriented **Text Editor application** built with **Qt 6 + QML** showcasing full file operations, document status tracking, text search, and live metrics calculations.

---

## ✨ Features

| Feature | Details |
|---|---|
| **File Operations** | New 📄, Open 📂, Save 💾, Save As 📤 via native system Dialogs |
| **Status Trackers** | Filename display, file path view, and clean "Modified •" change notifier |
| **Live Statistics** | Instant footer reports for total words, characters, and line count |
| **Find & Replace** | Collapsible header panel supporting search iteration and string replacement |
| **Aesthetic Controls** | Dedicated Sidebar icons with custom hover tooltips and dynamic editor zoom |
| **Shortcuts Support** | Keyboard macros (Ctrl+N, Ctrl+O, Ctrl+S, Ctrl+F) for rapid workflow navigation |

---

## 🏗️ Architecture

```
text-editor/
├── main.cpp         # Exposes C++ FileHandler class to QML view
├── filehandler.h    # Properties definition for stats, URL parsers, save/load handlers
├── filehandler.cpp  # Safe QFile streams, clean local URLs, word/line/char counters
├── Main.qml         # Full window UI containing collapsible search, text editing area, dialogs
└── CMakeLists.txt   # Multi-platform Qt 6 Quick module compiler setup
```

### Design Pattern
- **`FileHandler`** (C++) runs all parsing and stream procedures, isolating file reading operations from blocking UI threads.
- **`Main.qml`** (QML) listens to signals for operations and error notifications, managing visual states dynamically.

---

## 🚀 Build & Run

### Prerequisites
- **Qt 6.5+** (including Quick and Dialogs modules)
- **CMake 3.16+**

### Compilation Steps

```bash
# Generate project binaries configuration
cmake -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/msvc2022_64"

# Build target
cmake --build build --config Release

# Launch editor
./build/Release/apptexteditor.exe
```

---

## 📄 License

MIT License — free to use and distribute.
