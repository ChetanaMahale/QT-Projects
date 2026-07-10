// CategoryBadge.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string label: ""
    property string iconText: ""
    property color  badgeColor: "#A29BFE"
    property bool   selected: false
    property bool   clickable: true

    signal clicked()

    implicitWidth:  row.implicitWidth + 20
    implicitHeight: 30
    radius:         15
    color:          selected ? Qt.rgba(badgeColor.r, badgeColor.g, badgeColor.b, 0.25)
                             : (hov.containsMouse && clickable ? Qt.rgba(1,1,1,0.08) : Qt.rgba(1,1,1,0.05))
    border.color:   selected ? badgeColor : Qt.rgba(1,1,1,0.12)
    border.width:   1.5

    Behavior on color       { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            text:           root.iconText
            font.pixelSize: 12
            visible:        root.iconText.length > 0
        }
        Text {
            text:           root.label
            color:          root.selected ? root.badgeColor : "#cdd6f4"
            font.pixelSize: 12
            font.bold:      root.selected
        }
    }

    MouseArea {
        id: hov
        anchors.fill: parent
        hoverEnabled: root.clickable
        cursorShape:  root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked:    if (root.clickable) root.clicked()
    }
}
