// StatCard.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string emoji:    ""
    property string label:    ""
    property string value:    ""
    property color  accent:   "#A29BFE"
    property bool   positive: true

    implicitHeight: 90
    radius:         16
    color:          Qt.rgba(1, 1, 1, 0.06)
    border.color:   Qt.rgba(accent.r, accent.g, accent.b, 0.30)
    border.width:   1

    // Glow
    Rectangle {
        anchors.fill:    parent
        radius:          parent.radius
        color:           "transparent"
        border.color:    Qt.rgba(accent.r, accent.g, accent.b, 0.12)
        border.width:    6
    }

    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: 16
        spacing:         4

        RowLayout {
            spacing: 6
            Text { text: root.emoji;  font.pixelSize: 18 }
            Text {
                text:           root.label
                color:          Qt.rgba(1,1,1,0.55)
                font.pixelSize: 12
                font.letterSpacing: 0.5
            }
        }

        Text {
            text:           root.value
            color:          root.accent
            font.pixelSize: 22
            font.bold:      true

            NumberAnimation on opacity {
                loops:    1; from: 0; to: 1; duration: 600
                easing.type: Easing.OutCubic
            }
        }
    }
}
