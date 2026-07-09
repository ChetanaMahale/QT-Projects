# 🎭 Qt QML Animations Sandbox

An interactive **animation playground application** built with **Qt 6 + QML**, showcasing standard easing properties, state-machine transitions, nested animations, spring physics, and real-time speed configuration backends in C++.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Easing Curves** | Selection dashboard mapping Linear, OutBounce, OutBack, InOutElastic, and InOutCubic curves with a visual Canvas path tracer. |
| **Combined Transforms** | Head-to-head comparison visualizing sequential (step-by-step) vs parallel (simultaneous) transformations. |
| **State-Machine transitions** | Profile Card that triggers a smooth scaling, coloring, and descriptions transition when clicked. |
| **Spring Interpolation** | Drag a lead circle (`🤝`) and watch a blue particle follow with jello-style spring/damping elasticity. |
| **Dynamic Speed** | A global speed multiplier slider (0.25x up to 2.0x) that updates C++ calculation formulas instantly. |
| **Console Monitor** | Sidebar terminal displaying live logs emitted from active C++ animation slots. |

---

## 🏗️ Architecture

```
qml-animations/
├── main.cpp                 # Passes the AnimationController context to QML
├── animationcontroller.h    # Properties definition for speed indexes, base durations, and log systems
├── animationcontroller.cpp  # Slots for state logs and duration calculation multipliers
├── Main.qml                 # Layout grids, tab buttons, curves, states, spring elements, and terminal logs
└── CMakeLists.txt           # Build execution targets mapping files and quick modules
```

### Design Pattern
- **`AnimationController`** (C++) runs all calculation logs, handles multiplier calculations, and isolates logging systems from visual bindings.
- **`Main.qml`** (QML) listens to settings changes and adjusts its transitions dynamically.

---

## 🚀 Build & Run

### Prerequisites
- **Qt 6.5+** (including Quick modules)
- **CMake 3.16+**

### Compilation Steps

```bash
# Generate cmake configuration
cmake -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/msvc2022_64"

# Compile executable
cmake --build build --config Release

# Launch sandbox
./build/Release/appqmlanimations.exe
```

---

## 📄 License

MIT License — free to use and distribute.
