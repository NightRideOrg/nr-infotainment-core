import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Main 1.0

Rectangle {
    id: database
    width: 900
    height: 500
    anchors.centerIn: parent
    radius: 5
    color: "#211e20"

    ProgramModel {
        id: myModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // 1. Input/Simulation Area
        RowLayout {
            Layout.fillWidth: true
            TextField { id: txtPi; placeholderText: "PI Code"; Layout.fillWidth: true }
            TextField { id: txtLabel; placeholderText: "Station Name"; Layout.fillWidth: true }
            Button {
                text: "Refresh"
                onClicked: myModel.refresh()
            }
        }

        // 2. The List (FIXED ANCHORS HERE)
        ListView {
            id: mainListView
            Layout.fillWidth: true
            Layout.fillHeight: true  // Use Layout instead of anchors.fill
            model: myModel
            clip: true
            spacing: 5

            property string selectedId: ""

            delegate: Rectangle {
                // Use a unique ID for the delegate to avoid scoping issues
                id: stationDelegate
                width: mainListView.width
                height: isExpanded ? 200 : 70
                color: "#2d2d2d"
                radius: 4
                clip: true

                readonly property bool isExpanded: mainListView.selectedId === model.programId
                Behavior on height { NumberAnimation { duration: 200 } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Header Row
                    RowLayout {
                        Layout.fillWidth: true
                        Column {
                            Text {
                                text: model.label
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                            }
                            Text {
                                text: "PI: " + model.programId
                                color: "#777"
                                font.pixelSize: 11
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: (model.frequency / 1000).toFixed(1) + " MHz"
                            font.pixelSize: 20
                            color: "#00ff44"
                        }
                    }

                    // Expanded Section (FIXED TYPEERROR HERE)
                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: stationDelegate.isExpanded
                        opacity: stationDelegate.isExpanded ? 1 : 0

                        Text {
                            text: "RDS ALTERNATIVE FREQUENCIES:"
                            color: "#007acc"
                            font.pixelSize: 10
                            font.bold: true
                        }

                        Repeater {
                            // Direct access to the role 'allFrequencies'
                            // Check if it exists and is a list before assigning
                            model: (stationDelegate.isExpanded && typeof allFrequencies !== "undefined") ? allFrequencies : []

                            delegate: RowLayout {
                                Layout.fillWidth: true
                                spacing: 20
                                Text {
                                    text: (modelData.frequency / 1000).toFixed(1) + " MHz"
                                    color: "#eee"
                                    font.family: "Monospace"
                                    Layout.preferredWidth: 80
                                }
                                Text { text: "RSSI: " + modelData.rssi; color: "#888"; font.pixelSize: 11 }
                                Text { text: "SNR: " + modelData.snr; color: "#888"; font.pixelSize: 11 }
                            }
                        }
                    }

                    // Spacer to push content to top
                    Item { Layout.fillHeight: true; visible: stationDelegate.isExpanded }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (mainListView.selectedId === model.programId)
                            mainListView.selectedId = ""
                        else
                            mainListView.selectedId = model.programId
                    }
                }
            }
        }
    }
}
