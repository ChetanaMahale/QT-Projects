# 🌤️ Qt Weather App

A real-time **Weather Dashboard** built with **Qt 6 + QML**, powered by the **OpenWeatherMap API**. Features live current conditions, a dynamic 5-day forecast, sunrise/sunset times, and a weather-reactive animated background.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Live API Data** | Fetches real weather via OpenWeatherMap REST API using `QNetworkAccessManager` |
| **5-Day Forecast** | Shows high/low temp, emoji, and description for each upcoming day |
| **Dynamic Background** | Background gradient shifts colors based on weather condition (sunny, rainy, stormy, snowy, night, etc.) |
| **Weather Emojis** | Maps OpenWeatherMap icon codes to matching emojis ☀️🌧️⛈️❄️🌫️ |
| **Detail Stats** | Humidity, Wind Speed, Pressure, and Visibility in a responsive grid |
| **Sunrise & Sunset** | Local time of sunrise and sunset, timezone-corrected |
| **Error Handling** | User-friendly banners for invalid API key, city not found, or network errors |
| **Refresh Button** | One-click refresh for the last searched city |
| **API Key Input** | Secure password-masked field for your API key — stored in memory only |

---

## 🏗️ Architecture

```
weather-app/
├── main.cpp              # App entry, exposes WeatherManager to QML
├── weathermanager.h      # Property declarations, signals, and slot prototypes
├── weathermanager.cpp    # Network calls, JSON parsing, theme logic
├── Main.qml              # UI: search bar, main card, forecast list, gradients
└── CMakeLists.txt        # Qt 6 Quick + Network build config
```

### Design Pattern
- **`WeatherManager`** (C++) owns two `QNetworkAccessManager` instances: one for current weather, one for the forecast.
- **`Main.qml`** binds to exposed `Q_PROPERTY` values — no manual signal connection needed.
- Background gradient colors are computed in C++ and exposed as `bgGradientTop` / `bgGradientBot` strings.

---

## 🔑 Getting an API Key

1. Sign up free at [openweathermap.org](https://openweathermap.org/api)
2. Go to **API Keys** in your account dashboard
3. Copy your key and paste it into the **🔑 API Key** field in the app

> Free tier supports **60 calls/minute** — more than enough for this app.

---

## 🚀 Build & Run

### Prerequisites
- **Qt 6.5+** with `Quick` and `Network` modules
- **CMake 3.16+**
- **MSVC 2022** (Windows) or **GCC/Clang** (Linux/macOS)

### Steps (Qt Creator)
1. Open `CMakeLists.txt` in Qt Creator
2. Select your Desktop Kit (e.g., Desktop Qt 6.8.x MSVC2022 64bit)
3. Click **Configure Project**
4. Press **▶ Run**

### Steps (Command Line)
```bash
cmake -B build -DCMAKE_PREFIX_PATH="C:/Qt/6.x.x/msvc2022_64"
cmake --build build --config Release
./build/Release/appweatherapp.exe
```

---

## 🎨 Weather Themes

| Condition | Gradient |
|---|---|
| ☀️ Sunny Day | Bright blue → deep blue |
| 🌙 Clear Night | Deep navy → indigo |
| ☁️ Cloudy | Slate → charcoal |
| 🌧️ Rain | Ocean blue → dark blue |
| ⛈️ Thunderstorm | Dark navy → near-black |
| ❄️ Snow | Silver-blue → dark slate |
| 🌫️ Fog/Mist | Grey-blue → light steel |

---

## 📄 License

MIT License — free to use and distribute.
