import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import QtQuick.Effects

ApplicationWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 640
    minimumHeight: 480
    visible: true
    title: fileHandler.fileName + (fileHandler.isModified ? " •" : "") + " - Text Editor"
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
    readonly property color danger:     "#f87171"
    readonly property color border:     "#27272d"

    // ── State variables ────────────────────────────────────────────────────────
    property int  fontSize:       14
    property bool showFindPanel:  false
    property string toastMsg:     ""
    property bool   toastIsErr:   false

    // ── Dialogs ────────────────────────────────────────────────────────────────
    FileDialog {
        id: openFileDialog
        title: "Open Text File"
        currentFolder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        nameFilters: ["Text Files (*.txt *.md *.json *.xml *.cpp *.h *.qml *.html *.css)", "All Files (*)"]
        onAccepted: {
            var content = fileHandler.openFile(selectedFile)
            editorArea.text = content
            showToast("Opened file: " + fileHandler.fileName, false)
        }
    }

    FileDialog {
        id: saveFileDialog
        title: "Save File As"
        fileMode: FileDialog.SaveFile
        currentFolder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        nameFilters: ["Text Files (*.txt)", "Markdown Files (*.md)", "JSON Files (*.json)", "All Files (*)"]
        onAccepted: {
            var success = fileHandler.saveFile(selectedFile, editorArea.text)
            if (success) {
                showToast("Saved file: " + fileHandler.fileName, false)
            }
        }
    }

    // ── Connections ────────────────────────────────────────────────────────────
    Connections {
        target: fileHandler
        function onErrorOccurred(message) {
            showToast(message, true)
        }
        function onFileSaved() {
            showToast("Saved successfully", false)
        }
    }

    function showToast(msg, isErr) {
        root.toastMsg = msg
        root.toastIsErr = isErr
        toastTimer.restart()
    }

    function triggerSave() {
        if (fileHandler.filePath === "") {
            saveFileDialog.open()
        } else {
            fileHandler.saveCurrentFile(editorArea.text)
        }
    }

    // Keyboard Shortcuts
    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.modifiers & Qt.ControlModifier) {
                switch (event.key) {
                case Qt.Key_N:
                    fileHandler.newFile()
                    editorArea.text = ""
                    showToast("New document created", false)
                    event.accepted = true
                    break
                case Qt.Key_O:
                    openFileDialog.open()
                    event.accepted = true
                    break
                case Qt.Key_S:
                    triggerSave()
                    event.accepted = true
                    break
                case Qt.Key_F:
                    root.showFindPanel = !root.showFindPanel
                    if (root.showFindPanel) findInput.forceActiveFocus()
                    event.accepted = true
                    break
                }
            }
        }
    }

    // ── Main UI Layout ─────────────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            Layout.fillHeight: true
            width: 60
            color: root.bgCard
            border.color: root.border
            border.width: 1

            // Side Accent highlight line
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: root.border
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                SidebarButton { iconText: "📄"; tooltip: "New (Ctrl+N)"; onClicked: { fileHandler.newFile(); editorArea.text = "" } }
                SidebarButton { iconText: "📂"; tooltip: "Open (Ctrl+O)"; onClicked: openFileDialog.open() }
                SidebarButton { iconText: "💾"; tooltip: "Save (Ctrl+S)"; onClicked: triggerSave() }
                SidebarButton { iconText: "📤"; tooltip: "Save As..."; onClicked: saveFileDialog.open() }
                SidebarButton { iconText: "🔍"; tooltip: "Find (Ctrl+F)"; onClicked: root.showFindPanel = !root.showFindPanel }

                Item { Layout.fillHeight: true }

                // Font Size Buttons
                SidebarButton { iconText: "➕"; tooltip: "Increase Font"; onClicked: { if (root.fontSize < 32) root.fontSize += 1 } }
                SidebarButton { iconText: "➖"; tooltip: "Decrease Font"; onClicked: { if (root.fontSize > 8) root.fontSize -= 1 } }
            }
        }

        // Editor & Panels Column
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Header panel showing status
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: root.bgCard
                border.color: root.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Text {
                        text: fileHandler.fileName
                        font.pixelSize: 15
                        font.bold: true
                        color: root.textPri
                    }

                    Text {
                        text: fileHandler.isModified ? "• Modified" : ""
                        font.pixelSize: 11
                        font.bold: true
                        color: root.accent
                        opacity: fileHandler.isModified ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: fileHandler.filePath === "" ? "Not saved on disk" : fileHandler.filePath
                        font.pixelSize: 12
                        color: root.textSec
                        elide: Text.ElideLeft
                        Layout.maximumWidth: 350
                    }
                }
            }

            // Find & Replace Panel (Collapsible)
            Rectangle {
                Layout.fillWidth: true
                height: root.showFindPanel ? 50 : 0
                clip: true
                color: root.bgPanel
                border.color: root.border
                border.width: 1
                visible: height > 1

                Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    Text {
                        text: "Find:"
                        font.pixelSize: 12
                        color: root.textSec
                    }

                    // Find input
                    Rectangle {
                        width: 160; height: 28; radius: 6
                        color: root.bgInput
                        border.color: findInput.activeFocus ? root.accent : root.border
                        border.width: 1

                        Text {
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 8 }
                            text: "Search text..."
                            font.pixelSize: 12
                            color: root.textMuted
                            visible: findInput.text.length === 0 && !findInput.activeFocus
                        }
                        TextInput {
                            id: findInput
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 8 }
                            font.pixelSize: 12
                            color: root.textPri
                            selectionColor: root.accent + "66"
                        }
                    }

                    Text {
                        text: "Replace:"
                        font.pixelSize: 12
                        color: root.textSec
                    }

                    // Replace input
                    Rectangle {
                        width: 160; height: 28; radius: 6
                        color: root.bgInput
                        border.color: replaceInput.activeFocus ? root.accent : root.border
                        border.width: 1

                        Text {
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 8 }
                            text: "Replace with..."
                            font.pixelSize: 12
                            color: root.textMuted
                            visible: replaceInput.text.length === 0 && !replaceInput.activeFocus
                        }
                        TextInput {
                            id: replaceInput
                            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 8 }
                            font.pixelSize: 12
                            color: root.textPri
                            selectionColor: root.accent + "66"
                        }
                    }

                    // Action buttons
                    Rectangle {
                        width: 60; height: 28; radius: 6; color: root.accentDark
                        Text { anchors.centerIn: parent; text: "Find Next"; font.pixelSize: 11; font.bold: true; color: "white" }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var search = findInput.text
                                if (search.length > 0) {
                                    var textContent = editorArea.text
                                    var start = editorArea.cursorPosition
                                    var idx = textContent.indexOf(search, start)
                                    if (idx === -1) {
                                        // Wrap around
                                        idx = textContent.indexOf(search, 0)
                                    }
                                    if (idx !== -1) {
                                        editorArea.select(idx, idx + search.length)
                                        editorArea.cursorPosition = idx + search.length
                                        editorArea.forceActiveFocus()
                                    } else {
                                        showToast("Text not found", true)
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 60; height: 28; radius: 6; color: root.bgInput; border.color: root.border; border.width: 1
                        Text { anchors.centerIn: parent; text: "Replace"; font.pixelSize: 11; color: root.textPri }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var search = findInput.text
                                var repVal = replaceInput.text
                                if (search.length > 0 && editorArea.selectedText === search) {
                                    var start = editorArea.selectionStart
                                    var end = editorArea.selectionEnd
                                    editorArea.remove(start, end)
                                    editorArea.insert(start, repVal)
                                    editorArea.select(start, start + repVal.length)
                                    fileHandler.setIsModified(true)
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Close find
                    Text {
                        text: "✕"
                        font.pixelSize: 13
                        color: root.textSec
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showFindPanel = false
                        }
                    }
                }
            }

            // Editor Area (ScrollView)
            ScrollView {
                id: editorScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                TextArea {
                    id: editorArea
                    placeholderText: "Start typing code, logs or text here..."
                    font.family: "Courier New"
                    font.pixelSize: root.fontSize
                    color: root.textPri
                    placeholderTextColor: root.textMuted
                    selectionColor: root.accent + "66"
                    selectedTextColor: root.textPri
                    wrapMode: TextEdit.Wrap
                    padding: 16
                    selectByMouse: true

                    background: Rectangle {
                        color: "#0a0a0c"
                    }

                    onTextChanged: {
                        fileHandler.setIsModified(true)
                        fileHandler.updateStats(editorArea.text)
                    }
                }
            }

            // Status Bar
            Rectangle {
                Layout.fillWidth: true
                height: 32
                color: root.bgCard
                border.color: root.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    Text {
                        text: "Words: " + fileHandler.wordCount
                        font.pixelSize: 11
                        color: root.textSec
                    }
                    Text {
                        text: "Chars: " + fileHandler.charCount
                        font.pixelSize: 11
                        color: root.textSec
                    }
                    Text {
                        text: "Lines: " + fileHandler.lineCount
                        font.pixelSize: 11
                        color: root.textSec
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "UTF-8 | Plain Text"
                        font.pixelSize: 11
                        color: root.textSec
                    }
                }
            }
        }
    }

    // ── Toast Banner ──────────────────────────────────────────────────────────
    Rectangle {
        id: toastBanner
        anchors { right: parent.right; bottom: parent.bottom; margins: 48 }
        width: 260
        height: 48
        radius: 10
        color: root.toastIsErr ? root.danger + "ee" : root.accentDark + "ee"
        visible: opacity > 0.01
        opacity: 0.0

        Behavior on opacity { NumberAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                text: root.toastIsErr ? "⚠️" : "✨"
                font.pixelSize: 14
            }
            Text {
                Layout.fillWidth: true
                text: root.toastMsg
                font.pixelSize: 12
                font.bold: true
                color: "white"
                elide: Text.ElideRight
            }
        }
    }

    Timer {
        id: toastTimer
        interval: 2500
        onTriggered: toastBanner.opacity = 0.0
        onRunningChanged: {
            if (running) toastBanner.opacity = 1.0
        }
    }

    // ── Sidebar Button Component ───────────────────────────────────────────────
    component SidebarButton: Rectangle {
        id: sBtn
        property string iconText: ""
        property string tooltip: ""
        signal clicked

        Layout.fillWidth: true
        height: width
        radius: 12
        color: btnMa.pressed ? "#23232c" : (btnMa.containsMouse ? "#1c1c24" : "transparent")

        Behavior on color { ColorAnimation { duration: 100 } }

        Text {
            anchors.centerIn: parent
            text: sBtn.iconText
            font.pixelSize: 20
        }

        MouseArea {
            id: btnMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: sBtn.clicked()
        }

        // Simple tooltip box on hover
        Rectangle {
            id: tooltipBox
            visible: btnMa.containsMouse
            anchors { left: parent.right; leftMargin: 10; verticalCenter: parent.verticalCenter }
            width: ttText.implicitWidth + 12
            height: 24
            color: "#1e1e24"
            border.color: root.border
            border.width: 1
            radius: 5
            z: 100

            Text {
                id: ttText
                anchors.centerIn: parent
                text: sBtn.tooltip
                font.pixelSize: 10
                color: "white"
            }
        }
    }
}
