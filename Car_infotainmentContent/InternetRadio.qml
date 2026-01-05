import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import Car.Multimedia 1.0

Rectangle {
    id: root

    width: 900
    height: 500
    anchors.centerIn: parent
    radius: 5
    color: "#211e20"

    // State properties
    property bool isLoading: false
    property string currentStationName: "Select a station"
    property string currentStreamUrl: ""
    property string statusMessage: ""

    // ---------------------------------------------------------
    // 1. DATA MODEL
    // ---------------------------------------------------------
    ListModel {
        id: stationModel
    }

    // ---------------------------------------------------------
    // VLC
    // ---------------------------------------------------------
    VlcPlayer {
        id: vlc
    }

    // ---------------------------------------------------------
    // 2. C++ CONNECTIONS
    // ---------------------------------------------------------
    Connections {
        target: internetRadio

        function onStationsDataReceived(stations) {
            root.isLoading = false
            stationModel.clear()

            if (stations.length === 0) {
                root.statusMessage = "No stations found."
                return
            }

            root.statusMessage = "Found " + stations.length + " stations."

            // Append data to the ListModel
            // efficient batch insertion
            for (var i = 0; i < stations.length; i++) {
                var s = stations[i];
                stationModel.append({
                                        "stationuuid": s.stationuuid,
                                        "name": s.name,
                                        "favicon": s.favicon || "", // Handle null
                                        "country": s.country || "Unknown",
                                        "tags": s.tags || ""
                                    });
            }
        }

        function onStreamUrlReceived(uuid, url) {
            root.isLoading = false
            root.currentStreamUrl = url
            vlc.playUrl(url)
        }

        function onErrorOccurred(msg) {
            root.isLoading = false
            root.statusMessage = "Error: " + msg
            console.error(msg)
        }
    }

    // ---------------------------------------------------------
    // 3. MAIN LAYOUT
    // ---------------------------------------------------------
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        // -- Header: Search Bar --
        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: searchInput
                placeholderText: "Search (e.g., Jazz, BBC, Rock)..."
                Layout.fillWidth: true
                color: "white"
                background: Rectangle {
                    color: "#333"
                    radius: 5
                    border.color: searchInput.activeFocus ? "limegreen" : "transparent"
                }
                onAccepted: searchButton.clicked()
            }

            Button {
                id: searchButton
                text: "Search"
                highlighted: true
                enabled: !root.isLoading
                onClicked: {
                    if (searchInput.text.length < 2) return;
                    root.isLoading = true
                    root.statusMessage = "Searching..."
                    internetRadio.searchStations({
                                                     "name": searchInput.text,
                                                     "limit": "50",
                                                     "hidebroken": "true"
                                                 });
                }
            }
        }

        // -- Quick Actions --
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "Top 20"
                onClicked: {
                    root.isLoading = true
                    internetRadio.getTopStations(20)
                }
            }

            Button {
                text: "Local (US)" // Example
                onClicked: {
                    root.isLoading = true
                    internetRadio.searchStations({ "countrycode": "US", "limit": "20" })
                }
            }

            Label {
                text: root.statusMessage
                color: "lightgrey"
                Layout.alignment: Qt.AlignRight
            }
        }

        // -- Station List --
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: stationModel
            spacing: 5

            // ScrollBar
            ScrollBar.vertical: ScrollBar { active: true }

            delegate: ItemDelegate {
                width: ListView.view.width
                height: 60

                background: Rectangle {
                    color: parent.down ? "#444" : "#222"
                    radius: 5
                    border.color: (root.currentStationName === name) ? "limegreen" : "transparent"
                }

                contentItem: RowLayout {
                    spacing: 15

                    // Station Icon
                    Item {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40

                        // 1. Background
                        Image {
                            anchors.fill: parent
                            source: "qrc:/Car_infotainmentContent/icons/placeholder.png"
                            fillMode: Image.PreserveAspectFit
                            opacity: 0.3
                        }

                        // 2. Favicon (Foreground)
                        Image {
                            id: stationIcon
                            anchors.fill: parent

                            // Only try to load if string is not empty
                            source: (favicon && favicon !== "" && favicon !== "null" && (favicon.endsWith(".png") || favicon.endsWith(".jpg") || favicon.endsWith(".jpeg") || favicon.endsWith(".gif") || favicon.endsWith(".svg") || favicon.endsWith(".webp"))) ? favicon : ""
                            fillMode: Image.PreserveAspectFit

                            // Optimizes memory (icons don't need to be huge)
                            sourceSize.width: 64
                            sourceSize.height: 64

                            // If it fails (WebP missing, Insecure Redirect, 404), hide this image
                            visible: status === Image.Ready

                            // Optional: Smooth fading when loaded
                            opacity: status === Image.Ready ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 250 } }

                            // This ensures the cache doesn't hold onto broken redirect entries
                            cache: true
                        }
                    }

                    // Text Info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: name
                            color: "white"
                            font.bold: true
                            font.pixelSize: 16
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: country + (tags ? " • " + tags : "")
                            color: "#aaa"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                onClicked: {
                    root.currentStationName = name
                    root.statusMessage = "Resolving stream..."
                    root.isLoading = true
                    // Call C++ to resolve URL (and count click)
                    internetRadio.getStationStreamUrl(stationuuid)
                }
            }
        }

        // -- Footer: Now Playing Info --
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#111"
            radius: 10
            border.color: "#444"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15

                ColumnLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "NOW SELECTED"
                        color: "limegreen"
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Text {
                        text: root.currentStationName
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Text {
                        text: vlc.currentTitle ? vlc.currentTitle : "No song title"
                        color: "#aaa"
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Button {
                    text: vlc.isPlaying ? "Pause" : "Play"
                    onClicked: {
                        if (vlc.isPlaying) {
                            vlc.pause();
                        } else {
                            vlc.play();
                        }
                    }
                }

                BusyIndicator {
                    running: root.isLoading
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                }
            }
        }
    }
}
