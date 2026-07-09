# 🔐 Qt Login & Registration System

A premium **Login, Registration, and Dashboard application** built with **Qt 6 + QML** showcasing full MVVM integration with a validation-rich C++ authentication engine backend.

---

## ✨ Features

| Feature | Details |
|---|---|
| **User Sign In** | Email or Username support + real-time validation checks |
| **Secure Registration** | Minimum length constraints, regex-based valid email checks |
| **Password Strength Meter** | Dynamic strength calculation (Weak 🔴 / Medium 🟡 / Strong 🟢) |
| **Dashboard** | Responsive panel showing current logged-in user profile status |
| **Toast Notifications** | Slide-up popups for success messages and validation errors |
| **Clean UI** | Deep slate theme (`#0d0d0f`) with glassmorphic cards and canvas radial gradients |

---

## 🏗️ Architecture

```
login-system/
├── main.cpp         # Registers AuthManager instance to QML context
├── authmanager.h    # QObject definition for authentication slots & signals
├── authmanager.cpp  # Regex validators, credential storage, and password strength checks
├── Main.qml         # Modern UI with dynamic views, transitions, and inline CustomInput
└── CMakeLists.txt   # Cross-platform Qt 6 CMake configuration
```

### Design Pattern
- **`AuthManager`** (C++) contains all verification rules, regex matching, and state management.
- **`Main.qml`** (QML) listens to signals (`loginSuccess`, `registrationError`, etc.) to update UI state, switch screens, and display toast messages.
- Declarative components and zero styling pollution make it perfect for styling extension.

---

## 🚀 Build & Run

### Prerequisites
- **Qt 6.5+** (including Quick modules)
- **CMake 3.16+**

### Compilation Steps

```bash
# Generate build configuration
cmake -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/msvc2022_64"

# Compile release build
cmake --build build --config Release

# Execute binary
./build/Release/apploginsystem.exe
```

---

## 💡 Accounts Preloaded (Demo)
- **Username:** `admin`
- **Password:** `Password123`

---

## 📄 License

MIT License — free to use and distribute.
