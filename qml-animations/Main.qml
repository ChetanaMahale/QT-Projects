import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtCore

ApplicationWindow {
    id: root
    width: 960
    height: 700
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    title: "QML Animations Sandbox"
    color: "#0d0d0f"

    // ── Palette ────────────────────────────────────────────────────────────────
    readonly property color bgBase:     "#0d0d0f"
    readonly property color bgCard:     "#17171a"
    readonly property color bgPanel:    "#1e1e25"
    readonly property color accent:     "#a78bfa"
    readonly property color accentDark: "#7c3aed"
    readonly property color textPri:    "#f4f4f5"
    readonly property color textSec:    "#71717a"
    readonly property color success:    "#34d399"
    readonly property color danger:     "#f87171"
    readonly property color border:     "#27272d"

    // ── Playground State ───────────────────────────────────────────────────────
    property string activeTab: "easing" // "easing" | "combos" | "states" | "spring"
    property double animationSpeed: animController.speedMultiplier

    // ── Background Canvas ──────────────────────────────────────────────────────
    Canvas {
        id: bgCanvas
        anchors.fill: parent
        z: 0
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var g1 = ctx.createRadialGradient(width * 0.1, height * 0.1, 0, width * 0.1, height * 0.1, 300)
            g1.addColorStop(0, "#1d083e")
            g1.addColorStop(1, "transparent")
            ctx.fillStyle = g1; ctx.fillRect(0, 0, width, height)
            var g2 = ctx.createRadialGradient(width * 0.9, height * 0.85, 0, width * 0.9, height * 0.85, 260)
            g2.addColorStop(0, "#081d3d")
            g2.addColorStop(1, "transparent")
            ctx.fillStyle = g2; ctx.fillRect(0, 0, width, height)
        }
    }

    // ── Main Layout ────────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0
        z: 1

        // Left Playground Area
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 24
            spacing: 20

            // Header & Tabs
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Animation Playground"
                        font.pixelSize: 24
                        font.bold: true
                        color: root.textPri
                    }
                    Text {
                        text: "Interactive sandbox of Qt Quick animations"
                        font.pixelSize: 13
                        color: root.textSec
                    }
                }

                Item { Layout.fillWidth: true }

                // Tabs bar
                Rectangle {
                    height: 40; radius: 10
                    color: root.bgCard
                    border.color: root.border
                    border.width: 1
                    width: tabRow.implicitWidth + 8

                    RowLayout {
                        id: tabRow
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 4

                        TabButton { tabId: "easing"; label: "Easing Curves" }
                        TabButton { tabId: "combos"; label: "Sequences" }
                        TabButton { tabId: "states"; label: "States" }
                        TabButton { tabId: "spring"; label: "Spring Follower" }
                    }
                }
            }

            // Central Area (Switched based on activeTab)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 18
                color: root.bgCard
                border.color: root.border
                border.width: 1
                clip: true

                // subtle inner glow
                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1
                    color: root.accent + "33"
                }

                // ── Tab 1: Easing Curves ──
                Item {
                    id: easingTab
                    anchors.fill: parent
                    visible: root.activeTab === "easing"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 20

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16

                            // Easing curve list
                            ColumnLayout {
                                spacing: 8
                                Text { text: "SELECT EASING CURVE:"; font.pixelSize: 11; font.bold: true; color: root.textSec }
                                Rectangle {
                                    width: 180; height: 260; radius: 10; color: root.bgBase; border.color: root.border
                                    ListView {
                                        id: easingList
                                        anchors.fill: parent; anchors.margins: 6; clip: true; spacing: 4
                                        model: ["Linear", "OutBounce", "OutBack", "InOutElastic", "InOutCubic", "InQuad"]
                                        delegate: Rectangle {
                                            required property string modelData
                                            width: easingList.width; height: 32; radius: 6
                                            color: easingTab.selectedEasing === modelData ? root.accentDark + "33" : "transparent"
                                            border.color: easingTab.selectedEasing === modelData ? root.accent : "transparent"
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData
                                                font.pixelSize: 12
                                                color: easingTab.selectedEasing === modelData ? root.textPri : root.textSec
                                            }
                                            MouseArea {
                                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onClicked: { easingTab.selectedEasing = modelData; easingTab.resetEasingAnimation() }
                                            }
                                        }
                                    }
                                }
                            }

                            // Animation Box Area
                            Rectangle {
                                id: animationBox
                                Layout.fillWidth: true; Layout.fillHeight: true; radius: 12; color: root.bgBase
                                border.color: root.border; clip: true

                                Text {
                                    anchors { top: parent.top; left: parent.left; margins: 12 }
                                    text: "Visualizer"
                                    font.pixelSize: 12; font.bold: true; color: root.textSec
                                }

                                // Moving object (Ball)
                                Rectangle {
                                    id: easingBall
                                    width: 32; height: 32; radius: 16
                                    color: root.accent
                                    x: 40
                                    y: animationBox.height / 2 - 16

                                    // Easing Glow
                                    Rectangle {
                                        anchors.fill: parent; radius: 16; color: root.accent; opacity: 0.4; scale: 1.3
                                        layer.enabled: true
                                        layer.effect: MultiEffect { blurEnabled: true; blur: 0.6; blurMax: 16 }
                                    }

                                    // Path tracer dot generator
                                    Timer {
                                        interval: 30; running: easingAnim.running; repeat: true
                                        onTriggered: {
                                            // Create path dot coordinate marker
                                            pathCanvas.addPoint(easingBall.x + 16, easingBall.y + 16)
                                        }
                                    }
                                }

                                // Canvas to draw path trace
                                Canvas {
                                    id: pathCanvas
                                    anchors.fill: parent
                                    property var points: []
                                    function addPoint(px, py) {
                                        points.push({x: px, y: py})
                                        requestPaint()
                                    }
                                    function clearPoints() {
                                        points = []
                                        requestPaint()
                                    }
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        if (points.length < 2) return
                                        ctx.strokeStyle = root.accent + "55"
                                        ctx.lineWidth = 2
                                        ctx.beginPath()
                                        ctx.moveTo(points[0].x, points[0].y)
                                        for (var i = 1; i < points.length; i++) {
                                            ctx.lineTo(points[i].x, points[i].y)
                                        }
                                        ctx.stroke()
                                    }
                                }

                                NumberAnimation {
                                    id: easingAnim
                                    target: easingBall
                                    property: "x"
                                    from: 40
                                    to: animationBox.width - 72
                                    duration: animController.getCalculatedDuration(1500)
                                    easing.type: {
                                        switch (easingTab.selectedEasing) {
                                        case "OutBounce": return Easing.OutBounce
                                        case "OutBack": return Easing.OutBack
                                        case "InOutElastic": return Easing.InOutElastic
                                        case "InOutCubic": return Easing.InOutCubic
                                        case "InQuad": return Easing.InQuad
                                        default: return Easing.Linear
                                        }
                                    }
                                    onStarted: animController.logAnimationStart("Easing Curve", easingTab.selectedEasing)
                                    onStopped: animController.logAnimationComplete("Easing Curve", easingTab.selectedEasing)
                                }
                            }
                        }

                        // Trigger bar
                        RowLayout {
                            Layout.fillWidth: true; spacing: 12
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                width: 120; height: 38; radius: 8; color: root.accentDark
                                Text { anchors.centerIn: parent; text: "Start Animation"; font.bold: true; color: "white"; font.pixelSize: 12 }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { easingTab.resetEasingAnimation(); easingAnim.start() }
                                }
                            }
                        }
                    }

                    property string selectedEasing: "OutBounce"
                    function resetEasingAnimation() {
                        easingAnim.stop()
                        easingBall.x = 40
                        pathCanvas.clearPoints()
                    }
                }

                // ── Tab 2: Sequential vs Parallel ──
                Item {
                    anchors.fill: parent
                    visible: root.activeTab === "combos"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 20

                        Text {
                            text: "COMPARE SEQUENTIAL VS PARALLEL ANIMATIONS:"
                            font.pixelSize: 11; font.bold: true; color: root.textSec
                        }

                        RowLayout {
                            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 20

                            // Demo Card 1 (Sequential)
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true; radius: 12; color: root.bgBase
                                border.color: root.border; clip: true

                                Text {
                                    anchors { top: parent.top; left: parent.left; margins: 12 }
                                    text: "Sequential (Step-by-Step)"
                                    font.pixelSize: 12; font.bold: true; color: root.textSec
                                }

                                Rectangle {
                                    id: seqCard
                                    width: 70; height: 70; radius: 12; color: root.accent
                                    anchors.centerIn: parent

                                    Text { anchors.centerIn: parent; text: "Seq"; font.bold: true; color: "white" }
                                }

                                SequentialAnimation {
                                    id: seqAnimation
                                    onStarted: animController.logAnimationStart("Sequence", "Translate -> Rotate -> Scale -> Fade")

                                    // 1. Move up
                                    NumberAnimation { target: seqCard; property: "anchors.verticalCenterOffset"; from: 0; to: -60; duration: animController.getCalculatedDuration(400); easing.type: Easing.OutQuad }
                                    // 2. Rotate
                                    NumberAnimation { target: seqCard; property: "rotation"; from: 0; to: 180; duration: animController.getCalculatedDuration(400); easing.type: Easing.OutBack }
                                    // 3. Scale down
                                    NumberAnimation { target: seqCard; property: "scale"; from: 1.0; to: 0.6; duration: animController.getCalculatedDuration(300) }
                                    // 4. Fade out and back
                                    NumberAnimation { target: seqCard; property: "opacity"; from: 1.0; to: 0.2; duration: animController.getCalculatedDuration(300) }
                                    NumberAnimation { target: seqCard; property: "opacity"; to: 1.0; duration: 300 }
                                    // 5. Restore
                                    ParallelAnimation {
                                        NumberAnimation { target: seqCard; property: "anchors.verticalCenterOffset"; to: 0; duration: animController.getCalculatedDuration(400); easing.type: Easing.OutBounce }
                                        NumberAnimation { target: seqCard; property: "rotation"; to: 0; duration: animController.getCalculatedDuration(400) }
                                        NumberAnimation { target: seqCard; property: "scale"; to: 1.0; duration: animController.getCalculatedDuration(400) }
                                    }

                                    onStopped: animController.logAnimationComplete("Sequence", "Completed Sequence")
                                }
                            }

                            // Demo Card 2 (Parallel)
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true; radius: 12; color: root.bgBase
                                border.color: root.border; clip: true

                                Text {
                                    anchors { top: parent.top; left: parent.left; margins: 12 }
                                    text: "Parallel (Simultaneous)"
                                    font.pixelSize: 12; font.bold: true; color: root.textSec
                                }

                                Rectangle {
                                    id: parCard
                                    width: 70; height: 70; radius: 12; color: root.accentDark
                                    anchors.centerIn: parent

                                    Text { anchors.centerIn: parent; text: "Par"; font.bold: true; color: "white" }
                                }

                                SequentialAnimation {
                                    id: parAnimation
                                    onStarted: animController.logAnimationStart("Parallel", "All transforms together")

                                    ParallelAnimation {
                                        NumberAnimation { target: parCard; property: "anchors.verticalCenterOffset"; from: 0; to: -60; duration: animController.getCalculatedDuration(1000); easing.type: Easing.InOutQuad }
                                        NumberAnimation { target: parCard; property: "rotation"; from: 0; to: 360; duration: animController.getCalculatedDuration(1000); easing.type: Easing.OutBack }
                                        NumberAnimation { target: parCard; property: "scale"; from: 1.0; to: 0.5; duration: animController.getCalculatedDuration(1000) }
                                        NumberAnimation { target: parCard; property: "opacity"; from: 1.0; to: 0.3; duration: animController.getCalculatedDuration(1000) }
                                    }
                                    ParallelAnimation {
                                        NumberAnimation { target: parCard; property: "anchors.verticalCenterOffset"; to: 0; duration: animController.getCalculatedDuration(600); easing.type: Easing.OutBounce }
                                        NumberAnimation { target: parCard; property: "rotation"; to: 0; duration: animController.getCalculatedDuration(600) }
                                        NumberAnimation { target: parCard; property: "scale"; to: 1.0; duration: animController.getCalculatedDuration(600) }
                                        NumberAnimation { target: parCard; property: "opacity"; to: 1.0; duration: animController.getCalculatedDuration(600) }
                                    }

                                    onStopped: animController.logAnimationComplete("Parallel", "Completed Parallel")
                                }
                            }
                        }

                        // Play bar
                        RowLayout {
                            Layout.fillWidth: true; spacing: 12
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                width: 120; height: 38; radius: 8; color: root.bgBase; border.color: root.border
                                Text { anchors.centerIn: parent; text: "Play Sequence"; font.bold: true; color: root.textPri; font.pixelSize: 12 }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { seqAnimation.stop(); seqAnimation.start() }
                                }
                            }
                            Rectangle {
                                width: 120; height: 38; radius: 8; color: root.accentDark
                                Text { anchors.centerIn: parent; text: "Play Parallel"; font.bold: true; color: "white"; font.pixelSize: 12 }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: { parAnimation.stop(); parAnimation.start() }
                                }
                            }
                        }
                    }
                }

                // ── Tab 3: State Transitions ──
                Item {
                    anchors.fill: parent
                    visible: root.activeTab === "states"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 16

                        Text {
                            text: "CLICK CARD TO TRANSITION STATES (Normal vs Expanded):"
                            font.pixelSize: 11; font.bold: true; color: root.textSec
                        }

                        Item { Layout.fillHeight: true }

                        // Info Card
                        Rectangle {
                            id: stateCard
                            Layout.alignment: Qt.AlignHCenter
                            width: 280; height: 160; radius: 20
                            color: root.bgBase
                            border.color: root.border
                            border.width: 1
                            state: "normal"

                            // Gradient Fill
                            Rectangle {
                                id: cardGrad
                                anchors.fill: parent; radius: 20
                                color: "#1e1e24"
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 10

                                RowLayout {
                                    spacing: 12
                                    Rectangle {
                                        id: avatar
                                        width: 50; height: 50; radius: 25
                                        color: root.accent
                                        Text { anchors.centerIn: parent; text: "🚀"; font.pixelSize: 22 }
                                    }
                                    ColumnLayout {
                                        spacing: 2
                                        Text { text: "Qt Animator Pro"; font.pixelSize: 15; font.bold: true; color: root.textPri }
                                        Text { text: "Transition Module V1"; font.pixelSize: 12; color: root.textSec }
                                    }
                                }

                                Text {
                                    id: descriptionText
                                    text: "QML states organize layout configurations cleanly. Click this card to expand it and watch position, scale, and color transform smoothly."
                                    font.pixelSize: 12
                                    color: root.textSec
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    opacity: 0.0 // hidden in normal state
                                }

                                Item { Layout.fillHeight: true }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { text: "Status: Standby"; font.pixelSize: 11; color: root.textSec }
                                    Item { Layout.fillWidth: true }
                                    Rectangle {
                                        id: badge
                                        width: 60; height: 20; radius: 6; color: root.border
                                        Text { anchors.centerIn: parent; text: "NORMAL"; font.bold: true; color: root.textSec; font.pixelSize: 9 }
                                    }
                                }
                            }

                            // Definitions of States
                            states: [
                                State {
                                    name: "normal"
                                    PropertyChanges { target: stateCard; width: 280; height: 160 }
                                    PropertyChanges { target: cardGrad; color: "#1a1a20" }
                                    PropertyChanges { target: descriptionText; opacity: 0.0 }
                                    PropertyChanges { target: badge; color: root.border }
                                }  ,
                                State {
                                    name: "expanded"
                                    PropertyChanges { target: stateCard; width: 340; height: 240 }
                                    PropertyChanges { target: cardGrad; color: "#22133f" }
                                    PropertyChanges { target: descriptionText; opacity: 1.0 }
                                    PropertyChanges { target: badge; color: root.accent }
                                }
                            ]

                            // State Transitions
                            transitions: [
                                Transition {
                                    from: "*"; to: "*"
                                    SequentialAnimation {
                                        ScriptAction { script: animController.logAnimationStart("Transition", "State change triggers") }
                                        ParallelAnimation {
                                            NumberAnimation { target: stateCard; properties: "width,height"; duration: animController.getCalculatedDuration(400); easing.type: Easing.OutBack }
                                            ColorAnimation { target: cardGrad; duration: animController.getCalculatedDuration(400) }
                                            NumberAnimation { target: descriptionText; property: "opacity"; duration: animController.getCalculatedDuration(200) }
                                            ColorAnimation { target: badge; duration: animController.getCalculatedDuration(400) }
                                        }
                                        ScriptAction { script: animController.logAnimationComplete("Transition", "State change completed") }
                                    }
                                }
                            ]

                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    stateCard.state = (stateCard.state === "normal" ? "expanded" : "normal")
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                // ── Tab 4: Spring Follower ──
                Item {
                    anchors.fill: parent
                    visible: root.activeTab === "spring"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 12

                        Text {
                            text: "DRAG THE VIOLET DOT AND WATCH THE BLUE GLOW FOLLOW WITH SPRING ELASTICITY:"
                            font.pixelSize: 11; font.bold: true; color: root.textSec
                        }

                        Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true; radius: 12; color: root.bgBase
                            border.color: root.border; clip: true

                            // Spring Ball (Follower)
                            Rectangle {
                                id: followerBall
                                width: 28; height: 28; radius: 14
                                color: "#60a5fa"

                                // Spring Glow
                                Rectangle {
                                    anchors.fill: parent; radius: 14; color: "#60a5fa"; opacity: 0.5; scale: 1.4
                                    layer.enabled: true
                                    layer.effect: MultiEffect { blurEnabled: true; blur: 0.8; blurMax: 16 }
                                }

                                // Spring interpolation logic
                                Behavior on x {
                                    SpringAnimation { spring: 3.5; damping: 0.25; epsilon: 0.25 }
                                }
                                Behavior on y {
                                    SpringAnimation { spring: 3.5; damping: 0.25; epsilon: 0.25 }
                                }
                            }

                            // Lead Ball (Draggable)
                            Rectangle {
                                id: leadBall
                                width: 34; height: 34; radius: 17
                                color: root.accent
                                x: parent.width / 2 - 17
                                y: parent.height / 2 - 17

                                Text { anchors.centerIn: parent; text: "🤝"; font.pixelSize: 14 }

                                MouseArea {
                                    anchors.fill: parent
                                    drag.target: parent
                                    drag.axis: Drag.XAndYAxis
                                    drag.minimumX: 10
                                    drag.maximumX: leadBall.parent ? leadBall.parent.width - 44 : 200
                                    drag.minimumY: 10
                                    drag.maximumY: leadBall.parent ? leadBall.parent.height - 44 : 200
                                    cursorShape: Qt.SizeAllCursor
                                }
                            }

                            // Track follower sync changes
                            Connections {
                                target: leadBall
                                function onXChanged() {
                                    followerBall.x = leadBall.x + 3
                                    followerBall.y = leadBall.y + 3
                                }
                            }
                        }
                    }
                }
            }

            // Bottom Controller Bar (Slider)
            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 12
                color: root.bgCard
                border.color: root.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    Text {
                        text: "ANIMATION SPEED MULTIPLIER:"
                        font.pixelSize: 11; font.bold: true; color: root.textSec
                    }

                    Slider {
                        id: speedSlider
                        Layout.fillWidth: true
                        from: 0.25
                        to: 2.0
                        value: animController.speedMultiplier
                        stepSize: 0.25
                        onMoved: {
                            animController.speedMultiplier = speedSlider.value
                        }
                    }

                    Text {
                        text: speedSlider.value.toFixed(2) + "x"
                        font.pixelSize: 13
                        font.bold: true
                        color: root.accent
                        width: 40
                    }
                }
            }
        }

        // Right Console Sidebar (Events Monitor)
        Rectangle {
            Layout.fillHeight: true
            width: 260
            color: root.bgCard
            border.color: root.border
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                Text {
                    text: "SYSTEM CONSOLE"
                    font.pixelSize: 11
                    font.bold: true
                    color: root.accent
                    font.letterSpacing: 1.2
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.border
                }

                // Log monitor
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: "Active log changes will output below in real-time."
                            font.pixelSize: 11
                            color: root.textSec
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: root.border
                        }

                        // Terminal view list
                        Text {
                            text: animController.lastLog
                            font.family: "Courier New"
                            font.pixelSize: 12
                            color: root.success
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            Behavior on text {
                                SequentialAnimation {
                                    NumberAnimation { target: consoleGlow; property: "opacity"; to: 0.8; duration: 80 }
                                    NumberAnimation { target: consoleGlow; property: "opacity"; to: 0.0; duration: 250 }
                                }
                            }
                        }

                        // Console blink response glow
                        Rectangle {
                            id: consoleGlow
                            Layout.fillWidth: true
                            height: 20
                            color: root.success
                            opacity: 0.0
                            radius: 4
                        }
                    }
                }
            }
        }
    }

    // ── TabButton Helper Component ──
    component TabButton: Rectangle {
        property string tabId: ""
        property string label: ""
        Layout.fillHeight: true
        width: 120
        radius: 7
        color: root.activeTab === tabId ? root.accentDark : "transparent"

        Text {
            anchors.centerIn: parent
            text: parent.label
            font.pixelSize: 12
            font.bold: root.activeTab === parent.tabId
            color: root.activeTab === parent.tabId ? "white" : root.textSec
        }

        MouseArea {
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onClicked: root.activeTab = parent.tabId
        }
    }
}
