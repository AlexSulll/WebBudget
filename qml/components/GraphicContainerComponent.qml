import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: graphic

    width: parent.width
    height: 600
    clip: true
    anchors.top: fullStaticCard.bottom

    property real pulseSize: 1.0
    property real pulseOpacity: 0.3
    property int selectedYear: new Date().getFullYear()

    onVisibleChanged: {
        if (visible && chartCanvas) {
            chartCanvas.requestPaint();
        }
    }

    Component.onCompleted: {
        chartCanvas.requestPaint();
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Theme.rgba("#24224f", 0.4)
        border.width: 0.5
        radius: Theme.paddingMedium
    }

    Row {
        id: topPanel
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.paddingMedium
        }
        spacing: Theme.paddingMedium

        IconButton {
            id: graphSettingsButton
            icon.source: allowedOrientations === Orientation.All ? "image://theme/icon-l-gesture" : ""
            icon.color: "#24224f"
            z: 50
            visible: true
            enabled: true

            onClicked: {
                pageStack.push(Qt.resolvedUrl("FullscreenGraphic.qml"), {
                    "timeSeriesData": timeSeriesData,
                    "selectedMonthData": selectedMonthData
                });
            }
        }
    }
    SilicaFlickable {
        id: chartFlickable
        anchors {
            top: topPanel.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: Theme.paddingMedium
        }
        contentWidth: chartContainer.width
        interactive: contentWidth > width

        Item {
            id: chartContainer
            width: Math.max(chartFlickable.width, timeSeriesData.length * 200 + 40)
            height: parent.height

            Canvas {
                id: chartCanvas
                anchors.fill: parent

                property var clickAreas: ({})
                property var highlightedPoint: -1

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.reset();

                    if (!timeSeriesData || timeSeriesData.length === 0)
                        return;

                    var maxValue = Math.max(10000, Math.max.apply(null, timeSeriesData.map(function (d) {
                        return Math.max(d.value, d.target || 0);
                    })));

                    var availableWidth = width - 80;
                    var xStep = timeSeriesData.length > 1 ? availableWidth / (timeSeriesData.length - 1) : 0;
                    var chartBottom = height - 50;
                    var chartTop = 50;

                    var points = [];

                    for (var i = 0; i < timeSeriesData.length; i++) {
                        var x = timeSeriesData.length > 1 ? 40 + i * xStep : width / 2;
                        var y = chartBottom - ((timeSeriesData[i].value || 0.0001) / maxValue * (height * 0.6));
                        points.push({
                            x: x,
                            y: y
                        });
                    }

                    if (timeSeriesData.length > 1) {
                        ctx.beginPath();
                        ctx.moveTo(40, chartBottom);

                        for (var j = 0; j < points.length; j++) {
                            ctx.lineTo(points[j].x, points[j].y);
                        }

                        ctx.lineTo(40 + (timeSeriesData.length - 1) * xStep, chartBottom);
                        ctx.closePath();

                        var gradient = ctx.createLinearGradient(0, chartTop, 0, chartBottom);
                        gradient.addColorStop(0, Theme.rgba("#3a3a8f", 0.25));
                        gradient.addColorStop(0.5, Theme.rgba("#3a3a8f", 0.15));
                        gradient.addColorStop(1, Theme.rgba("#3a3a8f", 0.05));
                        ctx.fillStyle = gradient;
                        ctx.fill();

                        var glowGradient = ctx.createLinearGradient(0, chartTop, 0, chartBottom);
                        glowGradient.addColorStop(0, Theme.rgba("#6a6acf", 0.1));
                        glowGradient.addColorStop(1, "transparent");
                        ctx.fillStyle = glowGradient;
                        ctx.fill();
                    }

                    if (timeSeriesData.length > 1) {
                        ctx.beginPath();
                        ctx.moveTo(points[0].x, points[0].y);

                        for (var l = 1; l < points.length; l++) {
                            ctx.lineTo(points[l].x, points[l].y);
                        }

                        var lineGradient = ctx.createLinearGradient(0, chartTop, 0, chartBottom);
                        lineGradient.addColorStop(0, "#6a6acf");
                        lineGradient.addColorStop(1, "#24224f");

                        ctx.strokeStyle = lineGradient;
                        ctx.lineWidth = 4;
                        ctx.lineJoin = "round";
                        ctx.shadowColor = Theme.rgba("#6a6acf", 0.4);
                        ctx.shadowBlur = 10;
                        ctx.stroke();
                        ctx.shadowBlur = 0;
                    }

                    clickAreas = {};

                    for (var k = 0; k < timeSeriesData.length; k++) {
                        var x = points[k].x;
                        var y = points[k].y;

                        if (k === highlightedPoint || highlightedPoint === -1) {
                            ctx.shadowColor = Theme.rgba("#24224f", pulseOpacity);
                            ctx.shadowBlur = 15 * pulseSize;
                            ctx.beginPath();
                            ctx.arc(x, y, 20 * pulseSize, 0, Math.PI * 2);
                            ctx.fillStyle = Theme.rgba("#24224f", pulseOpacity * 0.7);
                            ctx.fill();
                            ctx.shadowBlur = 0;

                            ctx.shadowColor = Theme.rgba("#24224f", pulseOpacity * 0.5);
                            ctx.shadowBlur = 25 * (pulseSize * 0.7);
                            ctx.beginPath();
                            ctx.arc(x, y, 30 * (pulseSize * 0.7), 0, Math.PI * 2);
                            ctx.fillStyle = "transparent";
                            ctx.fill();
                            ctx.shadowBlur = 0;
                        }

                        ctx.shadowColor = Theme.rgba("#24224f", 0.3);
                        ctx.shadowBlur = 8;
                        ctx.beginPath();
                        ctx.arc(x, y, 12 * (k === highlightedPoint ? pulseSize * 1.2 : 1), 0, Math.PI * 2);
                        ctx.fillStyle = "white";
                        ctx.fill();
                        ctx.shadowBlur = 0;

                        var pointSize = 10 * (k === highlightedPoint ? pulseSize * 1.1 : 1);
                        ctx.beginPath();
                        ctx.arc(x, y, pointSize, 0, Math.PI * 2);
                        ctx.fillStyle = "#24224f";
                        ctx.fill();

                        ctx.fillStyle = Theme.rgba("#24224f", 0.8);
                        ctx.font = "bold " + Theme.fontSizeSmall * 0.6 + "px sans-serif";
                        ctx.textAlign = "center";
                        ctx.fillText(timeSeriesData[k].month + "," + timeSeriesData[k].year, x, height - 20);

                        var valueText = (timeSeriesData[k].value / 1000).toFixed(1) + "k";
                        if (k === highlightedPoint || highlightedPoint === -1) {
                            ctx.beginPath();
                            ctx.arc(x, y - 30, 20 * (k === highlightedPoint ? pulseSize * 1.1 : 1), 0, Math.PI * 2);
                            ctx.fillStyle = "white";
                            ctx.fill();
                            ctx.strokeStyle = "#24224f";
                            ctx.lineWidth = 1.5;
                            ctx.stroke();

                            ctx.shadowColor = Theme.rgba("#24224f", 0.2);
                            ctx.shadowBlur = 5 * (k === highlightedPoint ? pulseSize : 1);
                            ctx.fill();
                            ctx.shadowBlur = 0;
                        }

                        ctx.fillStyle = "#24224f";
                        ctx.font = "bold " + Theme.fontSizeExtraSmall * 0.8 + "px sans-serif";
                        ctx.textAlign = "center";
                        ctx.fillText(valueText, x, y - 28);

                        clickAreas[k] = {
                            x: x,
                            y: y,
                            radius: 50,
                            data: timeSeriesData[k]
                        };
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if (!containsMouse) {
                            chartCanvas.highlightedPoint = -1;
                            chartCanvas.requestPaint();
                        }
                    }

                    onPositionChanged: {
                        for (var i in chartCanvas.clickAreas) {
                            var area = chartCanvas.clickAreas[i];
                            var dx = mouse.x - area.x;
                            var dy = mouse.y - area.y;
                            if (Math.sqrt(dx * dx + dy * dy) <= area.radius) {
                                if (chartCanvas.highlightedPoint != i) {
                                    chartCanvas.highlightedPoint = i;
                                    chartCanvas.requestPaint();
                                }
                                return;
                            }
                        }

                        if (chartCanvas.highlightedPoint != -1) {
                            chartCanvas.highlightedPoint = -1;
                            chartCanvas.requestPaint();
                        }
                    }

                    onClicked: {
                        for (var i in chartCanvas.clickAreas) {
                            var area = chartCanvas.clickAreas[i];
                            var dx = mouse.x - area.x;
                            var dy = mouse.y - area.y;

                            if (Math.sqrt(dx * dx + dy * dy) <= area.radius) {
                                selectedMonthData = area.data;
                                showMonthPopup = true;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}
