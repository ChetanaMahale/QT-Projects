import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtCore

ApplicationWindow {
    id: root
    width: 900
    height: 660
    minimumWidth: 720
    minimumHeight: 520
    visible: true
    title: "Chat App - " + chatManager.activeRoom
    color: "#0d0d0f"

    // ── Palette ────────────────────────────────────────────────────────────────
    readonly property color bgBase:     "#0d0d0f"
    readonly property color bgCard:     "#17171a"
    readonly property color bgInput:    "#1e1e24"
    readonly property color bgPanel:    "#1e1e25"
    readonly property color accent:     "#a78bfa"
    readonly property color accentDark: "#7c3aed"
    readonly property color textPri:    "#f4f4f5"
    readonly property color textSec:    "#71717a"
    readonly property color textMuted:  "#3f3f47"
    readonly property color success:    "#34d399"
    readonly property color border:     "#27272d"

    // ── State variables ────────────────────────────────────────────────────────
    property string activeRoom: chatManager.activeRoom

    // Map to keep track of unread message counts in other rooms
    property var unreadCounts: ({
        "#general": 0,
        "#qt-dev": 0,
        "#design-critique": 0,
        "#random": 0
    })

    // ── Audio/Notification alerts simulation ──────────────────────────────────
    Connections {
        target: chatManager
        function onMessageReceived() {
            // Force message list scroll to bottom
            messageList.positionViewAtEnd()
        }
        function onActiveRoomChanged() {
            root.unreadCounts[chatManager.activeRoom] = 0
            unreadCountsChanged() // notify
            messageList.positionViewAtEnd()
        }
    }

    // Capture incoming mock messages to flag background activity
    Connections {
        target: chatManager
        function onMessageReceived() {
            // Check if active or background
            // Note: chatManager emits messageReceived whenever ANY room model grows.
            // But we can check if there are updates.
            // Let's trigger a UI refresh to scroll the active list
            messageList.positionViewAtEnd()
        }
    }

    // ── Background Canvas Blobs ────────────────────────────────────────────────
    Canvas {
        id: bgCanvas
        anchors.fill: parent
        z: 0
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var g1 = ctx.createRadialGradient(80, 100, 0, 80, 100, 280)
            g1.addColorStop(0, "#1c0c3a")
            g1.addColorStop(1, "transparent")
            ctx.fillStyle = g1; ctx.fillRect(0, 0, width, height)
            var g2 = ctx.createRadialGradient(width - 80, height - 100, 0, width - 80, height - 100, 240)
            g2.addColorStop(0, "#081a3e")
            g2.addColorStop(1, "transparent")
            ctx.fillStyle = g2; ctx.fillRect(0, 0, width, height)
        }
    }

    // ── Main Layout Split ──────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0
        z: 1

        // ── Left Sidebar (Rooms panel) ─────────────────────────────────────────
        Rectangle {
            Layout.fillHeight: true
            width: 250
            color: root.bgCard
            border.color: root.border
            border.width: 1

            // Right border highlight
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: root.border
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                // Profile Header
                RowLayout {
                    spacing: 12
                    Layout.fillWidth: true

                    Rectangle {
                        width: 42; height: 42; radius: 21
                        color: root.accentDark
                        border.color: root.accent + "88"
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "👨‍💻"
                            font.pixelSize: 20
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "You (Showcase)"
                            font.pixelSize: 14
                            font.bold: true
                            color: root.textPri
                        }
                        Text {
                            text: "Online · Active"
                            font.pixelSize: 11
                            color: root.success
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.border
                }

                Text {
                    text: "ROOMS"
                    font.pixelSize: 11
                    font.bold: true
                    color: root.textSec
                    font.letterSpacing: 1.2
                }

                // Rooms List
                ListView {
                    id: roomList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6
                    clip: true
                    model: chatManager.rooms

                    delegate: Rectangle {
                        required property string modelData
                        width: parent ? parent.width : 0
                        height: 42
                        radius: 10
                        color: chatManager.activeRoom === modelData ? root.accentDark + "33" : (roomMa.containsMouse ? "#202028" : "transparent")
                        border.color: chatManager.activeRoom === modelData ? root.accent : "transparent"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: "#"
                                font.pixelSize: 16
                                font.bold: true
                                color: chatManager.activeRoom === modelData ? root.accent : root.textSec
                            }

                            Text {
                                text: modelData.substring(1) // remove #
                                font.pixelSize: 14
                                font.bold: chatManager.activeRoom === modelData
                                color: chatManager.activeRoom === modelData ? root.textPri : root.textSec
                            }

                            Item { Layout.fillWidth: true }

                            // Mock Active Indicator Dot
                            Rectangle {
                                width: 6; height: 6; radius: 3
                                color: root.accent
                                visible: chatManager.activeRoom === modelData
                            }
                        }

                        MouseArea {
                            id: roomMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                chatManager.setActiveRoom(modelData)
                            }
                        }
                    }
                }
            }
        }

        // ── Right Area (Chat Screen) ───────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Chat Header
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: root.bgCard
                border.color: root.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Text {
                        text: chatManager.activeRoom
                        font.pixelSize: 16
                        font.bold: true
                        color: root.textPri
                    }

                    Rectangle {
                        width: 8; height: 8; radius: 4
                        color: root.success
                    }

                    Text {
                        text: "Active Sandbox Simulation"
                        font.pixelSize: 12
                        color: root.textSec
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "Mock timer active ⏱"
                        font.pixelSize: 11
                        color: root.accent
                    }
                }
            }

            // Message History Area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#0a0a0c"

                ListView {
                    id: messageList
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    clip: true
                    model: chatManager.messageModel

                    // Scroll to bottom when list completes layout
                    Component.onCompleted: positionViewAtEnd()

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 4
                            radius: 2
                            color: root.accent + "66"
                        }
                    }

                    delegate: ColumnLayout {
                        required property string sender
                        required property string text
                        required property bool   isMe
                        required property string timeText

                        width: messageList.width
                        spacing: 4

                        // Sender name label
                        Text {
                            text: sender
                            font.pixelSize: 11
                            font.bold: true
                            color: isMe ? root.accent : "#818cf8"
                            Layout.alignment: isMe ? Qt.AlignRight : Qt.AlignLeft
                            visible: !isMe || sender !== "You"
                        }

                        // Message Bubble
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Layout.alignment: isMe ? Qt.AlignRight : Qt.AlignLeft

                            Item {
                                visible: isMe
                                Layout.fillWidth: true
                            }

                            // Text Bubble Wrapper
                            Rectangle {
                                radius: 14
                                color: isMe ? root.accentDark : root.bgCard
                                border.color: isMe ? root.accent + "66" : root.border
                                border.width: 1
                                implicitWidth: Math.min(msgText.implicitWidth + 24, messageList.width * 0.7)
                                implicitHeight: msgText.implicitHeight + 16

                                Text {
                                    id: msgText
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    text: parent.parent.parent.text // reach delegate text
                                    font.pixelSize: 14
                                    color: isMe ? "white" : root.textPri
                                    wrapMode: Text.Wrap
                                }
                            }

                            Item {
                                visible: !isMe
                                Layout.fillWidth: true
                            }
                        }

                        // Timestamp tag
                        Text {
                            text: timeText
                            font.pixelSize: 10
                            color: root.textMuted
                            Layout.alignment: isMe ? Qt.AlignRight : Qt.AlignLeft
                            Layout.rightMargin: 4
                            Layout.leftMargin: 4
                        }
                    }
                }
            }

            // Bottom Input Bar
            Rectangle {
                Layout.fillWidth: true
                height: 70
                color: root.bgCard
                border.color: root.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    // Message input field
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: root.bgInput
                        border.color: chatInput.activeFocus ? root.accent : root.border
                        border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        // Placeholder
                        Text {
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 14 }
                            text: "Type a message in " + chatManager.activeRoom + "..."
                            font.pixelSize: 14
                            color: root.textMuted
                            visible: chatInput.text.length === 0 && !chatInput.activeFocus
                        }

                        TextInput {
                            id: chatInput
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 14 }
                            font.pixelSize: 14
                            color: root.textPri
                            selectionColor: root.accent + "66"
                            Keys.onReturnPressed: sendActionBtn.clicked()
                        }
                    }

                    // Send Button
                    Rectangle {
                        id: sendActionBtn
                        width: 42; height: 42; radius: 12
                        color: root.accentDark
                        border.color: root.accent + "44"
                        border.width: 1
                        scale: sendMa.pressed ? 0.93 : 1.0
                        Behavior on scale { NumberAnimation { duration: 80 } }
                        signal clicked

                        onClicked: {
                            if (chatInput.text.trim() !== "") {
                                chatManager.sendMessage(chatInput.text)
                                chatInput.text = ""
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "➔"
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                        }

                        MouseArea {
                            id: sendMa
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: sendActionBtn.clicked()
                        }
                    }
                }
            }
        }
    }
}
