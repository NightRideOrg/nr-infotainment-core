import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: settings
    width: 800
    height: 800
    anchors.centerIn: parent
    radius: 5
    color: "#211e20"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: tab
            Layout.fillWidth: true
            Layout.preferredHeight: settings.height / 8

            TabButton {
                text: "Android Auto"
                width: implicitWidth
            }
            TabButton {
                text: "Settings"
                width: implicitWidth
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tab.currentIndex

            // Android Auto Tab
            Item {
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20

                    Button {
                        id: pushButtonStartAndroidAuto
                        Layout.preferredHeight: 150
                        Layout.preferredWidth: 300
                        text: "Start Android Auto"
                    }
                    Button {
                        id: pushButtonSettings
                        Layout.preferredHeight: 150
                        Layout.preferredWidth: 300
                        text: "Settings"
                    }
                }
            }

            // Settings Tab
            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    TabBar {
                        id: tab2
                        Layout.fillWidth: true
                        Layout.preferredHeight: settings.height / 8

                        TabButton {
                            text: "Display"
                            width: implicitWidth
                        }
                        TabButton {
                            text: "Audio"
                            width: implicitWidth
                        }
                    }

                    StackLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.bottomMargin: 70
                        currentIndex: tab2.currentIndex

                        // Display Settings
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            GridLayout {
                                width: parent.width
                                columns: 2
                                rowSpacing: 10
                                columnSpacing: 10

                                GroupBox {
                                    title: "Frame rate"
                                    Layout.fillWidth: true
                                    Layout.margins: 10

                                    ColumnLayout {
                                        anchors.fill: parent
                                        RadioButton {
                                            text: "30 FPS"
                                            checked: true
                                        }
                                        RadioButton {
                                            text: "60 FPS"
                                        }
                                    }
                                }

                                GroupBox {
                                    title: "Resolution"
                                    Layout.fillWidth: true
                                    Layout.margins: 10

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 5

                                        RadioButton {
                                            text: "480p"
                                            checked: true
                                        }
                                        RadioButton {
                                            text: "720p"
                                        }
                                        RadioButton {
                                            text: "1080p"
                                        }

                                        Label {
                                            text: "⚠️ 720p and 1080p must be activated in hidden Developer settings of Android Auto application."
                                            Layout.fillWidth: true
                                            Layout.topMargin: 10
                                            font.pixelSize: 10
                                            font.italic: true
                                            wrapMode: Text.Wrap
                                            color: "#cccccc"
                                        }
                                    }
                                }

                                GroupBox {
                                    title: "Display"
                                    Layout.fillWidth: true
                                    Layout.columnSpan: 2
                                    Layout.margins: 10

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 10

                                        GridLayout {
                                            Layout.fillWidth: true
                                            columns: 6
                                            columnSpacing: 10
                                            rowSpacing: 5

                                            Label {
                                                text: "Layer index"
                                                Layout.alignment: Qt.AlignVCenter
                                            }
                                            SpinBox {
                                                value: 1
                                            }

                                            Label {
                                                text: "Margin height"
                                                Layout.alignment: Qt.AlignVCenter
                                            }
                                            SpinBox {
                                                value: 1
                                                to: 99999
                                            }

                                            Label {
                                                text: "Margin width"
                                                Layout.alignment: Qt.AlignVCenter
                                            }
                                            SpinBox {
                                                value: 1
                                                to: 99999
                                            }
                                        }

                                        Label {
                                            text: "ⓘ OMX Layer is used only in case of OMX video output."
                                            Layout.fillWidth: true
                                            font.pointSize: 10
                                            font.italic: true
                                            wrapMode: Text.Wrap
                                            color: "#cccccc"
                                        }
                                    }
                                }

                                GroupBox {
                                    title: "Android Auto Screen DPI"
                                    Layout.fillWidth: true
                                    Layout.columnSpan: 2
                                    Layout.margins: 10

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 10

                                        Label {
                                            text: dpi.value
                                            Layout.preferredWidth: 50
                                        }
                                        Slider {
                                            id: dpi
                                            Layout.fillWidth: true
                                            from: 0
                                            value: 100
                                            stepSize: 1
                                            to: 400
                                        }
                                    }
                                }
                            }
                        }

                        // Audio Settings
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            GridLayout {
                                width: parent.width
                                columns: 2
                                rowSpacing: 10
                                columnSpacing: 10

                                GroupBox {
                                    title: "Audio channels"
                                    Layout.fillWidth: true
                                    Layout.margins: 10

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 10

                                        RowLayout {
                                            CheckBox {
                                                checked: true
                                                text: "Speech channel"
                                            }
                                            CheckBox {
                                                checked: true
                                                text: "Music channel"
                                            }
                                        }

                                        Label {
                                            text: "ⓘ Disable audio channel if you need custom audio routing e.g. via A2DP or AUX."
                                            Layout.fillWidth: true
                                            font.pointSize: 10
                                            font.italic: true
                                            wrapMode: Text.Wrap
                                            color: "#cccccc"
                                        }
                                    }
                                }

                                GroupBox {
                                    title: "Output backend"
                                    Layout.fillWidth: true
                                    Layout.margins: 10

                                    RowLayout {
                                        anchors.fill: parent
                                        RadioButton {
                                            checked: true
                                            text: "RT audio"
                                        }
                                        RadioButton {
                                            text: "Qt"
                                        }
                                    }
                                }

                                GroupBox {
                                    title: "Pulseaudio Input / Output Device"
                                    Layout.fillWidth: true
                                    Layout.columnSpan: 2
                                    Layout.margins: 10

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 10

                                        RowLayout {
                                            Label {
                                                text: "Output"
                                                Layout.preferredWidth: 60
                                            }
                                            ComboBox {
                                                Layout.fillWidth: true
                                                model: settingsProvider.outputDevices
                                            }
                                        }

                                        RowLayout {
                                            Label {
                                                text: "Input"
                                                Layout.preferredWidth: 60
                                            }
                                            ComboBox {
                                                Layout.fillWidth: true
                                                model: settingsProvider.inputDevices
                                            }
                                        }

                                        RowLayout {
                                            Button {
                                                text: "Refresh Devices"
                                                onClicked: settingsProvider.refreshAudioDevices()
                                            }
                                            Button {
                                                text: "Test"
                                                onClicked: settingsProvider.onAudioTestClicked()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bottom Action Buttons (only in Settings tab)
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        Layout.margins: 10
                        spacing: 10

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            id: pushButtonSave
                            text: "Save"
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40

                            background: Rectangle {
                                color: pushButtonSave.down ? "#5ca70d" : (pushButtonSave.hovered ? "#73d216" : "#4e9a06")
                                radius: 4
                                border.color: pushButtonSave.down ? "#3d6b08" : "#4e9a06"
                                border.width: 1
                            }

                            contentItem: Text {
                                text: pushButtonSave.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }

                        Button {
                            id: pushButtonCancel
                            text: "Cancel"
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 40

                            background: Rectangle {
                                color: pushButtonCancel.down ? "#a40000" : (pushButtonCancel.hovered ? "#ef2929" : "#cc0000")
                                radius: 4
                                border.color: pushButtonCancel.down ? "#8f0000" : "#cc0000"
                                border.width: 1
                            }

                            contentItem: Text {
                                text: pushButtonCancel.text
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
