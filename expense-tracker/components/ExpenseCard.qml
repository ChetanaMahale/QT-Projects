// ExpenseCard.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property int    txId:      0
    property string emoji:     "📦"
    property string title:     ""
    property string category:  ""
    property string date:      ""
    property string note:      ""
    property double amount:    0.0
    property string type:      "expense"   // "expense" | "income"
    property color  catColor:  "#A29BFE"

    signal deleteRequested(int id)

    implicitHeight: 68
    radius:         14
    color:          hov.containsMouse ? Qt.rgba(1,1,1,0.07) : Qt.rgba(1,1,1,0.04)
    border.color:   Qt.rgba(1,1,1,0.09)
    border.width:   1

    Behavior on color { ColorAnimation { duration: 100 } }

    // Left accent bar
    Rectangle {
        width:  4
        height: parent.height * 0.6
        radius: 2
        anchors { left: parent.left; leftMargin: 0; verticalCenter: parent.verticalCenter }
        color:  root.type === "income" ? "#1DD1A1" : root.catColor
    }

    RowLayout {
        anchors.fill:         parent
        anchors.leftMargin:   16
        anchors.rightMargin:  12
        anchors.topMargin:    10
        anchors.bottomMargin: 10
        spacing:              12

        // Icon circle
        Rectangle {
            width:  42; height: 42; radius: 21
            color:  Qt.rgba(catColor.r, catColor.g, catColor.b, 0.18)
            Text {
                anchors.centerIn: parent
                text:            root.emoji
                font.pixelSize:  20
            }
        }

        // Title + meta
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text:           root.title
                color:          "#cdd6f4"
                font.pixelSize: 14
                font.bold:      true
                elide:          Text.ElideRight
                Layout.fillWidth: true
            }
            RowLayout {
                spacing: 8
                Text {
                    text:           root.category
                    color:          root.catColor
                    font.pixelSize: 11
                }
                Text {
                    text:           "•"
                    color:          Qt.rgba(1,1,1,0.25)
                    font.pixelSize: 10
                    visible:        root.note.length > 0
                }
                Text {
                    text:           root.note
                    color:          Qt.rgba(1,1,1,0.40)
                    font.pixelSize: 11
                    elide:          Text.ElideRight
                    Layout.fillWidth: true
                    visible:        root.note.length > 0
                }
            }
        }

        // Right: amount + date + delete
        ColumnLayout {
            spacing: 3
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

            Text {
                Layout.alignment:   Qt.AlignRight
                text:               (root.type === "income" ? "+" : "−") +
                                    " ₹" + root.amount.toLocaleString(Qt.locale(), 'f', 2)
                color:              root.type === "income" ? "#1DD1A1" : "#FF6B6B"
                font.pixelSize:     15
                font.bold:          true
            }
            Text {
                Layout.alignment:   Qt.AlignRight
                text:               root.date
                color:              Qt.rgba(1,1,1,0.38)
                font.pixelSize:     11
            }
        }

        // Delete button
        Rectangle {
            width:  30; height: 30; radius: 8
            color:  delMa.containsMouse ? Qt.rgba(0.96, 0.27, 0.27, 0.22) : "transparent"
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text:             "🗑️"
                font.pixelSize:   14
            }
            MouseArea {
                id:          delMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked:    root.deleteRequested(root.txId)
            }
        }
    }

    MouseArea {
        id: hov
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onClicked: mouse.accepted = false
    }
}
