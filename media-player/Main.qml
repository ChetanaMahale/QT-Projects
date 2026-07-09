import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtCore

ApplicationWindow {
    id: root
    width: 820
    height: 560
    minimumWidth: 700
    minimumHeight: 480
    visible: true
    title: "Media Player - Showcase"
    color: "#0d0d0f"

    // ── Palette ────────────────────────────────────────────────────────────────
    readonly property color bgBase:     "#0d0d0f"
    readonly property color bgCard:     "#17171a"
    readonly property color bgInput:    "#1e1e24"
    readonly property color accent:     "#a78bfa"
    readonly property color accentDark: "#7c3aed"
    readonly property color textPri:    "#f4f4f5"
    readonly property color textSec:    "#71717a"
    readonly property color border:     "#27272d"

    // ── Background blobs ──────────────────────────────────────────────────────
    Canvas {
        id: bgCanvas
        anchors.fill: parent
        z: 0
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var g1 = ctx.createRadialGradient(80, 100, 0, 80, 100, 260)
            g1.addColorStop(0, "#1f093f")
            g1.addColorStop(1, "transparent")
            ctx.fillStyle = g1; ctx.fillRect(0, 0, width, height)
            var g2 = ctx.createRadialGradient(width - 80, height - 100, 0, width - 80, height - 100, 240)
            g2.addColorStop(0, "#081d44")
            g2.addColorStop(1, "transparent")
            ctx.fillStyle = g2; ctx.fillRect(0, 0, width, height)
        }
    }

    // ── Main Layout ────────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0
        z: 1

        // ── Left Sidebar (Playlist panel) ──────────────────────────────────────
        Rectangle {
            Layout.fillHeight: true
            width: 280
            color: root.bgCard
            border.color: root.border
            border.width: 1

            // Right border line
            Rectangle {
                anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 1
                color: root.border
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16

                Text {
                    text: "PLAYLIST"
                    font.pixelSize: 11
                    font.bold: true
                    color: root.accent
                    font.letterSpacing: 1.5
                }

                // Track list
                ListView {
                    id: playlistView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    model: playerManager.playlist

                    delegate: Rectangle {
                        required property int    index
                        required property string title
                        required property string artist
                        required property string durationText
                        required property string cover
                        width: playlistView.width; height: 50; radius: 10
                        color: playerManager.currentTrackIndex === index ? root.accentDark + "33" : (trackMa.containsMouse ? "#202026" : "transparent")
                        border.color: playerManager.currentTrackIndex === index ? root.accent : "transparent"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 12

                            Text {
                                text: cover
                                font.pixelSize: 20
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true
                                Text {
                                    text: parent.parent.parent.title
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: playerManager.currentTrackIndex === parent.parent.parent.index ? root.textPri : root.textSec
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: parent.parent.parent.artist
                                    font.pixelSize: 11
                                    color: root.textSec
                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                text: durationText
                                font.pixelSize: 11
                                color: root.textSec
                            }
                        }

                        MouseArea {
                            id: trackMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                playerManager.setCurrentTrackIndex(index)
                            }
                        }
                    }
                }
            }
        }

        // ── Right Area (Player Panel) ──────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 32
            spacing: 24

            Item { Layout.fillHeight: true }

            // Vinyl / Album art container
            Rectangle {
                id: coverContainer
                Layout.alignment: Qt.AlignHCenter
                width: 200; height: 200; radius: 100
                color: "#1e1e24"
                border.color: root.border
                border.width: 2

                // Vinyl grooves background
                Rectangle {
                    anchors.fill: parent; radius: 100; color: "black"; border.color: "#111"; border.width: 8
                    opacity: 0.8
                }

                // Dynamic cover display (Emoji representation rotating)
                Text {
                    id: vinylCover
                    anchors.centerIn: parent
                    text: playerManager.currentCover
                    font.pixelSize: 84

                    // Rotation animation
                    RotationAnimation on rotation {
                        id: vinylAnim
                        loops: Animation.Infinite
                        from: 0; to: 360; duration: 8000
                        running: playerManager.isPlaying
                    }
                }

                // Vinyl center pin
                Rectangle {
                    anchors.centerIn: parent
                    width: 20; height: 20; radius: 10; color: root.bgBase
                    border.color: "grey"; border.width: 2
                }

                // Glow when playing
                Rectangle {
                    visible: playerManager.isPlaying
                    anchors.fill: parent; radius: 100; color: root.accent; opacity: 0.15; scale: 1.05
                    z: -1
                    layer.enabled: true
                    layer.effect: MultiEffect { blurEnabled: true; blur: 0.8; blurMax: 32 }
                }
            }

            // Song Info metadata
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: playerManager.currentTitle
                    font.pixelSize: 22
                    font.bold: true
                    color: root.textPri
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: playerManager.currentArtist
                    font.pixelSize: 14
                    color: root.accent
                }
            }

            // Timeline slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Slider {
                    id: timeSlider
                    Layout.fillWidth: true
                    from: 0
                    to: playerManager.currentDuration
                    value: playerManager.playbackPosition

                    // Bind position set on interaction
                    onMoved: {
                        playerManager.playbackPosition = timeSlider.value
                    }

                    background: Rectangle {
                        x: timeSlider.leftPadding
                        y: timeSlider.topPadding + (timeSlider.availableHeight - height) / 2
                        width: timeSlider.availableWidth; height: 4; radius: 2
                        color: root.border
                        Rectangle {
                            width: timeSlider.visualPosition * parent.width; height: parent.height; radius: 2
                            color: root.accent
                        }
                    }

                    handle: Rectangle {
                        x: timeSlider.leftPadding + timeSlider.visualPosition * (timeSlider.availableWidth - width)
                        y: timeSlider.topPadding + (timeSlider.availableHeight - height) / 2
                        width: 14; height: 14; radius: 7
                        color: timeSlider.pressed ? root.accent : root.textPri
                        border.color: root.accentDark; border.width: 1
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: playerManager.formatTime(playerManager.playbackPosition)
                        font.pixelSize: 11; color: root.textSec
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: playerManager.formatTime(playerManager.currentDuration)
                        font.pixelSize: 11; color: root.textSec
                    }
                }
            }

            // Controls buttons row
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                PlayerButton { iconText: "⏮"; onClicked: playerManager.previous() }
                PlayerButton { iconText: "⏹"; onClicked: playerManager.stop() }

                // Play / Pause Circle Button
                Rectangle {
                    width: 58; height: 58; radius: 29
                    color: root.accentDark
                    border.color: root.accent + "88"
                    border.width: 1
                    scale: playMa.pressed ? 0.92 : 1.0
                    Behavior on scale { NumberAnimation { duration: 80 } }

                    Text {
                        anchors.centerIn: parent
                        text: playerManager.isPlaying ? "⏸" : "▶"
                        font.pixelSize: 22
                        color: "white"
                        x: playerManager.isPlaying ? 0 : 2 // Offset play symbol slightly for visual centering
                    }

                    MouseArea {
                        id: playMa
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: playerManager.togglePlay()
                    }
                }

                PlayerButton { iconText: "⏭"; onClicked: playerManager.next() }
            }

            // Volume & Mute control
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12
                width: 240

                // Mute toggle
                Rectangle {
                    width: 32; height: 32; radius: 8
                    color: muteMa.containsMouse ? "#202026" : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: playerManager.isMuted ? "🔇" : (playerManager.volume > 50 ? "🔊" : "🔉")
                        font.pixelSize: 16
                    }
                    MouseArea {
                        id: muteMa
                        anchors.fill: parent
                        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: playerManager.toggleMute()
                    }
                }

                // Volume slider
                Slider {
                    id: volSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: playerManager.isMuted ? 0 : playerManager.volume
                    onMoved: {
                        if (playerManager.isMuted) playerManager.isMuted = false
                        playerManager.volume = volSlider.value
                    }

                    background: Rectangle {
                        x: volSlider.leftPadding
                        y: volSlider.topPadding + (volSlider.availableHeight - height) / 2
                        width: volSlider.availableWidth; height: 4; radius: 2
                        color: root.border
                        Rectangle {
                            width: volSlider.visualPosition * parent.width; height: parent.height; radius: 2
                            color: root.accent
                        }
                    }

                    handle: Rectangle {
                        x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                        y: volSlider.topPadding + (volSlider.availableHeight - height) / 2
                        width: 12; height: 12; radius: 6
                        color: root.textPri
                    }
                }

                Text {
                    text: (playerManager.isMuted ? 0 : playerManager.volume) + "%"
                    font.pixelSize: 11; color: root.textSec; width: 28
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ── PlayerButton inline component ──
    component PlayerButton: Rectangle {
        id: pBtn
        property string iconText: ""
        signal clicked
        width: 42; height: 42; radius: 10
        color: btnMa.pressed ? "#222228" : (btnMa.containsMouse ? "#1c1c20" : "transparent")
        border.color: btnMa.containsMouse ? root.border : "transparent"; border.width: 1

        Behavior on color { ColorAnimation { duration: 100 } }

        Text {
            anchors.centerIn: parent
            text: pBtn.iconText
            font.pixelSize: 18
            color: root.textPri
        }
        MouseArea {
            id: btnMa
            anchors.fill: parent
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: pBtn.clicked()
        }
    }
}
