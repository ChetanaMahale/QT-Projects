import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import "components"

ApplicationWindow {
    id: root
    width:       1100
    height:      700
    minimumWidth: 900
    minimumHeight: 600
    visible: true
    title: "Expense Tracker"

    // ── Theme tokens ─────────────────────────────────────────────────────────
    readonly property color bg:       "#11111b"
    readonly property color surface:  "#1e1e2e"
    readonly property color surface2: "#181825"
    readonly property color border:   Qt.rgba(1,1,1,0.09)
    readonly property color textPri:  "#cdd6f4"
    readonly property color textSec:  "#a6adc8"
    readonly property color textMut:  "#585b70"
    readonly property color accentB:  "#89b4fa"
    readonly property color accentG:  "#1DD1A1"
    readonly property color accentR:  "#FF6B6B"

    // ── Background ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: root.bg

        Rectangle {
            width: 500; height: 500; radius: 250
            x: -180; y: -180
            color: Qt.rgba(0.537, 0.706, 0.980, 0.04)
        }
        Rectangle {
            width: 400; height: 400; radius: 200
            x: parent.width - 200; y: parent.height - 200
            color: Qt.rgba(0.114, 0.820, 0.631, 0.04)
        }
    }

    // ── Error connection ──────────────────────────────────────────────────────
    Connections {
        target: expense
        function onErrorOccurred(msg) {
            toastText.text = msg
            toastTimer.restart()
        }
    }

    // ── Layout: Sidebar + Main ────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ══ LEFT SIDEBAR ══════════════════════════════════════════════════════
        Rectangle {
            Layout.fillHeight: true
            width: 230
            color: root.surface2

            Rectangle {
                anchors.right:  parent.right
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: root.border
            }

            ColumnLayout {
                anchors.fill:    parent
                anchors.margins: 20
                spacing:         4

                // ── Logo ─────────────────────────────────────────────────────
                RowLayout {
                    spacing: 10
                    Rectangle {
                        width: 38; height: 38; radius: 12
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#89b4fa" }
                            GradientStop { position: 1.0; color: "#1DD1A1" }
                        }
                        Text { anchors.centerIn: parent; text: "💰"; font.pixelSize: 20 }
                    }
                    ColumnLayout {
                        spacing: 1
                        Text { text: "Expense"; color: root.textPri; font.pixelSize: 14; font.bold: true }
                        Text { text: "Tracker"; color: root.textSec; font.pixelSize: 11 }
                    }
                }

                Item { height: 18 }

                // ── Nav items ────────────────────────────────────────────────
                Repeater {
                    model: [
                        { icon: "📊", label: "Dashboard",    page: 0 },
                        { icon: "📋", label: "Transactions", page: 1 },
                        { icon: "🍩", label: "Analytics",    page: 2 }
                    ]
                    delegate: Rectangle {
                        required property var  modelData
                        Layout.fillWidth: true
                        height: 42
                        radius: 10
                        color: stack.currentIndex === modelData.page
                               ? Qt.rgba(0.537, 0.706, 0.980, 0.15)
                               : (navMa.containsMouse ? Qt.rgba(1,1,1,0.05) : "transparent")
                        border.color: stack.currentIndex === modelData.page ? root.accentB : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill:        parent
                            anchors.margins:     12
                            spacing:             10
                            Text { text: modelData.icon; font.pixelSize: 16 }
                            Text {
                                text: modelData.label
                                Layout.fillWidth: true
                                color: stack.currentIndex === modelData.page ? root.accentB : root.textSec
                                font.pixelSize: 13
                                font.bold: stack.currentIndex === modelData.page
                            }
                        }
                        MouseArea {
                            id: navMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: stack.currentIndex = modelData.page
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // ── Balance summary ──────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    radius: 14
                    color: Qt.rgba(1,1,1,0.04)
                    border.color: root.border
                    border.width: 1

                    ColumnLayout {
                        anchors.fill:    parent
                        anchors.margins: 14
                        spacing:         4
                        Text { text: "Net Balance"; color: root.textMut; font.pixelSize: 11 }
                        Text {
                            text: (expense.balance >= 0 ? "+" : "") + "₹" +
                                  expense.balance.toLocaleString(Qt.locale(), 'f', 2)
                            color: expense.balance >= 0 ? root.accentG : root.accentR
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Text { text: "All time"; color: root.textMut; font.pixelSize: 10 }
                    }
                }

                Item { height: 8 }

                // ── Add Expense button ────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 10
                    color: addExpMa.pressed
                           ? Qt.darker("#89b4fa", 1.2)
                           : (addExpMa.containsMouse ? Qt.lighter("#89b4fa", 1.05) : "#89b4fa")
                    Behavior on color { ColorAnimation { duration: 100 } }
                    RowLayout {
                        anchors.fill:    parent
                        anchors.margins: 10
                        spacing: 6
                        Text { text: "➖"; font.pixelSize: 13 }
                        Text { text: "Add Expense"; color: "#11111b"; font.pixelSize: 13; font.bold: true; Layout.fillWidth: true }
                    }
                    MouseArea {
                        id: addExpMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            dialog.isIncome = false
                            dialog.reset()
                            dialog.visible = true
                        }
                    }
                }

                // ── Add Income button ─────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 10
                    color: addIncMa.pressed
                           ? Qt.darker("#1DD1A1", 1.2)
                           : (addIncMa.containsMouse ? Qt.lighter("#1DD1A1", 1.05) : "#1DD1A1")
                    Behavior on color { ColorAnimation { duration: 100 } }
                    RowLayout {
                        anchors.fill:    parent
                        anchors.margins: 10
                        spacing: 6
                        Text { text: "➕"; font.pixelSize: 13 }
                        Text { text: "Add Income"; color: "#11111b"; font.pixelSize: 13; font.bold: true; Layout.fillWidth: true }
                    }
                    MouseArea {
                        id: addIncMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                            dialog.isIncome = true
                            dialog.reset()
                            dialog.visible = true
                        }
                    }
                }

                Item { height: 4 }
            }
        }

        // ══ MAIN CONTENT ══════════════════════════════════════════════════════
        StackLayout {
            id: stack
            Layout.fillWidth:  true
            Layout.fillHeight: true
            currentIndex: 0

            // ── PAGE 0 : Dashboard ────────────────────────────────────────────
            Item {
                ColumnLayout {
                    anchors.fill:    parent
                    anchors.margins: 28
                    spacing:         20

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            spacing: 3
                            Text { text: "Dashboard"; color: root.textPri; font.pixelSize: 24; font.bold: true }
                            Text {
                                text: Qt.formatDate(new Date(), "dddd, MMMM d yyyy")
                                color: root.textSec
                                font.pixelSize: 13
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            width: 38; height: 38; radius: 10
                            color: refMa.containsMouse ? Qt.rgba(1,1,1,0.10) : Qt.rgba(1,1,1,0.05)
                            border.color: root.border
                            border.width: 1
                            Text { anchors.centerIn: parent; text: "↻"; color: root.textSec; font.pixelSize: 18 }
                            MouseArea {
                                id: refMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: expense.refresh()
                            }
                        }
                    }

                    // Stat cards row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14

                        StatCard {
                            Layout.fillWidth: true
                            emoji: "💸"; label: "TOTAL EXPENSES"
                            value: "₹" + expense.totalExpenses.toLocaleString(Qt.locale(), 'f', 2)
                            accent: root.accentR
                        }
                        StatCard {
                            Layout.fillWidth: true
                            emoji: "📥"; label: "TOTAL INCOME"
                            value: "₹" + expense.totalIncome.toLocaleString(Qt.locale(), 'f', 2)
                            accent: root.accentG
                        }
                        StatCard {
                            Layout.fillWidth: true
                            emoji: "📅"; label: "THIS MONTH (EXP)"
                            value: "₹" + expense.monthlyExpenses.toLocaleString(Qt.locale(), 'f', 2)
                            accent: "#FECA57"
                        }
                        StatCard {
                            Layout.fillWidth: true
                            emoji: "📅"; label: "THIS MONTH (INC)"
                            value: "₹" + expense.monthlyIncome.toLocaleString(Qt.locale(), 'f', 2)
                            accent: root.accentB
                        }
                    }

                    // Middle row: Donut + Recent
                    RowLayout {
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        spacing: 14

                        // Donut + legend
                        Rectangle {
                            width: 280
                            Layout.fillHeight: true
                            radius: 18
                            color: root.surface
                            border.color: root.border
                            border.width: 1

                            ColumnLayout {
                                anchors.fill:    parent
                                anchors.margins: 20
                                spacing:         14

                                Text { text: "By Category"; color: root.textSec; font.pixelSize: 12; font.bold: true; font.letterSpacing: 1 }

                                DonutChart {
                                    id: donutChart
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 170; height: 170
                                    segments: {
                                        var segs = []
                                        for (var i = 0; i < expense.categoryTotals.length; i++) {
                                            var c = expense.categoryTotals[i]
                                            segs.push({ color: c.color, value: c.total, label: c.category })
                                        }
                                        return segs
                                    }
                                    total: expense.totalExpenses
                                }

                                // Legend
                                ListView {
                                    Layout.fillWidth:  true
                                    Layout.fillHeight: true
                                    model:   expense.categoryTotals
                                    clip:    true
                                    spacing: 5

                                    delegate: RowLayout {
                                        required property var modelData
                                        required property int index
                                        width:   ListView.view.width
                                        spacing: 8

                                        Rectangle {
                                            width: 10; height: 10; radius: 5
                                            color: modelData.color
                                        }
                                        Text {
                                            text: modelData.icon + " " + modelData.category
                                            color: donutChart.hovered === index ? "#fff" : root.textSec
                                            font.pixelSize: 11
                                            Layout.fillWidth: true
                                            Behavior on color { ColorAnimation { duration: 100 } }
                                        }
                                        Text {
                                            text: "₹" + modelData.total.toLocaleString(Qt.locale(), 'f', 0)
                                            color: modelData.color
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: expense.categoryTotals.length === 0
                                        text:    "No expenses yet"
                                        color:   root.textMut
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        // Recent transactions
                        Rectangle {
                            Layout.fillWidth:  true
                            Layout.fillHeight: true
                            radius: 18
                            color:  root.surface
                            border.color: root.border
                            border.width: 1

                            ColumnLayout {
                                anchors.fill:    parent
                                anchors.margins: 20
                                spacing:         10

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "Recent Transactions"
                                        color: root.textSec
                                        font.pixelSize: 12
                                        font.bold: true
                                        font.letterSpacing: 1
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: "See all →"
                                        color: root.accentB
                                        font.pixelSize: 12
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape:  Qt.PointingHandCursor
                                            onClicked: stack.currentIndex = 1
                                        }
                                    }
                                }

                                ListView {
                                    Layout.fillWidth:  true
                                    Layout.fillHeight: true
                                    model:   expense.transactions
                                    clip:    true
                                    spacing: 7

                                    delegate: ExpenseCard {
                                        required property var modelData
                                        width:    ListView.view.width
                                        txId:     modelData.id
                                        emoji:    modelData.icon
                                        title:    modelData.title
                                        category: modelData.category
                                        date:     modelData.date
                                        note:     modelData.note
                                        amount:   modelData.amount
                                        type:     modelData.type
                                        catColor: modelData.color
                                        onDeleteRequested: function(id) { expense.deleteTransaction(id) }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: expense.transactions.length === 0
                                        text:    "No transactions yet.\nClick '+ Add Expense' to get started!"
                                        color:   root.textMut
                                        font.pixelSize: 13
                                        horizontalAlignment: Text.AlignHCenter
                                        lineHeight: 1.6
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── PAGE 1 : Transactions ─────────────────────────────────────────
            Item {
                ColumnLayout {
                    anchors.fill:    parent
                    anchors.margins: 28
                    spacing:         16

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Transactions"; color: root.textPri; font.pixelSize: 24; font.bold: true; Layout.fillWidth: true }
                        Text {
                            text:  expense.transactions.length + " records"
                            color: root.textMut
                            font.pixelSize: 13
                        }
                    }

                    // Filter bar
                    Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: 14
                        color:  root.surface
                        border.color: root.border
                        border.width: 1

                        RowLayout {
                            anchors.fill:    parent
                            anchors.margins: 12
                            spacing:         10

                            // Search
                            Rectangle {
                                Layout.fillWidth: true
                                height: 32
                                radius: 8
                                color:  Qt.rgba(1,1,1,0.05)
                                border.color: searchIn.activeFocus ? root.accentB : Qt.rgba(1,1,1,0.10)
                                border.width: 1
                                RowLayout {
                                    anchors.fill:    parent
                                    anchors.margins: 8
                                    spacing:         6
                                    Text { text: "🔍"; font.pixelSize: 12 }
                                    TextInput {
                                        id: searchIn
                                        Layout.fillWidth: true
                                        color: root.textPri
                                        font.pixelSize: 13
                                        onTextChanged: expense.searchText = text
                                        Text {
                                            anchors.fill: parent
                                            text: "Search…"
                                            color: root.textMut
                                            font.pixelSize: 13
                                            visible: parent.text.length === 0
                                        }
                                    }
                                }
                            }

                            // Type filter chips
                            Repeater {
                                model: [
                                    { lbl: "All",      val: ""        },
                                    { lbl: "Expenses", val: "expense" },
                                    { lbl: "Income",   val: "income"  }
                                ]
                                delegate: Rectangle {
                                    required property var  modelData
                                    property bool sel: expense.filterType === modelData.val
                                    height: 32
                                    width:  chipText.implicitWidth + 20
                                    radius: 8
                                    color:  sel ? Qt.rgba(0.537, 0.706, 0.980, 0.20) : Qt.rgba(1,1,1,0.05)
                                    border.color: sel ? root.accentB : Qt.rgba(1,1,1,0.10)
                                    border.width: 1
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    Text {
                                        id: chipText
                                        anchors.centerIn: parent
                                        text: modelData.lbl
                                        color: sel ? root.accentB : root.textSec
                                        font.pixelSize: 13
                                        font.bold: sel
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape:  Qt.PointingHandCursor
                                        onClicked: expense.filterType = modelData.val
                                    }
                                }
                            }

                            // Clear filter
                            Rectangle {
                                visible: expense.filterType !== "" || expense.searchText !== ""
                                height: 32; width: 32; radius: 8
                                color: clrMa.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent"
                                Text { anchors.centerIn: parent; text: "✕"; color: root.textMut; font.pixelSize: 14 }
                                MouseArea {
                                    id: clrMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape:  Qt.PointingHandCursor
                                    onClicked: {
                                        expense.filterType     = ""
                                        expense.filterCategory = ""
                                        searchIn.text          = ""
                                    }
                                }
                            }
                        }
                    }

                    // Transaction list
                    Rectangle {
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        radius: 16
                        color:  root.surface
                        border.color: root.border
                        border.width: 1
                        clip: true

                        ListView {
                            anchors.fill:    parent
                            anchors.margins: 14
                            model:   expense.transactions
                            spacing: 7
                            clip:    true

                            delegate: ExpenseCard {
                                required property var modelData
                                width:    ListView.view.width
                                txId:     modelData.id
                                emoji:    modelData.icon
                                title:    modelData.title
                                category: modelData.category
                                date:     modelData.date
                                note:     modelData.note
                                amount:   modelData.amount
                                type:     modelData.type
                                catColor: modelData.color
                                onDeleteRequested: function(id) { expense.deleteTransaction(id) }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: expense.transactions.length === 0
                                text:    "No transactions found.\nTry clearing the filters."
                                color:   root.textMut
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                lineHeight: 1.6
                            }
                        }
                    }
                }
            }

            // ── PAGE 2 : Analytics ────────────────────────────────────────────
            Item {
                ColumnLayout {
                    anchors.fill:    parent
                    anchors.margins: 28
                    spacing:         16

                    Text { text: "Analytics"; color: root.textPri; font.pixelSize: 24; font.bold: true }

                    RowLayout {
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        spacing: 14

                        // Category breakdown panel
                        Rectangle {
                            Layout.fillHeight: true
                            width: 320
                            radius: 18
                            color:  root.surface
                            border.color: root.border
                            border.width: 1

                            ColumnLayout {
                                anchors.fill:    parent
                                anchors.margins: 20
                                spacing:         14

                                Text { text: "EXPENSE BREAKDOWN"; color: root.textMut; font.pixelSize: 11; font.letterSpacing: 1.5 }

                                DonutChart {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 200; height: 200
                                    segments: {
                                        var segs = []
                                        for (var i = 0; i < expense.categoryTotals.length; i++) {
                                            var c = expense.categoryTotals[i]
                                            segs.push({ color: c.color, value: c.total, label: c.category })
                                        }
                                        return segs
                                    }
                                    total: expense.totalExpenses
                                }

                                ListView {
                                    Layout.fillWidth:  true
                                    Layout.fillHeight: true
                                    model:   expense.categoryTotals
                                    spacing: 8
                                    clip:    true

                                    delegate: ColumnLayout {
                                        required property var modelData
                                        width:   ListView.view.width
                                        spacing: 4

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8
                                            Text { text: modelData.icon; font.pixelSize: 14 }
                                            Text { text: modelData.category; color: root.textSec; font.pixelSize: 12; Layout.fillWidth: true }
                                            Text {
                                                text: "₹" + modelData.total.toLocaleString(Qt.locale(), 'f', 0)
                                                color: modelData.color
                                                font.pixelSize: 12
                                                font.bold: true
                                            }
                                            Text {
                                                text: expense.totalExpenses > 0
                                                      ? Math.round(modelData.total / expense.totalExpenses * 100) + "%"
                                                      : "0%"
                                                color: root.textMut
                                                font.pixelSize: 11
                                            }
                                        }

                                        // Progress bar
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 5
                                            radius: 3
                                            color:  Qt.rgba(1,1,1,0.07)
                                            Rectangle {
                                                height: parent.height
                                                radius: parent.radius
                                                color:  modelData.color
                                                width:  expense.totalExpenses > 0
                                                        ? parent.width * (modelData.total / expense.totalExpenses)
                                                        : 0
                                                Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: expense.categoryTotals.length === 0
                                        text:    "No expense data"
                                        color:   root.textMut
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        // Monthly bar chart panel
                        Rectangle {
                            Layout.fillWidth:  true
                            Layout.fillHeight: true
                            radius: 18
                            color:  root.surface
                            border.color: root.border
                            border.width: 1

                            ColumnLayout {
                                anchors.fill:    parent
                                anchors.margins: 24
                                spacing:         16

                                Text { text: "MONTHLY TREND (6 MONTHS)"; color: root.textMut; font.pixelSize: 11; font.letterSpacing: 1.5 }

                                // Legend
                                RowLayout {
                                    spacing: 16
                                    Repeater {
                                        model: [
                                            { barColor: root.accentR, label: "Expenses" },
                                            { barColor: root.accentG, label: "Income"   }
                                        ]
                                        delegate: RowLayout {
                                            required property var modelData
                                            spacing: 6
                                            Rectangle { width: 12; height: 12; radius: 3; color: modelData.barColor }
                                            Text { text: modelData.label; color: root.textSec; font.pixelSize: 12 }
                                        }
                                    }
                                }

                                // Bar chart
                                Item {
                                    Layout.fillWidth:  true
                                    Layout.fillHeight: true

                                    Text {
                                        anchors.centerIn: parent
                                        visible:          expense.monthlyTrend.length === 0
                                        text:             "No trend data yet"
                                        color:            root.textMut
                                        font.pixelSize:   13
                                    }

                                    Row {
                                        anchors.fill: parent
                                        spacing: 0
                                        visible: expense.monthlyTrend.length > 0

                                        Repeater {
                                            model: expense.monthlyTrend

                                            delegate: Item {
                                                required property var modelData
                                                width:  parent.width / Math.max(expense.monthlyTrend.length, 1)
                                                height: parent.height

                                                property double maxVal: {
                                                    var mx = 1
                                                    for (var i = 0; i < expense.monthlyTrend.length; i++) {
                                                        var e   = expense.monthlyTrend[i].expense || 0
                                                        var inc = expense.monthlyTrend[i].income  || 0
                                                        mx = Math.max(mx, e, inc)
                                                    }
                                                    return mx
                                                }

                                                ColumnLayout {
                                                    anchors.fill: parent
                                                    spacing: 6

                                                    Item {
                                                        Layout.fillWidth:  true
                                                        Layout.fillHeight: true

                                                        Row {
                                                            anchors.bottom:           parent.bottom
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            spacing: 4

                                                            // Expense bar
                                                            Rectangle {
                                                                width:  16
                                                                radius: 4
                                                                color:  root.accentR
                                                                anchors.bottom: parent.bottom
                                                                height: {
                                                                    var e = modelData.expense || 0
                                                                    return (e / maxVal) * (parent.parent.height - 10)
                                                                }
                                                                Behavior on height { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                                                            }

                                                            // Income bar
                                                            Rectangle {
                                                                width:  16
                                                                radius: 4
                                                                color:  root.accentG
                                                                anchors.bottom: parent.bottom
                                                                height: {
                                                                    var inc = modelData.income || 0
                                                                    return (inc / maxVal) * (parent.parent.height - 10)
                                                                }
                                                                Behavior on height { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                                                            }
                                                        }
                                                    }

                                                    // Month label
                                                    Text {
                                                        Layout.alignment: Qt.AlignHCenter
                                                        text: {
                                                            var parts = (modelData.month || "").split("-")
                                                            if (parts.length < 2) return ""
                                                            var months = ["Jan","Feb","Mar","Apr","May","Jun",
                                                                          "Jul","Aug","Sep","Oct","Nov","Dec"]
                                                            return months[parseInt(parts[1]) - 1] || parts[1]
                                                        }
                                                        color: root.textMut
                                                        font.pixelSize: 11
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Add Transaction Dialog (overlay) ─────────────────────────────────────
    AddExpenseDialog {
        id:           dialog
        anchors.fill: parent
        visible:      false
        categories:   expense.getCategories()

        onAccepted: function(title, amount, category, type, date, note) {
            if (expense.addTransaction(title, amount, category, type, date, note)) {
                visible = false
                toastText.text = type === "income" ? "✅ Income added!" : "✅ Expense added!"
                toastTimer.restart()
            }
        }
        onCancelled: visible = false
    }

    // ── Toast notification ────────────────────────────────────────────────────
    Rectangle {
        id: toast
        anchors.bottom:           parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin:     28
        width:   toastText.implicitWidth + 32
        height:  42
        radius:  21
        color:   "#313244"
        border.color: Qt.rgba(1,1,1,0.15)
        border.width: 1
        visible: opacity > 0
        opacity: 0
        z: 100

        Text {
            id:               toastText
            anchors.centerIn: parent
            color:            root.textPri
            font.pixelSize:   14
        }

        Timer {
            id:          toastTimer
            interval:    2400
            onTriggered: toastFade.start()
        }

        NumberAnimation on opacity {
            id:      toastFadeIn
            from:    0; to: 1; duration: 200
            running: toastTimer.running
            onStarted: toast.opacity = 1
        }
        NumberAnimation {
            id:       toastFade
            target:   toast
            property: "opacity"
            from:     1; to: 0; duration: 350
        }
    }
}
