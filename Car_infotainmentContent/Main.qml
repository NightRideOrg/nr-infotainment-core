import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

// Wichtig: Stellen Sie sicher, dass Qt Design Studio/Ihr Projekt Taskbar.qml finden kann.
// Wenn Taskbar.qml im selben Ordner wie main.qml liegt, ist kein spezieller Import nötig.
// Ansonsten: import "./components" o.ä. und Taskbar.qml in den Ordner components legen.
import QtQuick.Studio.Components 1.0

Rectangle { // Oder Rectangle, wenn dies eine Komponente ist
    width: 1920
    height: 1080 // Angepasst für Demozwecke
    visible: true
    color: "#a9a9a9"

    Image {
        id: image
        x: 0
        y: 0
        width: 1920
        height: 1080
        source: "../../Downloads/1239183-3840x2160-desktop-4k-green-forest-background-photo.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    Item {
            id: taskbarBlurBackground
            y: 920
            width: 1920
            height: 160
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            // ShaderEffectSource für den Blur-Effekt
            ShaderEffectSource {
                id: effectSource
                sourceItem: image  // Verweis auf das Hintergrundbild
                anchors.fill: parent
                sourceRect: Qt.rect(0, parent.parent.height - parent.height, parent.width, parent.height)
                live: true
            }

            // FastBlur für den Blur-Effekt
            FastBlur {
                id: blur
                anchors.fill: effectSource
                source: effectSource
                radius: 64  // Stärke des Blur-Effekts, anpassbar
                cached: true
            }

            // Halbtransparentes Overlay für besseren Kontrast
            Rectangle {
                anchors.fill: parent
                color: "#50000000"  // Schwarz mit 50% Opacity
                opacity: 0.7
            }
        }


    // Instanz Ihrer Taskleiste

    Taskbar {
        id: myAppTaskbar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20

        // Auf Signale reagieren
        onDynamicIconClicked: (itemName, iconSource) => {
                                  console.log("MAIN: Dynamisches Icon geklickt: " + itemName + ", Quelle: " + iconSource);
                                  // Hier könnten Sie z.B. eine App starten oder eine Ansicht wechseln
                              }
        onAppDrawerClicked: () => {
                                console.log("MAIN: App Drawer wurde geklickt!");
                                // Hier die Logik für den App Drawer implementieren
                            }
    }

    // Steuerungs-Buttons zum Demonstrieren


    ColumnLayout {
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Button {
            text: "Spotify hinzufügen"
            onClicked: {
                // Annahme: Sie haben Icons im qrc unter /app_icons/
                myAppTaskbar.addIcon("Spotify", "icons/Spotify.png", "limegreen");
            }
        }
        Button {
            text: "Karten hinzufügen"
            onClicked: {
                myAppTaskbar.addIcon("Karten", "icons/map.png", "tomato");
            }
        }
        Button {
            text: "Spotify2 hinzufügen"
            onClicked: {
                myAppTaskbar.addIcon("Spotify2", "icons/map.png", "tomato");
            }
        }
        Button {
            text: "Spotify3 hinzufügen"
            onClicked: {
                myAppTaskbar.addIcon("Spotify3", "icons/map.png", "tomato");
            }
        }
        Button {
            text: "Navigation hinzufügen"
            onClicked: {
                myAppTaskbar.addIcon("Navigation", "icons/placeholder.png", "dodgerblue");
            }
        }
        Button {
            text: "Spotify entfernen"
            onClicked: {
                myAppTaskbar.removeIconByName("Spotify");
            }
        }
        Button {
            text: "Letztes dyn. Icon entfernen"
            onClicked: {
                myAppTaskbar.removeLastDynamicIcon();
            }
        }
        Button {
            text: "Entferne 1. dyn. Icon (Index 0)"
            onClicked: {
                myAppTaskbar.removeIconByIndex(0);
            }
        }
    }


}


