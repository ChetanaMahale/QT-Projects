# 📻 Qt Media Player Simulation

A gorgeous **Media Player dashboard** built with **Qt 6 + QML** featuring playlist selections, volume bars, playback timers, C++ simulator loops, and a rotating disc vinyl visualization.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Simulated Progress** | 1-second interval timers in C++ update playback positions when playing and transition tracks automatically on finish. |
| **Vinyl Visualization** | Interactive record sleeve graphic that spins when playing and halts smoothly when paused. |
| **Playlist Index** | Left sidebar displaying metadata (Titles, Artists, Emojis, and durations) supporting selection clicks. |
| **Control Console** | Play/Pause, Stop, Next, and Previous control buttons. |
| **Volume Slider** | Horizontal volume level adjuster supporting mute toggles. |
| **Clean Design** | Premium slate background with glassmorphic cards and glowing control points. |

---

## 🏗️ Architecture

```
media-player/
├── main.cpp            # Exposes the PlayerManager instance to QML context
├── playermanager.h     # Properties definitions for position ticks, track indexes, and audio states
├── playermanager.cpp   # Timer connections, track lists seed arrays, and format converters
├── Main.qml            # Layout grid, playlist side-views, vinyl rotators, buttons, and volume bar
└── CMakeLists.txt      # Multi-platform Qt 6 Quick module compiler setup
```

### Design Pattern
- **`PlayerManager`** (C++) runs all calculation logs, keeps track of playlists, and runs the active timer simulation.
- **`Main.qml`** (QML) listens to signals for operations and updates sliders and timers.

---

## 🚀 Build & Run

### Prerequisites
- **Qt 6.5+** (including Quick modules)
- **CMake 3.16+**

### Compilation Steps

```bash
# Generate project binaries configuration
cmake -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/msvc2022_64"

# Build target
cmake --build build --config Release

# Launch player
./build/Release/appmediaplayer.exe
```

---

## 📄 License

MIT License — free to use and distribute.
