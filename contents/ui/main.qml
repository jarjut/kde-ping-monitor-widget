import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

PlasmoidItem {
    id: root
    
    property string pingTime: "..."
    property bool pingError: false
    property string targetHost: plasmoid.configuration.targetHost
    property var pingHistory: []
    property int maxHistorySize: 30
    
    function getPingColor() {
        if (root.pingError) return Kirigami.Theme.negativeTextColor
        var ping = parseInt(root.pingTime)
        if (ping < 60) return Kirigami.Theme.positiveTextColor
        if (ping < 150) return Kirigami.Theme.neutralTextColor
        return Kirigami.Theme.negativeTextColor
    }
    
    function addPingToHistory(ping, isError) {
        var history = root.pingHistory.slice()
        history.push({
            value: ping,
            timestamp: Date.now(),
            error: isError || false
        })
        
        // Keep only last maxHistorySize entries
        if (history.length > root.maxHistorySize) {
            history.shift()
        }
        
        root.pingHistory = history
        
        // Trigger canvas repaint if it exists and is ready
        if (typeof pingChart !== 'undefined' && pingChart.chartReady) {
            pingChart.requestPaint()
        }
    }
    
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    
    preferredRepresentation: compactRepresentation
    
    compactRepresentation: Item {
        Layout.fillHeight: true
        Layout.minimumWidth: contentRow.implicitWidth
        Layout.maximumWidth: contentRow.implicitWidth
        
        RowLayout {
            id: contentRow
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing
            
            Kirigami.Icon {
                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                Layout.preferredHeight: Kirigami.Units.iconSizes.small
                source: root.pingError ? "network-disconnect" : "network-wired"
                color: root.getPingColor()
            }
            
            PlasmaComponents.Label {
                id: label
                text: root.pingTime + "ms"
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }
    
    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumHeight: Kirigami.Units.gridUnit * 15
        Layout.preferredWidth: Kirigami.Units.gridUnit * 30
        Layout.preferredHeight: Kirigami.Units.gridUnit * 20
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing
            
            PlasmaComponents.Label {
                text: "Ping Monitor"
                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.5
                font.bold: true
            }
            
            GridLayout {
                columns: 2
                columnSpacing: Kirigami.Units.largeSpacing
                rowSpacing: Kirigami.Units.smallSpacing
                
                PlasmaComponents.Label {
                    text: "Host:"
                    font.bold: true
                }
                PlasmaComponents.Label {
                    text: root.targetHost
                }
                
                PlasmaComponents.Label {
                    text: "Current Ping:"
                    font.bold: true
                }
                PlasmaComponents.Label {
                    text: root.pingTime + "ms"
                    color: root.getPingColor()
                }
                
                PlasmaComponents.Label {
                    text: "Status:"
                    font.bold: true
                }
                PlasmaComponents.Label {
                    text: root.pingError ? "Error / Timeout" : "Connected"
                    color: root.pingError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.positiveTextColor
                }
            }
            
            // Ping History Chart
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Kirigami.Units.smallSpacing
                
                PlasmaComponents.Label {
                    text: "Ping History"
                    font.bold: true
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: Kirigami.Units.gridUnit * 8
                    color: Qt.rgba(Kirigami.Theme.backgroundColor.r, 
                                   Kirigami.Theme.backgroundColor.g, 
                                   Kirigami.Theme.backgroundColor.b, 0.3)
                    border.color: Kirigami.Theme.textColor
                    border.width: 1
                    radius: 4
                    
                    Canvas {
                        id: pingChart
                        anchors.fill: parent
                        anchors.margins: 10
                        renderStrategy: Canvas.Threaded
                        renderTarget: Canvas.FramebufferObject
                        
                        property bool chartReady: false
                        
                        Component.onCompleted: {
                            chartReady = true
                        }
                        
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        
                        onPaint: {
                            if (!chartReady || width <= 0 || height <= 0) {
                                return
                            }
                            
                            var ctx = getContext("2d")
                            if (!ctx) {
                                return
                            }
                            
                            ctx.reset()
                            ctx.clearRect(0, 0, width, height)
                            
                            if (root.pingHistory.length < 2) {
                                return
                            }
                            
                            // Find min and max values for scaling
                            var minPing = 0
                            var maxPing = 200
                            
                            for (var i = 0; i < root.pingHistory.length; i++) {
                                var val = root.pingHistory[i].value
                                if (val > maxPing) maxPing = val
                            }
                            
                            // Add some padding to max
                            maxPing = Math.ceil(maxPing * 1.2)
                            
                            // Draw grid lines
                            ctx.strokeStyle = Qt.rgba(Kirigami.Theme.textColor.r,
                                                     Kirigami.Theme.textColor.g,
                                                     Kirigami.Theme.textColor.b, 0.2)
                            ctx.lineWidth = 1
                            
                            for (var j = 0; j <= 4; j++) {
                                var y = height - (height / 4) * j
                                ctx.beginPath()
                                ctx.moveTo(0, y)
                                ctx.lineTo(width, y)
                                ctx.stroke()
                            }
                            
                            // Draw reference lines for thresholds
                            ctx.strokeStyle = Qt.rgba(Kirigami.Theme.positiveTextColor.r,
                                                     Kirigami.Theme.positiveTextColor.g,
                                                     Kirigami.Theme.positiveTextColor.b, 0.3)
                            ctx.setLineDash([5, 5])
                            var y60 = height - (60 / maxPing) * height
                            ctx.beginPath()
                            ctx.moveTo(0, y60)
                            ctx.lineTo(width, y60)
                            ctx.stroke()
                            
                            ctx.strokeStyle = Qt.rgba(Kirigami.Theme.neutralTextColor.r,
                                                     Kirigami.Theme.neutralTextColor.g,
                                                     Kirigami.Theme.neutralTextColor.b, 0.3)
                            var y150 = height - (150 / maxPing) * height
                            ctx.beginPath()
                            ctx.moveTo(0, y150)
                            ctx.lineTo(width, y150)
                            ctx.stroke()
                            
                            ctx.setLineDash([])
                            
                            // Calculate drawing area with padding
                            var chartPadding = width * 0.05  // 5% padding
                            var chartWidth = width - chartPadding
                            var dataPoints = Math.min(root.pingHistory.length, root.maxHistorySize)
                            
                            // Draw ping line (with disconnections for timeouts)
                            ctx.strokeStyle = Kirigami.Theme.highlightColor
                            ctx.lineWidth = 2
                            
                            // Always draw as if we have maxHistorySize points
                            var stepX = chartWidth / (root.maxHistorySize - 1)
                            var startIndex = Math.max(0, dataPoints - root.maxHistorySize)
                            
                            var inPath = false
                            for (var k = 0; k < dataPoints; k++) {
                                var entry = root.pingHistory[k]
                                var pointPosition = (root.maxHistorySize - dataPoints) + k
                                var x = chartPadding + (pointPosition * stepX)
                                
                                if (entry.error || entry.value === null) {
                                    // End current path if we were drawing
                                    if (inPath) {
                                        ctx.stroke()
                                        inPath = false
                                    }
                                    continue
                                }
                                
                                var pingVal = entry.value
                                var y = height - (pingVal / maxPing) * height
                                
                                if (!inPath) {
                                    ctx.beginPath()
                                    ctx.moveTo(x, y)
                                    inPath = true
                                } else {
                                    ctx.lineTo(x, y)
                                }
                            }
                            
                            // Finish the last path if we were drawing
                            if (inPath) {
                                ctx.stroke()
                            }
                            
                            // Draw points
                            for (var l = 0; l < dataPoints; l++) {
                                var pointEntry = root.pingHistory[l]
                                var pointPosition = (root.maxHistorySize - dataPoints) + l
                                var pointX = chartPadding + (pointPosition * stepX)
                                
                                // Handle error/timeout points
                                if (pointEntry.error || pointEntry.value === null) {
                                    // Draw X mark for timeouts
                                    ctx.strokeStyle = Kirigami.Theme.negativeTextColor
                                    ctx.lineWidth = 2
                                    var size = 4
                                    var pointY = height / 2  // Center vertically
                                    ctx.beginPath()
                                    ctx.moveTo(pointX - size, pointY - size)
                                    ctx.lineTo(pointX + size, pointY + size)
                                    ctx.moveTo(pointX + size, pointY - size)
                                    ctx.lineTo(pointX - size, pointY + size)
                                    ctx.stroke()
                                    continue
                                }
                                
                                var pointVal = pointEntry.value
                                var pointY = height - (pointVal / maxPing) * height
                                
                                // Color code points
                                if (pointVal < 60) {
                                    ctx.fillStyle = Kirigami.Theme.positiveTextColor
                                } else if (pointVal < 150) {
                                    ctx.fillStyle = Kirigami.Theme.neutralTextColor
                                } else {
                                    ctx.fillStyle = Kirigami.Theme.negativeTextColor
                                }
                                
                                ctx.beginPath()
                                ctx.arc(pointX, pointY, 3, 0, 2 * Math.PI)
                                ctx.fill()
                            }
                            
                            // Draw scale labels
                            ctx.fillStyle = Kirigami.Theme.textColor
                            ctx.font = "10px sans-serif"
                            
                            // Draw labels for each grid line
                            for (var m = 0; m <= 4; m++) {
                                var labelY = height - (height / 4) * m
                                var labelValue = Math.round((maxPing / 4) * m)
                                ctx.fillText(labelValue + "ms", 5, labelY + 4)
                            }
                        }
                        
                        Connections {
                            target: root
                            function onPingHistoryChanged() {
                                pingChart.requestPaint()
                            }
                        }
                    }
                    
                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: "Collecting data..."
                        visible: root.pingHistory.length < 2
                        opacity: 0.5
                    }
                }
                
                // Legend
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Kirigami.Units.largeSpacing
                    
                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Rectangle {
                            width: 12
                            height: 12
                            color: Kirigami.Theme.positiveTextColor
                            radius: 2
                        }
                        PlasmaComponents.Label {
                            text: "< 60ms"
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }
                    
                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Rectangle {
                            width: 12
                            height: 12
                            color: Kirigami.Theme.neutralTextColor
                            radius: 2
                        }
                        PlasmaComponents.Label {
                            text: "60-150ms"
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }
                    
                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Rectangle {
                            width: 12
                            height: 12
                            color: Kirigami.Theme.negativeTextColor
                            radius: 2
                        }
                        PlasmaComponents.Label {
                            text: "> 150ms"
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
            
            PlasmaComponents.Button {
                Layout.alignment: Qt.AlignHCenter
                text: "Configure"
                icon.name: "configure"
                onClicked: plasmoid.internalAction("configure").trigger()
            }
        }
    }
    
    // Ping execution
    Plasma5Support.DataSource {
        id: pingDataSource
        engine: "executable"
        connectedSources: []
        
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
            
            if (data["exit code"] === 0) {
                // Parse ping output
                var output = data.stdout
                var match = output.match(/time=([0-9.]+)\s*ms/)
                if (match) {
                    var pingValue = parseFloat(match[1])
                    root.pingTime = pingValue.toFixed(1)
                    root.pingError = false
                    root.addPingToHistory(pingValue)
                } else {
                    root.pingTime = "N/A"
                    root.pingError = true
                    root.addPingToHistory(null, true)
                }
            } else {
                root.pingTime = "Error"
                root.pingError = true
                root.addPingToHistory(null, true)
            }
        }
    }
    
    Timer {
        interval: plasmoid.configuration.updateInterval * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            // Execute ping command
            var cmd = "ping -c 1 -W 2 " + root.targetHost
            pingDataSource.connectSource(cmd)
        }
    }
}
