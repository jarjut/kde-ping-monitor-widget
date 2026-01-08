import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configPage
    
    property alias cfg_targetHost: targetHostField.text
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    
    Kirigami.FormLayout {
        QQC2.TextField {
            id: targetHostField
            Kirigami.FormData.label: "Target host:"
            placeholderText: "e.g., 8.8.8.8 or google.com"
        }
        
        QQC2.SpinBox {
            id: updateIntervalSpinBox
            Kirigami.FormData.label: "Update interval (seconds):"
            from: 1
            to: 300
            stepSize: 1
        }
        
        Item {
            Kirigami.FormData.isSection: true
        }
        
        QQC2.Label {
            text: "The widget will ping the specified host at regular intervals\nand display the latency in the panel."
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
            opacity: 0.7
        }
    }
}
