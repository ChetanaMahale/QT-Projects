import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

ApplicationWindow {
    id: root
    width: 900
    height: 620
    minimumWidth: 780
    minimumHeight: 540
    visible: true
    title: "Weather App"

    // ── Theme ────────────────────────────────────────────────────────────────
    readonly property color textPri:   "#ffffff"
    readonly property color textSec:   "rgba(255,255,255,0.65)"
    readonly property color cardBg:    "rgba(255,255,255,0.10)"
    readonly property color cardBord:  "rgba(255,255,255,0.15)"

    // ── Animated background gradient ─────────────────────────────────────────
    Rectangle {
        id: bgRect
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { id: gs1; position: 0.0; color: weather.hasData ? weather.bgGradientTop : "#1e3a5f"
                Behavior on color { ColorAnimation { duration: 800 } }
            }
            GradientStop { id: gs2; position: 1.0; color: weather.hasData ? weather.bgGradientBot : "#0d1b2a"
                Behavior on color { ColorAnimation { duration: 800 } }
            }
        }
    }

    // ── Decorative blobs ─────────────────────────────────────────────────────
    Rectangle {
        width: 340; height: 340; radius: 170
        x: -80; y: -80
        color: "rgba(255,255,255,0.04)"
        layer.enabled: true
    }
    Rectangle {
        width: 260; height: 260; radius: 130
        x: parent.width - 120; y: parent.height - 120
        color: "rgba(255,255,255,0.04)"
    }

    // ── Main content ─────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 20

        // ── API Key + Search row ─────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // API key input
            Rectangle {
                width: 240; height: 44; radius: 12
                color: cardBg
                border.color: cardBord; border.width: 1

                RowLayout {
                    anchors.fill: parent; anchors.margins: 12; spacing: 8
                    Text { text: "🔑"; font.pixelSize: 14 }
                    TextInput {
                        id: apiKeyInput
                        Layout.fillWidth: true
                        placeholderText: "API Key"
                        color: root.textPri
                        font.pixelSize: 13
                        echoMode: TextInput.Password
                        onTextChanged: weather.apiKey = text
                        Text {
                            anchors.fill: parent
                            text: parent.placeholderText
                            color: "rgba(255,255,255,0.35)"
                            font.pixelSize: 13
                            visible: parent.text.length === 0
                        }
                    }
                }
            }

            // City search
            Rectangle {
                Layout.fillWidth: true; height: 44; radius: 12
                color: cardBg
                border.color: cityInput.activeFocus ? "rgba(255,255,255,0.5)" : cardBord; border.width: 1

                RowLayout {
                    anchors.fill: parent; anchors.margins: 12; spacing: 8
                    Text { text: "🔍"; font.pixelSize: 14 }
                    TextInput {
                        id: cityInput
                        Layout.fillWidth: true
                        placeholderText: "Search city… (e.g. London)"
                        color: root.textPri
                        font.pixelSize: 14
                        onAccepted: weather.fetchWeather(cityInput.text)
                        Text {
                            anchors.fill: parent
                            text: parent.placeholderText
                            color: "rgba(255,255,255,0.35)"
                            font.pixelSize: 14
                            visible: parent.text.length === 0
                        }
                    }
                }
            }

            // Search button
            Rectangle {
                width: 100; height: 44; radius: 12
                color: srchMa.pressed ? "rgba(255,255,255,0.25)" : (srchMa.containsMouse ? "rgba(255,255,255,0.2)" : "rgba(255,255,255,0.12)")
                border.color: cardBord; border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
                Text {
                    anchors.centerIn: parent
                    text: weather.isLoading ? "…" : "Search"
                    color: root.textPri; font.pixelSize: 14; font.bold: true
                }
                MouseArea {
                    id: srchMa
                    anchors.fill: parent
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: weather.fetchWeather(cityInput.text)
                }
            }

            // Refresh button
            Rectangle {
                width: 44; height: 44; radius: 12
                visible: weather.hasData
                color: rfMa.containsMouse ? "rgba(255,255,255,0.2)" : "rgba(255,255,255,0.1)"
                border.color: cardBord; border.width: 1
                Text { anchors.centerIn: parent; text: "↻"; font.pixelSize: 20; color: root.textPri }
                MouseArea {
                    id: rfMa
                    anchors.fill: parent
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: weather.refreshWeather()
                }
            }
        }

        // ── Error banner ─────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true; height: 40; radius: 10
            visible: weather.errorMessage.length > 0
            color: "rgba(220,60,60,0.25)"
            border.color: "rgba(220,60,60,0.5)"; border.width: 1
            RowLayout { anchors.fill: parent; anchors.margins: 12; spacing: 8
                Text { text: "⚠️" }
                Text {
                    Layout.fillWidth: true
                    text: weather.errorMessage
                    color: "#ffaaaa"; font.pixelSize: 13
                    elide: Text.ElideRight
                }
            }
        }

        // ── Loading indicator ────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true; height: 80
            visible: weather.isLoading
            ColumnLayout {
                anchors.centerIn: parent; spacing: 10
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "⏳"
                    font.pixelSize: 32

                    RotationAnimation on rotation {
                        loops: Animation.Infinite; from: 0; to: 360; duration: 2000
                        running: weather.isLoading
                    }
                }
                Text { Layout.alignment: Qt.AlignHCenter; text: "Fetching weather…"; color: root.textSec; font.pixelSize: 14 }
            }
        }

        // ── Main weather panel ───────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true; Layout.fillHeight: true
            spacing: 20
            visible: weather.hasData && !weather.isLoading

            // Left: Main weather card
            Rectangle {
                Layout.fillHeight: true
                width: 300; radius: 20
                color: cardBg
                border.color: cardBord; border.width: 1

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 24; spacing: 16

                    // City + country
                    ColumnLayout { spacing: 4
                        Text {
                            text: weather.cityName + ", " + weather.countryCode
                            font.pixelSize: 20; font.bold: true; color: root.textPri
                        }
                        Text {
                            text: "Updated at " + weather.lastUpdated
                            font.pixelSize: 12; color: root.textSec
                        }
                    }

                    // Big emoji + temperature
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter; spacing: 4

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: weather.weatherEmoji
                            font.pixelSize: 80

                            NumberAnimation on scale {
                                loops: 1; from: 0.5; to: 1.0; duration: 500
                                easing.type: Easing.OutBack
                                running: weather.hasData
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: weather.temperature + "°C"
                            font.pixelSize: 58; font.bold: true; color: root.textPri
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: weather.condition
                            font.pixelSize: 16; color: root.textSec
                        }
                    }

                    // Feels like
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 10
                        color: "rgba(255,255,255,0.07)"
                        RowLayout {
                            anchors.fill: parent; anchors.margins: 12; spacing: 8
                            Text { text: "🌡️"; font.pixelSize: 16 }
                            Text { text: "Feels like"; color: root.textSec; font.pixelSize: 13; Layout.fillWidth: true }
                            Text { text: weather.feelsLike + "°C"; color: root.textPri; font.pixelSize: 14; font.bold: true }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Sunrise / Sunset
                    RowLayout { spacing: 8
                        Rectangle { Layout.fillWidth: true; height: 36; radius: 10; color: "rgba(255,255,255,0.07)"
                            RowLayout { anchors.fill: parent; anchors.margins: 10; spacing: 6
                                Text { text: "🌅"; font.pixelSize: 14 }
                                Text { text: weather.sunriseTime; color: root.textPri; font.pixelSize: 12 }
                            }
                        }
                        Rectangle { Layout.fillWidth: true; height: 36; radius: 10; color: "rgba(255,255,255,0.07)"
                            RowLayout { anchors.fill: parent; anchors.margins: 10; spacing: 6
                                Text { text: "🌇"; font.pixelSize: 14 }
                                Text { text: weather.sunsetTime; color: root.textPri; font.pixelSize: 12 }
                            }
                        }
                    }
                }
            }

            // Right: Details grid + Forecast
            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 16

                // Details stats grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2; rowSpacing: 12; columnSpacing: 12

                    Repeater {
                        model: [
                            { icon: "💧", label: "Humidity",    value: weather.humidity + "%" },
                            { icon: "💨", label: "Wind Speed",  value: weather.windSpeed.toFixed(1) + " m/s" },
                            { icon: "📊", label: "Pressure",    value: weather.pressure + " hPa" },
                            { icon: "👁️", label: "Visibility",  value: weather.visibility + " km" }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true; height: 72; radius: 14
                            color: cardBg; border.color: cardBord; border.width: 1

                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 14; spacing: 6
                                RowLayout { spacing: 8
                                    Text { text: modelData.icon; font.pixelSize: 20 }
                                    Text { text: modelData.label; color: root.textSec; font.pixelSize: 12; Layout.fillWidth: true }
                                }
                                Text {
                                    text: modelData.value
                                    font.pixelSize: 20; font.bold: true; color: root.textPri
                                }
                            }
                        }
                    }
                }

                // 5-day Forecast
                Rectangle {
                    Layout.fillWidth: true; Layout.fillHeight: true; radius: 16
                    color: cardBg; border.color: cardBord; border.width: 1

                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 18; spacing: 12

                        Text { text: "5-Day Forecast"; font.pixelSize: 13; font.bold: true; color: root.textSec; font.letterSpacing: 1 }

                        ListView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            model: weather.forecast
                            orientation: ListView.Vertical
                            spacing: 6
                            clip: true

                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                width: ListView.view.width; height: 44; radius: 10
                                color: index % 2 === 0 ? "rgba(255,255,255,0.04)" : "transparent"

                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 12
                                    Text { text: modelData.dayName; font.pixelSize: 14; font.bold: true; color: root.textPri; width: 36 }
                                    Text { text: modelData.date;    font.pixelSize: 12; color: root.textSec; Layout.fillWidth: true }
                                    Text { text: modelData.emoji;   font.pixelSize: 18 }
                                    Text {
                                        text: modelData.tempHigh + "° / " + modelData.tempLow + "°"
                                        font.pixelSize: 13; color: root.textPri; font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Empty state ──────────────────────────────────────────────────────
        ColumnLayout {
            visible: !weather.hasData && !weather.isLoading && weather.errorMessage.length === 0
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 16

            Item { Layout.fillHeight: true }
            Text { Layout.alignment: Qt.AlignHCenter; text: "⛅"; font.pixelSize: 72 }
            Text { Layout.alignment: Qt.AlignHCenter; text: "Your Weather App"; font.pixelSize: 28; font.bold: true; color: root.textPri }
            Text { Layout.alignment: Qt.AlignHCenter; text: "Enter your OpenWeatherMap API key and search for a city to get started."; color: root.textSec; font.pixelSize: 14; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Get a free API key at openweathermap.org/api"
                color: "rgba(255,255,255,0.4)"; font.pixelSize: 12
            }
            Item { Layout.fillHeight: true }
        }
    }
}
