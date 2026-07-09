import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects

ApplicationWindow {
    id: root
    width: 400
    height: 700
    minimumWidth: 360
    minimumHeight: 600
    maximumWidth: 480
    maximumHeight: 860
    visible: true
    title: "Calculator"
    color: "#0d0d0f"

    // ── palette ────────────────────────────────────────────────────────────
    readonly property color bgBase:      "#0d0d0f"
    readonly property color bgCard:      "#17171a"
    readonly property color bgPanel:     "#1e1e23"
    readonly property color accent:      "#a78bfa"
    readonly property color accentGlow:  "#7c3aed"
    readonly property color opColor:     "#c084fc"
    readonly property color eqColor:     "#a78bfa"
    readonly property color textPri:     "#f4f4f5"
    readonly property color textSec:     "#a1a1aa"
    readonly property color btnNum:      "#27272d"
    readonly property color btnNumHov:   "#32323a"
    readonly property color btnFunc:     "#1e1e27"
    readonly property color btnFuncHov:  "#2a2a35"
    readonly property color errorColor:  "#f87171"

    // keyboard shortcut handler
    Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: (event) => {
            const k = event.key
            const t = event.text
            if (t >= '0' && t <= '9') { calc.inputDigit(t); return }
            if (t === '.') { calc.inputDecimal(); return }
            if (t === '+') { calc.inputOperator("+"); return }
            if (t === '-') { calc.inputOperator("−"); return }
            if (t === '*') { calc.inputOperator("×"); return }
            if (t === '/') { calc.inputOperator("÷"); event.accepted = true; return }
            if (t === '%') { calc.percentage(); return }
            if (k === Qt.Key_Return || k === Qt.Key_Enter || t === '=') { calc.calculate(); return }
            if (k === Qt.Key_Backspace) { calc.backspace(); return }
            if (k === Qt.Key_Escape || t === 'c' || t === 'C') { calc.clearAll(); return }
        }
    }

    // ── background gradient blobs ──────────────────────────────────────────
    Canvas {
        id: bgCanvas
        anchors.fill: parent
        Component.onCompleted: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            // blob 1 – top-left purple
            var g1 = ctx.createRadialGradient(80, 120, 0, 80, 120, 220)
            g1.addColorStop(0, "#1e0a40")
            g1.addColorStop(1, "transparent")
            ctx.fillStyle = g1
            ctx.fillRect(0, 0, width, height)
            // blob 2 – bottom-right blue
            var g2 = ctx.createRadialGradient(width - 60, height - 100, 0, width - 60, height - 100, 200)
            g2.addColorStop(0, "#0a1540")
            g2.addColorStop(1, "transparent")
            ctx.fillStyle = g2
            ctx.fillRect(0, 0, width, height)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ── header ────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Calc"
                font.pixelSize: 20
                font.bold: true
                color: root.accent
                font.letterSpacing: 1.5
            }
            Item { Layout.fillWidth: true }
            // history toggle
            Rectangle {
                width: 36; height: 36; radius: 10
                color: historyPanel.visible ? root.accent + "33" : root.bgPanel
                border.color: historyPanel.visible ? root.accent : "#2e2e38"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "⏱"
                    font.pixelSize: 16
                    color: historyPanel.visible ? root.accent : root.textSec
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: historyPanel.visible = !historyPanel.visible
                }
            }
        }

        // ── display card ──────────────────────────────────────────────────
        Rectangle {
            id: displayCard
            Layout.fillWidth: true
            height: 170
            radius: 24
            color: root.bgCard
            border.color: "#2a2a35"
            border.width: 1

            // subtle inner glow on top edge
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: root.accent + "55"
                radius: 24
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 4

                // expression line
                Text {
                    id: exprText
                    Layout.fillWidth: true
                    text: calc.expressionText
                    font.pixelSize: 15
                    color: root.textSec
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideLeft
                    Behavior on text { animation: SequentialAnimation {
                        NumberAnimation { target: exprText; property: "opacity"; to: 0.4; duration: 80 }
                        NumberAnimation { target: exprText; property: "opacity"; to: 1.0; duration: 80 }
                    }}
                }

                Item { Layout.fillHeight: true }

                // main display
                Text {
                    id: mainDisplay
                    Layout.fillWidth: true
                    text: calc.displayText
                    font.pixelSize: calc.displayText.length > 12 ? 32 : calc.displayText.length > 9 ? 42 : 56
                    font.bold: true
                    color: calc.hasError ? root.errorColor : root.textPri
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideLeft

                    Behavior on font.pixelSize {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }

                    // result pop animation
                    NumberAnimation on scale {
                        id: resultAnim
                        from: 1.05; to: 1.0
                        duration: 250
                        easing.type: Easing.OutBack
                        running: false
                    }
                }

                Connections {
                    target: engine
                    function onAnimateResult() { resultAnim.running = true }
                }
            }
        }

        // ── history panel (collapsible) ────────────────────────────────────
        Rectangle {
            id: historyPanel
            Layout.fillWidth: true
            height: 130
            radius: 18
            color: root.bgCard
            border.color: "#2a2a35"
            border.width: 1
            visible: false
            clip: true

            Behavior on visible {
                PropertyAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Text {
                    text: "History"
                    font.pixelSize: 12
                    font.bold: true
                    color: root.accent
                    font.letterSpacing: 1
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: calc.history
                    clip: true
                    spacing: 2

                    delegate: Text {
                        width: parent ? parent.width : 0
                        text: modelData
                        font.pixelSize: 12
                        color: root.textSec
                        elide: Text.ElideLeft
                        horizontalAlignment: Text.AlignRight
                    }

                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                }
            }
        }

        // ── button grid ───────────────────────────────────────────────────
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            rowSpacing: 10
            columnSpacing: 10

            // Row 1: AC  +/-  %  ÷
            CalcButton { label: "AC";  wide: false; btnType: "func";  onTapped: calc.clearAll() }
            CalcButton { label: "+/−"; wide: false; btnType: "func";  onTapped: calc.toggleSign() }
            CalcButton { label: "%";   wide: false; btnType: "func";  onTapped: calc.percentage() }
            CalcButton { label: "÷";   wide: false; btnType: "op";    onTapped: calc.inputOperator("÷") }

            // Row 2: 7  8  9  ×
            CalcButton { label: "7";  wide: false; btnType: "num"; onTapped: calc.inputDigit("7") }
            CalcButton { label: "8";  wide: false; btnType: "num"; onTapped: calc.inputDigit("8") }
            CalcButton { label: "9";  wide: false; btnType: "num"; onTapped: calc.inputDigit("9") }
            CalcButton { label: "×";  wide: false; btnType: "op";  onTapped: calc.inputOperator("×") }

            // Row 3: 4  5  6  −
            CalcButton { label: "4";  wide: false; btnType: "num"; onTapped: calc.inputDigit("4") }
            CalcButton { label: "5";  wide: false; btnType: "num"; onTapped: calc.inputDigit("5") }
            CalcButton { label: "6";  wide: false; btnType: "num"; onTapped: calc.inputDigit("6") }
            CalcButton { label: "−";  wide: false; btnType: "op";  onTapped: calc.inputOperator("−") }

            // Row 4: 1  2  3  +
            CalcButton { label: "1";  wide: false; btnType: "num"; onTapped: calc.inputDigit("1") }
            CalcButton { label: "2";  wide: false; btnType: "num"; onTapped: calc.inputDigit("2") }
            CalcButton { label: "3";  wide: false; btnType: "num"; onTapped: calc.inputDigit("3") }
            CalcButton { label: "+";  wide: false; btnType: "op";  onTapped: calc.inputOperator("+") }

            // Row 5: 0(wide)  .  =
            CalcButton { label: "0";  wide: true;  btnType: "num"; onTapped: calc.inputDigit("0");
                         Layout.columnSpan: 2; Layout.fillWidth: true }
            CalcButton { label: ".";  wide: false; btnType: "num"; onTapped: calc.inputDecimal() }
            CalcButton { label: "=";  wide: false; btnType: "eq";  onTapped: calc.calculate() }
        }

        // ── extra functions row ────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            CalcButton {
                label: "√x"; wide: false; btnType: "func"
                Layout.fillWidth: true
                onTapped: calc.inputSpecial("sqrt")
            }
            CalcButton {
                label: "x²"; wide: false; btnType: "func"
                Layout.fillWidth: true
                onTapped: calc.inputSpecial("sq")
            }
            CalcButton {
                label: "1/x"; wide: false; btnType: "func"
                Layout.fillWidth: true
                onTapped: calc.inputSpecial("inv")
            }
            CalcButton {
                label: "⌫"; wide: false; btnType: "func"
                Layout.fillWidth: true
                onTapped: calc.backspace()
            }
        }

        // bottom padding
        Item { height: 4 }
    }

    // ── CalcButton component (inline) ──────────────────────────────────────
    component CalcButton: Rectangle {
        id: btn
        property string label: ""
        property bool wide: false
        property string btnType: "num"  // num | op | eq | func
        signal tapped

        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: 70
        radius: 18

        // colours by type
        readonly property color baseBg: {
            switch(btnType) {
            case "op":   return "#2a1f40"
            case "eq":   return root.accentGlow
            case "func": return root.btnFunc
            default:     return root.btnNum
            }
        }
        readonly property color hoverBg: {
            switch(btnType) {
            case "op":   return "#3a2855"
            case "eq":   return "#8b5cf6"
            case "func": return root.btnFuncHov
            default:     return root.btnNumHov
            }
        }
        readonly property color pressBg: {
            switch(btnType) {
            case "op":   return "#4a3468"
            case "eq":   return "#7c3aed"
            case "func": return "#35353e"
            default:     return "#3d3d48"
            }
        }
        readonly property color labelColor: {
            switch(btnType) {
            case "op":   return root.opColor
            case "eq":   return "#ffffff"
            case "func": return root.textSec
            default:     return root.textPri
            }
        }

        color: ma.pressed ? pressBg : (ma.containsMouse ? hoverBg : baseBg)

        border.color: btnType === "eq" ? "#9f6fe8" : btnType === "op" ? "#4a2a7a" : "#2e2e3a"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 100 } }

        // top highlight stripe
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: btnType === "eq" ? "#bf9ef8" : "#3a3a48"
            radius: 18
        }

        // glow under eq button
        Rectangle {
            visible: btnType === "eq"
            anchors.centerIn: parent
            width: parent.width * 0.6
            height: parent.height * 0.4
            color: root.accentGlow + "44"
            radius: 20
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1.0
                blurMax: 32
            }
        }

        Text {
            anchors.centerIn: parent
            text: btn.label
            font.pixelSize: btn.label.length > 2 ? 18 : 24
            font.bold: btnType === "eq" || btnType === "op"
            color: btn.labelColor
            Behavior on color { ColorAnimation { duration: 100 } }
        }

        // scale press animation
        scale: ma.pressed ? 0.93 : 1.0
        Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutBack } }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.tapped()
        }
    }
}
