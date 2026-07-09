# 🧮 Qt Calculator

A modern, feature-rich **calculator application** built with **Qt 6 + QML**, showcasing a clean MVVM-style architecture with a C++ backend and a polished, animated QML frontend.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Basic Operations** | Addition, Subtraction, Multiplication, Division |
| **Special Functions** | Square root (`√x`), Square (`x²`), Reciprocal (`1/x`), Percentage (`%`) |
| **Chained Calculations** | Seamlessly chain multiple operations |
| **History Panel** | Last 20 calculations stored and viewable |
| **Error Handling** | Division by zero, invalid inputs (shows `Error` state) |
| **Keyboard Support** | Full keyboard input (`0–9`, `+`, `-`, `*`, `/`, `=`, `Enter`, `Backspace`, `Esc`) |
| **Animations** | Button press scale animation, result pop effect, smooth state transitions |
| **Sign Toggle** | `+/−` button to flip sign |
| **Backspace** | Delete last digit individually |

---

## 🖥️ Screenshots

> **Dark glassmorphism theme** with purple accent colours, radial gradient background blobs, and glowing equals button.

---

## 🏗️ Architecture

```
calculator/
├── main.cpp                 # App entry point — registers C++ engine with QML context
├── calculatorengine.h       # CalculatorEngine QObject — public API exposed to QML
├── calculatorengine.cpp     # All math logic: operators, chaining, history, error states
├── Main.qml                 # Full UI: display card, button grid, history panel
└── CMakeLists.txt           # Qt 6 CMake build configuration
```

### Design Pattern
- **`CalculatorEngine`** (C++) acts as the **ViewModel** — holds all state, emits change signals
- **`Main.qml`** acts as the **View** — binds to properties and calls slots via `engine.*`
- Zero business logic in QML — QML is purely declarative UI

---

## 🚀 Build & Run

### Prerequisites
- **Qt 6.5+** (tested with Qt 6.8)
- **CMake 3.16+**
- A C++17 compatible compiler (MSVC, GCC, or Clang)

### Steps

```bash
# Clone the repo
git clone https://github.com/<your-username>/calculator.git
cd calculator

# Configure with CMake (Qt6 must be in PATH or set CMAKE_PREFIX_PATH)
cmake -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/msvc2022_64"

# Build
cmake --build build --config Release

# Run
./build/Release/appcalculator.exe   # Windows
```

Or simply open the project in **Qt Creator** and press **Run** (▶).

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `0–9` | Input digit |
| `.` | Decimal point |
| `+` `-` `*` `/` | Operators |
| `Enter` / `=` | Calculate result |
| `Backspace` | Delete last digit |
| `Esc` / `C` | Clear all |
| `%` | Percentage |

---

## 🛠️ Tech Stack

- **Qt 6** — `QtQuick`, `QtQuick.Controls`, `QtQuick.Layouts`, `QtQuick.Effects`
- **QML** — Declarative UI with inline components and property bindings
- **C++17** — Backend engine with `Q_PROPERTY`, signals, and slots
- **CMake** — Cross-platform build system

---

## 📄 License

MIT License — free to use, modify, and distribute.
