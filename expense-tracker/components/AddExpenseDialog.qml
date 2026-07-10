// AddExpenseDialog.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Rectangle {
    id: root

    property bool   isIncome:   false
    property var    categories: []

    signal accepted(string title, real amount, string category,
                    string type, string date, string note)
    signal cancelled()

    // ── Overlay background ────────────────────────────────────────────────────
    color: Qt.rgba(0, 0, 0, 0.55)

    // Dismiss on backdrop click
    MouseArea {
        anchors.fill: parent
        onClicked: root.cancelled()
    }

    // ── Dialog card ───────────────────────────────────────────────────────────
    Rectangle {
        id: card
        width:  460
        // Height driven by content; clamped so it never overflows the overlay
        height: Math.min(contentCol.implicitHeight + 56, root.height - 40)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:   parent.verticalCenter
        radius:  22
        color:   "#1e1e2e"
        border.color: Qt.rgba(1,1,1,0.10)
        border.width: 1
        clip: true

        // Stop backdrop click propagation
        MouseArea { anchors.fill: parent }

        // Entrance animation
        NumberAnimation on scale {
            from: 0.88; to: 1.0; duration: 220
            easing.type: Easing.OutBack
            running: true
        }
        NumberAnimation on opacity {
            from: 0; to: 1; duration: 200
            running: true
        }

        // Scrollable wrapper so content is never hidden in small windows
        Flickable {
            anchors.fill:  parent
            contentWidth:  width
            contentHeight: contentCol.implicitHeight + 56
            clip:          true

            ColumnLayout {
                id:              contentCol
                width:           parent.width - 56
                x:               28
                y:               28
                spacing:         18

            // ── Header ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text:           root.isIncome ? "➕ Add Income" : "➖ Add Expense"
                    color:          "#cdd6f4"
                    font.pixelSize: 18
                    font.bold:      true
                    Layout.fillWidth: true
                }

                // Type toggle
                Rectangle {
                    width:  130; height: 32; radius: 10
                    color:  Qt.rgba(1,1,1,0.06)
                    border.color: Qt.rgba(1,1,1,0.10); border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        spacing:      0

                        Rectangle {
                            Layout.fillWidth: true; height: parent.height; radius: 9
                            color: !root.isIncome ? "#FF6B6B" : "transparent"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: "Expense"; color: "#fff"
                                font.pixelSize: 11; font.bold: !root.isIncome
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { root.isIncome = false; catRepeater.selectedIndex = -1 }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true; height: parent.height; radius: 9
                            color: root.isIncome ? "#1DD1A1" : "transparent"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: "Income"; color: "#fff"
                                font.pixelSize: 11; font.bold: root.isIncome
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { root.isIncome = true; catRepeater.selectedIndex = -1 }
                            }
                        }
                    }
                }
            }

            // ── Title input ───────────────────────────────────────────────────
            ColumnLayout { spacing: 6; Layout.fillWidth: true
                Text { text: "Title"; color: Qt.rgba(1,1,1,0.55); font.pixelSize: 12 }
                Rectangle {
                    Layout.fillWidth: true; height: 42; radius: 10
                    color: Qt.rgba(1,1,1,0.06)
                    border.color: titleIn.activeFocus ? "#89b4fa" : Qt.rgba(1,1,1,0.12)
                    border.width: 1.5
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    TextInput {
                        id: titleIn
                        anchors.fill:    parent
                        anchors.margins: 12
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        Text {
                            anchors.fill: parent
                            text: "e.g. Groceries, Salary…"
                            color: Qt.rgba(1,1,1,0.25)
                            font.pixelSize: 14
                            visible: parent.text.length === 0
                        }
                    }
                }
            }

            // ── Amount input ──────────────────────────────────────────────────
            ColumnLayout { spacing: 6; Layout.fillWidth: true
                Text { text: "Amount (₹)"; color: Qt.rgba(1,1,1,0.55); font.pixelSize: 12 }
                Rectangle {
                    Layout.fillWidth: true; height: 42; radius: 10
                    color: Qt.rgba(1,1,1,0.06)
                    border.color: amtIn.activeFocus ? "#89b4fa" : Qt.rgba(1,1,1,0.12)
                    border.width: 1.5
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill:    parent
                        anchors.margins: 12
                        spacing: 6
                        Text { text: "₹"; color: Qt.rgba(1,1,1,0.45); font.pixelSize: 16 }
                        TextInput {
                            id: amtIn
                            Layout.fillWidth: true
                            color: "#cdd6f4"; font.pixelSize: 14
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            validator: DoubleValidator { bottom: 0; decimals: 2; notation: DoubleValidator.StandardNotation }
                            Text {
                                anchors.fill: parent
                                text: "0.00"; color: Qt.rgba(1,1,1,0.25); font.pixelSize: 14
                                visible: parent.text.length === 0
                            }
                        }
                    }
                }
            }

            // ── Category ──────────────────────────────────────────────────────
            ColumnLayout { spacing: 8; Layout.fillWidth: true
                Text { text: "Category"; color: Qt.rgba(1,1,1,0.55); font.pixelSize: 12 }

                Flow {
                    Layout.fillWidth: true
                    spacing: 7

                    property int selectedIndex: -1

                    Repeater {
                        id: catRepeater
                        property int selectedIndex: -1
                        model: root.categories

                        delegate: Rectangle {
                            required property var    modelData
                            required property int    index
                            property bool sel: catRepeater.selectedIndex === index

                            // Skip income-only or expense-only categories
                            visible: {
                                var incCats = ["Salary","Freelance","Investment"]
                                if (root.isIncome  && !incCats.includes(modelData.name)) return false
                                if (!root.isIncome &&  incCats.includes(modelData.name)) return false
                                return true
                            }

                            width:  row.implicitWidth + 18
                            height: 28
                            radius: 14
                            color:  sel ? Qt.rgba(Qt.color(modelData.color).r,
                                                  Qt.color(modelData.color).g,
                                                  Qt.color(modelData.color).b, 0.25)
                                        : Qt.rgba(1,1,1,0.05)
                            border.color: sel ? modelData.color : Qt.rgba(1,1,1,0.12)
                            border.width: 1.5
                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                id: row
                                anchors.centerIn: parent; spacing: 4
                                Text { text: modelData.icon; font.pixelSize: 11 }
                                Text {
                                    text: modelData.name; font.pixelSize: 11
                                    color: sel ? modelData.color : "#a6adc8"
                                    font.bold: sel
                                }
                            }

                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: catRepeater.selectedIndex = index
                            }
                        }
                    }
                }
            }

            // ── Date + Note row ───────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true; spacing: 12

                ColumnLayout { spacing: 6; Layout.fillWidth: true
                    Text { text: "Date"; color: Qt.rgba(1,1,1,0.55); font.pixelSize: 12 }
                    Rectangle {
                        Layout.fillWidth: true; height: 42; radius: 10
                        color: Qt.rgba(1,1,1,0.06)
                        border.color: dateIn.activeFocus ? "#89b4fa" : Qt.rgba(1,1,1,0.12)
                        border.width: 1.5
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        TextInput {
                            id: dateIn
                            anchors.fill:    parent
                            anchors.margins: 12
                            color: "#cdd6f4"
                            font.pixelSize: 14
                            text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                        }
                    }
                }

                ColumnLayout { spacing: 6; Layout.fillWidth: true
                    Text { text: "Note (optional)"; color: Qt.rgba(1,1,1,0.55); font.pixelSize: 12 }
                    Rectangle {
                        Layout.fillWidth: true; height: 42; radius: 10
                        color: Qt.rgba(1,1,1,0.06)
                        border.color: noteIn.activeFocus ? "#89b4fa" : Qt.rgba(1,1,1,0.12)
                        border.width: 1.5
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        TextInput {
                            id: noteIn
                            anchors.fill:    parent
                            anchors.margins: 12
                            color: "#cdd6f4"
                            font.pixelSize: 14
                            Text {
                                anchors.fill: parent
                                text: "Short note…"
                                color: Qt.rgba(1,1,1,0.25)
                                font.pixelSize: 14
                                visible: parent.text.length === 0
                            }
                        }
                    }
                }
            }

            // ── Error message ─────────────────────────────────────────────────
            Rectangle {
                id: errBanner
                Layout.fillWidth: true; height: 36; radius: 8
                visible: errorText.text.length > 0
                color: Qt.rgba(0.86, 0.24, 0.24, 0.20)
                border.color: Qt.rgba(0.86, 0.24, 0.24, 0.45); border.width: 1
                Text {
                    id: errorText
                    anchors.fill:    parent
                    anchors.margins: 10
                    color: "#ffaaaa"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
            }

            // ── Buttons ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true; spacing: 10

                // Cancel
                Rectangle {
                    Layout.fillWidth: true; height: 44; radius: 12
                    color: cancelMa.containsMouse ? Qt.rgba(1,1,1,0.10) : Qt.rgba(1,1,1,0.05)
                    border.color: Qt.rgba(1,1,1,0.12); border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#a6adc8"; font.pixelSize: 14 }
                    MouseArea {
                        id: cancelMa; anchors.fill: parent
                        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: root.cancelled()
                    }
                }

                // Save
                Rectangle {
                    Layout.fillWidth: true; height: 44; radius: 12
                    color: saveMa.pressed ? Qt.darker(accentCol, 1.1)
                                         : (saveMa.containsMouse ? Qt.lighter(accentCol, 1.1) : accentCol)
                    property color accentCol: root.isIncome ? "#1DD1A1" : "#89b4fa"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text { anchors.centerIn: parent; text: "Save"; color: "#fff"; font.pixelSize: 14; font.bold: true }
                    MouseArea {
                        id: saveMa; anchors.fill: parent
                        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Validate
                            if (titleIn.text.trim().length === 0) {
                                errorText.text = "Please enter a title."; return
                            }
                            if (parseFloat(amtIn.text) <= 0 || amtIn.text.length === 0) {
                                errorText.text = "Please enter a valid amount."; return
                            }
                            if (catRepeater.selectedIndex < 0) {
                                errorText.text = "Please select a category."; return
                            }
                            errorText.text = ""
                            var cat = root.categories[catRepeater.selectedIndex].name
                            root.accepted(
                                titleIn.text.trim(),
                                parseFloat(amtIn.text),
                                cat,
                                root.isIncome ? "income" : "expense",
                                dateIn.text,
                                noteIn.text.trim()
                            )
                        }
                    }
                }
            }

            Item { height: 2 }
        }
        } // Flickable
    }

    function reset() {
        titleIn.text  = ""
        amtIn.text    = ""
        noteIn.text   = ""
        dateIn.text   = Qt.formatDate(new Date(), "yyyy-MM-dd")
        catRepeater.selectedIndex = -1
        errorText.text = ""
    }
}
