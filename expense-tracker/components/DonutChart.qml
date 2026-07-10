// DonutChart.qml – pure QML canvas donut chart (no Qt Charts dependency)
import QtQuick

Canvas {
    id: root

    property var    segments: []   // [{color, value, label}]
    property double total:    0
    property int    hovered:  -1

    implicitWidth:  200
    implicitHeight: 200

    onSegmentsChanged: requestPaint()
    onTotalChanged:    requestPaint()
    onHoveredChanged:  requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        if (total <= 0 || segments.length === 0) {
            // Empty ring
            ctx.beginPath();
            ctx.arc(width/2, height/2, width * 0.38, 0, Math.PI * 2);
            ctx.lineWidth   = width * 0.14;
            ctx.strokeStyle = "#ffffff12";
            ctx.stroke();
            return;
        }

        var cx = width  / 2;
        var cy = height / 2;
        var r  = width  * 0.38;
        var lw = width  * 0.14;
        var gap = 0.025;

        var startAngle = -Math.PI / 2;

        for (var i = 0; i < segments.length; i++) {
            var seg   = segments[i];
            var sweep = (seg.value / total) * (Math.PI * 2 - gap * segments.length);
            var end   = startAngle + sweep;
            var isHov = (i === hovered);

            ctx.beginPath();
            ctx.arc(cx, cy, isHov ? r + 4 : r, startAngle + gap/2, end - gap/2);
            ctx.lineWidth   = isHov ? lw + 4 : lw;
            ctx.strokeStyle = seg.color;
            ctx.lineCap     = "round";
            ctx.stroke();

            startAngle = end;
        }

        // Centre text
        if (hovered >= 0 && hovered < segments.length) {
            var s = segments[hovered];
            ctx.fillStyle   = "#ffffff";
            ctx.font        = "bold " + Math.round(width * 0.10) + "px sans-serif";
            ctx.textAlign   = "center";
            ctx.textBaseline = "middle";
            var pct = total > 0 ? Math.round(s.value / total * 100) : 0;
            ctx.fillText(pct + "%", cx, cy - 8);
            ctx.font        = Math.round(width * 0.072) + "px sans-serif";
            ctx.fillStyle   = "#ffffff88";
            var shortLabel  = s.label.length > 8 ? s.label.substring(0,7) + "…" : s.label;
            ctx.fillText(shortLabel, cx, cy + 12);
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onPositionChanged: function(mouse) {
            if (root.total <= 0) return;
            var cx = root.width  / 2;
            var cy = root.height / 2;
            var dx = mouse.x - cx;
            var dy = mouse.y - cy;
            var dist = Math.sqrt(dx*dx + dy*dy);
            var r    = root.width * 0.38;
            var lw   = root.width * 0.14;
            if (dist < r - lw/2 || dist > r + lw/2 + 6) {
                root.hovered = -1;
                return;
            }
            var angle = Math.atan2(dy, dx) + Math.PI/2;
            if (angle < 0) angle += Math.PI * 2;

            var gap   = 0.025;
            var start = 0.0;
            for (var i = 0; i < root.segments.length; i++) {
                var sweep = (root.segments[i].value / root.total) * (Math.PI*2 - gap*root.segments.length);
                if (angle >= start && angle < start + sweep + gap) {
                    root.hovered = i;
                    return;
                }
                start += sweep + gap;
            }
            root.hovered = -1;
        }
        onExited: root.hovered = -1
    }
}
