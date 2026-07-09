import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects

ApplicationWindow {
    id: root
    width: 440
    height: 780
    minimumWidth: 380
    minimumHeight: 640
    visible: true
    title: "ToDo App"
    color: "#0d0d0f"

    // ── Palette ────────────────────────────────────────────────────────────────
    readonly property color bgBase:     "#0d0d0f"
    readonly property color bgCard:     "#17171a"
    readonly property color bgInput:    "#1c1c21"
    readonly property color bgPanel:    "#1e1e25"
    readonly property color accent:     "#a78bfa"
    readonly property color accentDark: "#7c3aed"
    readonly property color textPri:    "#f4f4f5"
    readonly property color textSec:    "#71717a"
    readonly property color textMuted:  "#3f3f47"
    readonly property color success:    "#34d399"
    readonly property color danger:     "#f87171"
    readonly property color border:     "#27272d"

    readonly property var priorityColors: ["#60a5fa", "#facc15", "#f87171"]
    readonly property var priorityLabels: ["Low", "Medium", "High"]

    // ── State ─────────────────────────────────────────────────────────────────
    property int  editingId:    -1
    property bool showAddPanel: false

    // ── Helper function ────────────────────────────────────────────────────────
    function doAddTask() {
        if (titleInput.text.trim() !== "") {
            todoManager.addTodo(titleInput.text, prioritySelector.current)
            titleInput.text = ""
            prioritySelector.current = 1
            root.showAddPanel = false
        }
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
            var g1 = ctx.createRadialGradient(width * 0.15, height * 0.1, 0, width * 0.15, height * 0.1, 260)
            g1.addColorStop(0, "#1a0a38")
            g1.addColorStop(1, "transparent")
            ctx.fillStyle = g1; ctx.fillRect(0, 0, width, height)
            var g2 = ctx.createRadialGradient(width * 0.85, height * 0.75, 0, width * 0.85, height * 0.75, 200)
            g2.addColorStop(0, "#09183a")
            g2.addColorStop(1, "transparent")
            ctx.fillStyle = g2; ctx.fillRect(0, 0, width, height)
        }
    }

    // ── Main layout ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 0
        z: 1

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 6

            ColumnLayout {
                spacing: 2
                Text {
                    text: "My Tasks"
                    font.pixelSize: 28
                    font.bold: true
                    color: root.textPri
                }
                Text {
                    text: todoManager.activeCount + " remaining · " + todoManager.totalCount + " total"
                    font.pixelSize: 13
                    color: root.textSec
                }
            }

            Item { Layout.fillWidth: true }

            // Add button
            Rectangle {
                width: 44; height: 44; radius: 14
                color: root.accentDark
                border.color: root.accent + "88"
                border.width: 1
                scale: addMa.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 80 } }

                Text {
                    anchors.centerIn: parent
                    text: root.showAddPanel ? "✕" : "+"
                    font.pixelSize: 22
                    font.bold: true
                    color: "white"
                    Behavior on text { }
                }
                MouseArea {
                    id: addMa
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.showAddPanel = !root.showAddPanel
                        if (root.showAddPanel) titleInput.forceActiveFocus()
                    }
                }
            }
        }

        // ── Add task panel (collapsible) ──────────────────────────────────────
        Rectangle {
            id: addPanel
            Layout.fillWidth: true
            Layout.topMargin: 10
            Layout.bottomMargin: root.showAddPanel ? 10 : 0
            height: root.showAddPanel ? addPanelContent.implicitHeight + 28 : 0
            clip: true
            radius: 18
            color: root.bgPanel
            border.color: root.border
            border.width: 1
            visible: height > 2

            Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            ColumnLayout {
                id: addPanelContent
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                spacing: 10

                // Title input
                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 12
                    color: root.bgInput
                    border.color: titleInput.activeFocus ? root.accent : root.border
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    TextInput {
                        id: titleInput
                        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 14 }
                        font.pixelSize: 15
                        color: root.textPri
                        selectionColor: root.accent + "66"
                        placeholderText: "What needs to be done?"
                        placeholderTextColor: root.textMuted
                        Keys.onReturnPressed: root.doAddTask()
                        Keys.onEscapePressed: root.showAddPanel = false
                    }
                }

                // Priority selector + Add button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Priority:"
                        font.pixelSize: 13
                        color: root.textSec
                    }

                    Repeater {
                        model: ["Low", "Med", "High"]
                        Rectangle {
                            required property int index
                            required property string modelData
                            width: 52; height: 30; radius: 8
                            color: prioritySelector.current === index
                                   ? root.priorityColors[index] + "33"
                                   : root.bgInput
                            border.color: prioritySelector.current === index
                                          ? root.priorityColors[index]
                                          : root.border
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 12
                                color: prioritySelector.current === index
                                       ? root.priorityColors[index]
                                       : root.textSec
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: prioritySelector.current = parent.index
                            }
                        }
                    }

                    QtObject { id: prioritySelector; property int current: 1 }

                    Item { Layout.fillWidth: true }

                    // Add task button
                    Rectangle {
                        id: addTaskBtn
                        width: 80; height: 34; radius: 10
                        color: root.accentDark

                        Text {
                            anchors.centerIn: parent
                            text: "Add Task"
                            font.pixelSize: 13
                            font.bold: true
                            color: "white"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.doAddTask()
                        }
                    }
                }
            }
        }

        // ── Filter tabs ───────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 4
            Layout.bottomMargin: 14
            height: 42
            radius: 12
            color: root.bgCard
            border.color: root.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4

                Repeater {
                    model: [
                        "All ("    + todoManager.totalCount     + ")",
                        "Active (" + todoManager.activeCount    + ")",
                        "Done ("   + todoManager.completedCount + ")"
                    ]
                    Rectangle {
                        required property int    index
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 9
                        color: todoManager.filterMode === index ? root.accentDark : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData
                            font.pixelSize: 13
                            font.bold: todoManager.filterMode === parent.index
                            color: todoManager.filterMode === parent.index ? "white" : root.textSec
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: todoManager.filterMode = parent.index
                        }
                    }
                }
            }
        }

        // ── Task list ─────────────────────────────────────────────────────────
        ListView {
            id: taskList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            model: todoManager

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 4
                    radius: 2
                    color: root.accent + "66"
                }
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                visible: taskList.count === 0
                text: todoManager.filterMode === 2 ? "No completed tasks yet" :
                      todoManager.filterMode === 1 ? "All tasks done! 🎉" : "No tasks yet\nTap + to add one"
                font.pixelSize: 16
                color: root.textSec
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.6
            }

            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250 }
                NumberAnimation { property: "y"; from: -20; duration: 250; easing.type: Easing.OutCubic }
            }
            remove: Transition {
                NumberAnimation { property: "opacity"; to: 0; duration: 180 }
                NumberAnimation { property: "x"; to: 80;  duration: 180 }
            }
            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutCubic }
            }

            delegate: TodoCard {}
        }

        // ── Footer ────────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 14
            visible: todoManager.completedCount > 0

            Text {
                text: todoManager.completedCount + " task" +
                      (todoManager.completedCount !== 1 ? "s" : "") + " completed"
                font.pixelSize: 13
                color: root.textSec
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "Clear completed"
                font.pixelSize: 13
                color: root.danger
                font.underline: clearMa.containsMouse
                MouseArea {
                    id: clearMa
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: todoManager.clearCompleted()
                }
            }
        }
    }

    // ── TodoCard inline component ─────────────────────────────────────────────
    component TodoCard: Rectangle {
        id: card
        width: taskList.width
        height: cardContent.implicitHeight + 24
        radius: 16
        color: root.bgCard
        border.color: completed ? root.border : (cardMa.containsMouse ? root.accent + "44" : root.border)
        border.width: 1
        clip: true

        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on height       { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        // Priority stripe on left edge
        Rectangle {
            width: 4
            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
            radius: 4
            color: root.priorityColors[priority]
            opacity: completed ? 0.3 : 1.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        RowLayout {
            id: cardContent
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14; leftMargin: 20 }
            spacing: 12

            // Checkbox
            Rectangle {
                width: 24; height: 24; radius: 12
                color: completed ? root.success + "22" : "transparent"
                border.color: completed ? root.success : root.textMuted
                border.width: 2
                Behavior on border.color { ColorAnimation { duration: 150 } }
                Behavior on color        { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.success
                    opacity: completed ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: todoManager.toggleTodo(todoId)
                }
            }

            // Text area
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                // Editable title or static text
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: root.editingId === todoId ? editComp : displayComp

                    Component {
                        id: displayComp
                        Text {
                            text: title
                            font.pixelSize: 15
                            font.strikeout: completed
                            color: completed ? root.textSec : root.textPri
                            elide: Text.ElideRight
                            Behavior on color { ColorAnimation { duration: 200 } }
                            MouseArea {
                                anchors.fill: parent
                                onDoubleClicked: {
                                    root.editingId = todoId
                                }
                            }
                        }
                    }

                    Component {
                        id: editComp
                        TextInput {
                            id: editInput
                            text: title
                            font.pixelSize: 15
                            color: root.textPri
                            selectionColor: root.accent + "66"
                            selectByMouse: true
                            focus: true
                            Component.onCompleted: { selectAll(); forceActiveFocus() }
                            Keys.onReturnPressed: {
                                todoManager.editTodo(todoId, editInput.text)
                                root.editingId = -1
                            }
                            Keys.onEscapePressed: root.editingId = -1
                            onActiveFocusChanged: {
                                if (!activeFocus && root.editingId === todoId) {
                                    todoManager.editTodo(todoId, editInput.text)
                                    root.editingId = -1
                                }
                            }
                        }
                    }
                }

                // Meta row: priority badge + date
                RowLayout {
                    spacing: 6
                    Rectangle {
                        width: priorityLabel.implicitWidth + 12
                        height: 18; radius: 5
                        color: root.priorityColors[priority] + "22"
                        border.color: root.priorityColors[priority] + "55"
                        border.width: 1
                        Text {
                            id: priorityLabel
                            anchors.centerIn: parent
                            text: root.priorityLabels[priority]
                            font.pixelSize: 10
                            color: root.priorityColors[priority]
                        }
                    }
                    Text {
                        text: createdAtText
                        font.pixelSize: 11
                        color: root.textMuted
                    }
                }
            }

            // Delete button
            Rectangle {
                width: 30; height: 30; radius: 9
                color: delMa.containsMouse ? root.danger + "22" : "transparent"
                border.color: delMa.containsMouse ? root.danger : "transparent"
                border.width: 1
                opacity: cardMa.containsMouse || delMa.containsMouse ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }
                Behavior on color   { ColorAnimation  { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 13
                    color: root.danger
                }
                MouseArea {
                    id: delMa
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: todoManager.removeTodo(todoId)
                }
            }
        }

        // Invisible hover tracker for the whole card
        MouseArea {
            id: cardMa
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            onClicked: (mouse) => mouse.accepted = false
        }
    }
}
