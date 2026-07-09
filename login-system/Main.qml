import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects

ApplicationWindow {
    id: root
    width: 440
    height: 700
    minimumWidth: 400
    minimumHeight: 640
    visible: true
    title: "Login System"
    color: "#0d0d0f"

    // ── Palette ────────────────────────────────────────────────────────────────
    readonly property color bgBase:     "#0d0d0f"
    readonly property color bgCard:     "#17171a"
    readonly property color bgInput:    "#1e1e24"
    readonly property color accent:     "#a78bfa"
    readonly property color accentDark: "#7c3aed"
    readonly property color textPri:    "#f4f4f5"
    readonly property color textSec:    "#71717a"
    readonly property color textMuted:  "#3f3f47"
    readonly property color success:    "#34d399"
    readonly property color danger:     "#f87171"
    readonly property color border:     "#27272d"

    // ── State variables ────────────────────────────────────────────────────────
    property string activeView:  "login" // "login" | "register" | "dashboard"
    property string toastMsg:    ""
    property bool   toastIsErr:  true

    // ── Connections to AuthManager ─────────────────────────────────────────────
    Connections {
        target: authManager

        function onLoginSuccess(username) {
            showToast("Welcome back, " + username + "!", false)
            root.activeView = "dashboard"
            regUserVal.text = ""
            regEmailVal.text = ""
            regPassVal.text = ""
            loginUserVal.text = ""
            loginPassVal.text = ""
        }

        function onLoginError(message) {
            showToast(message, true)
        }

        function onRegistrationSuccess() {
            showToast("Registration successful! You can now log in.", false)
            root.activeView = "login"
            regUserVal.text = ""
            regEmailVal.text = ""
            regPassVal.text = ""
        }

        function onRegistrationError(message) {
            showToast(message, true)
        }
    }

    // Helper to trigger toast
    function showToast(msg, isErr) {
        root.toastMsg = msg
        root.toastIsErr = isErr
        toastTimer.restart()
    }

    // ── Background blobs ──────────────────────────────────────────────────────
    Canvas {
        id: bgCanvas
        anchors.fill: parent
        z: 0
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var g1 = ctx.createRadialGradient(width * 0.1, height * 0.15, 0, width * 0.1, height * 0.15, 260)
            g1.addColorStop(0, "#221144")
            g1.addColorStop(1, "transparent")
            ctx.fillStyle = g1; ctx.fillRect(0, 0, width, height)
            var g2 = ctx.createRadialGradient(width * 0.9, height * 0.8, 0, width * 0.9, height * 0.8, 240)
            g2.addColorStop(0, "#0a2244")
            g2.addColorStop(1, "transparent")
            ctx.fillStyle = g2; ctx.fillRect(0, 0, width, height)
        }
    }

    // ── Main UI Stack ──────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent
        anchors.margins: 24
        z: 1

        // ── View 1: Login Form ──────────────────────────────────────────────────
        ColumnLayout {
            id: loginView
            anchors.fill: parent
            spacing: 16
            visible: root.activeView === "login"

            Item { Layout.fillHeight: true }

            // Logo & Header
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 60; height: 60; radius: 18
                    color: root.accentDark
                    border.color: root.accent + "88"
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "🔐"
                        font.pixelSize: 28
                    }
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Sign In"
                    font.pixelSize: 26
                    font.bold: true
                    color: root.textPri
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Access your account dashboard"
                    font.pixelSize: 13
                    color: root.textSec
                }
            }

            Item { height: 12 }

            // Input Fields
            ColumnLayout {
                spacing: 12
                Layout.fillWidth: true

                // Username / Email input
                CustomInput {
                    id: loginUserVal
                    label: "Username or Email"
                    placeholder: "Enter admin or registered email"
                }

                // Password input
                CustomInput {
                    id: loginPassVal
                    label: "Password"
                    placeholder: "••••••••"
                    isPassword: true
                }
            }

            Item { height: 4 }

            // Submit Button
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 12
                color: root.accentDark
                border.color: root.accent + "44"
                border.width: 1
                scale: loginMa.pressed ? 0.97 : 1.0
                Behavior on scale { NumberAnimation { duration: 80 } }

                Text {
                    anchors.centerIn: parent
                    text: "Log In"
                    font.pixelSize: 15
                    font.bold: true
                    color: "white"
                }
                MouseArea {
                    id: loginMa
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        authManager.login(loginUserVal.text, loginPassVal.text)
                    }
                }
            }

            // Toggle view link
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4
                Text {
                    text: "Don't have an account?"
                    font.pixelSize: 13
                    color: root.textSec
                }
                Text {
                    text: "Register"
                    font.pixelSize: 13
                    font.bold: true
                    color: root.accent
                    font.underline: regLinkMa.containsMouse
                    MouseArea {
                        id: regLinkMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.activeView = "register"
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }

        // ── View 2: Register Form ───────────────────────────────────────────────
        ColumnLayout {
            id: registerView
            anchors.fill: parent
            spacing: 14
            visible: root.activeView === "register"

            Item { Layout.fillHeight: true }

            // Header
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Create Account"
                    font.pixelSize: 26
                    font.bold: true
                    color: root.textPri
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Join us and showcase your Qt apps"
                    font.pixelSize: 13
                    color: root.textSec
                }
            }

            Item { height: 8 }

            // Input Fields
            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true

                CustomInput {
                    id: regUserVal
                    label: "Username"
                    placeholder: "Min 3 characters"
                }

                CustomInput {
                    id: regEmailVal
                    label: "Email"
                    placeholder: "you@example.com"
                }

                CustomInput {
                    id: regPassVal
                    label: "Password"
                    placeholder: "••••••••"
                    isPassword: true
                    onTextChanged: {
                        passStrength.strength = authManager.checkPasswordStrength(regPassVal.text)
                    }
                }

                // Password strength indicator
                ColumnLayout {
                    id: passStrength
                    property int strength: 0 // 0=weak, 1=medium, 2=strong
                    Layout.fillWidth: true
                    spacing: 4
                    visible: regPassVal.text.length > 0

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Password Strength:"
                            font.pixelSize: 11
                            color: root.textSec
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: passStrength.strength === 2 ? "Strong" : (passStrength.strength === 1 ? "Medium" : "Weak")
                            font.pixelSize: 11
                            font.bold: true
                            color: passStrength.strength === 2 ? root.success : (passStrength.strength === 1 ? "#fbbf24" : root.danger)
                        }
                    }

                    // Strength bars
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        height: 4

                        Repeater {
                            model: 3
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 2
                                color: {
                                    if (index <= passStrength.strength) {
                                        return passStrength.strength === 2 ? root.success : (passStrength.strength === 1 ? "#fbbf24" : root.danger)
                                    }
                                    return root.border
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 4 }

            // Submit Button
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 12
                color: root.accentDark
                border.color: root.accent + "44"
                border.width: 1
                scale: registerBtnMa.pressed ? 0.97 : 1.0
                Behavior on scale { NumberAnimation { duration: 80 } }

                Text {
                    anchors.centerIn: parent
                    text: "Register"
                    font.pixelSize: 15
                    font.bold: true
                    color: "white"
                }
                MouseArea {
                    id: registerBtnMa
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        authManager.registerUser(regUserVal.text, regEmailVal.text, regPassVal.text)
                    }
                }
            }

            // Toggle view link
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4
                Text {
                    text: "Already have an account?"
                    font.pixelSize: 13
                    color: root.textSec
                }
                Text {
                    text: "Login"
                    font.pixelSize: 13
                    font.bold: true
                    color: root.accent
                    font.underline: logLinkMa.containsMouse
                    MouseArea {
                        id: logLinkMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.activeView = "login"
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }

        // ── View 3: Dashboard Dashboard ─────────────────────────────────────────
        ColumnLayout {
            id: dashboardView
            anchors.fill: parent
            spacing: 20
            visible: root.activeView === "dashboard"

            Item { Layout.fillHeight: true }

            // Success circle
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 100; height: 100; radius: 50
                color: root.success + "22"
                border.color: root.success
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 42
                    font.bold: true
                    color: root.success
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Success!"
                    font.pixelSize: 28
                    font.bold: true
                    color: root.textPri
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "You are successfully authenticated."
                    font.pixelSize: 13
                    color: root.textSec
                }
            }

            // Info Card
            Rectangle {
                Layout.fillWidth: true
                height: 120
                radius: 16
                color: root.bgCard
                border.color: root.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Username"
                            font.pixelSize: 13
                            color: root.textSec
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: authManager.currentUser
                            font.pixelSize: 14
                            font.bold: true
                            color: root.textPri
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.border
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Session Status"
                            font.pixelSize: 13
                            color: root.textSec
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Active"
                            font.pixelSize: 13
                            font.bold: true
                            color: root.success
                        }
                    }
                }
            }

            // Logout Button
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 12
                color: "transparent"
                border.color: root.danger + "88"
                border.width: 1
                scale: logoutMa.pressed ? 0.97 : 1.0
                Behavior on scale { NumberAnimation { duration: 80 } }

                Text {
                    anchors.centerIn: parent
                    text: "Sign Out"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.danger
                }
                MouseArea {
                    id: logoutMa
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        authManager.logout()
                        root.activeView = "login"
                        showToast("Logged out successfully.", false)
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ── Toast Banner ──────────────────────────────────────────────────────────
    Rectangle {
        id: toastBanner
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 16 }
        height: 54
        radius: 12
        color: root.toastIsErr ? root.danger + "ee" : root.accentDark + "ee"
        visible: opacity > 0.01
        opacity: 0.0

        Behavior on opacity { NumberAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Text {
                text: root.toastIsErr ? "⚠️" : "✨"
                font.pixelSize: 16
            }
            Text {
                Layout.fillWidth: true
                text: root.toastMsg
                font.pixelSize: 13
                font.bold: true
                color: "white"
                elide: Text.ElideRight
            }
        }
    }

    Timer {
        id: toastTimer
        interval: 3000
        onTriggered: toastBanner.opacity = 0.0
        onRunningChanged: {
            if (running) toastBanner.opacity = 1.0
        }
    }

    // ── Custom Input Component (Inline) ────────────────────────────────────────
    component CustomInput: ColumnLayout {
        id: inputRoot
        property string label: ""
        property string placeholder: ""
        property bool   isPassword: false
        property alias  text: mainInput.text

        spacing: 6
        Layout.fillWidth: true

        Text {
            text: inputRoot.label
            font.pixelSize: 13
            font.bold: true
            color: root.textSec
        }

        Rectangle {
            Layout.fillWidth: true
            height: 46
            radius: 10
            color: root.bgInput
            border.color: mainInput.activeFocus ? root.accent : root.border
            border.width: 1
            Behavior on border.color { ColorAnimation { duration: 120 } }

            // Manual placeholder text
            Text {
                anchors { left: parent.left; right: parent.right
                          verticalCenter: parent.verticalCenter; margins: 14 }
                text: inputRoot.placeholder
                font.pixelSize: 14
                color: root.textMuted
                visible: mainInput.text.length === 0 && !mainInput.activeFocus
            }

            TextInput {
                id: mainInput
                anchors { left: parent.left; right: parent.right
                          verticalCenter: parent.verticalCenter; margins: 14 }
                font.pixelSize: 14
                color: root.textPri
                echoMode: inputRoot.isPassword ? TextInput.Password : TextInput.Normal
                selectionColor: root.accent + "66"
            }
        }
    }
}
