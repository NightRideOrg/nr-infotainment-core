import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick3D

// Wichtig: Stellen Sie sicher, dass Qt Design Studio/Ihr Projekt Taskbar.qml finden kann.
// Wenn Taskbar.qml im selben Ordner wie main.qml liegt, ist kein spezieller Import nötig.
// Ansonsten: import "./components" o.ä. und Taskbar.qml in den Ordner components legen.
import QtQuick.Studio.Components 1.0
import QtQuick.Studio.DesignEffects

import QtQuick.Scene3D
import "./3d"

Window { // Oder Rectangle, wenn dies eine Komponente ist
    id: mainRoot
    width: 1920
    height: 1080 // Angepasst für Demozwecke
    visible: true
    color: "#a9a9a9"
    property int speed: 20
    property bool show_rpm: false
    property int rpm: 7000
    property string rpmColor: "#ffffff"

    Image {
        id: image
        x: 0
        y: 0
        width: 1920
        height: 1080
        source: "../Images/1239183-3840x2160-desktop-4k-green-forest-background-photo.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    Item {
        id: window
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        height: parent.height - 160

        Item {
            id: puremaps
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width / 2

            Image {
                id: puremap
                source: "../Images/pure-maps2.png"
                anchors.fill: parent
                fillMode: Image.Pad
            }
        }
        Item {
            id: car
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width / 2


            Item {
                id: speed
                width: 281
                height: 318

                Rectangle {
                    id: rectangle
                    anchors.centerIn: parent // Rechteck ist der Ankerpunkt
                    width: speedtext.width
                    height: 8
                    color: "#ffffff"
                    border.width: 1
                    DesignEffect {
                        visible: true
                        backgroundBlurVisible: true
                        layerBlurVisible: false
                        effects: [
                            DesignDropShadow {
                                showBehind: true
                            }
                        ]
                    }
                }

                Text {
                    id: speedtext
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: rectangle.top // Anker an Oberkante Rechteck
                    anchors.bottomMargin: -10 // Gewünschter Abstand
                    color: "#ffffff"
                    text: mainRoot.speed
                    font.pixelSize: 70
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
                    layer.enabled: true
                    enabled: true
                    smooth: true
                    antialiasing: true
                    font.family: "Abel"
                    style: Text.Outline
                    styleColor: "#000000"

                    DesignEffect {
                        visible: true
                        backgroundBlurVisible: true
                        layerBlurVisible: false
                        effects: [
                            DesignDropShadow {
                                showBehind: true
                            }
                        ]
                    }

                }
                Text {
                    id: kmh
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: rectangle.bottom // Anker an Unterkante Rechteck
                    anchors.topMargin: -2
                    width: contentWidth
                    height: contentHeight
                    color: "#ffffff"
                    text: qsTr("Km/h")
                    font.pixelSize: 40
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    layer.enabled: true
                    enabled: true
                    smooth: true
                    antialiasing: true
                    font.family: "Abel"
                    style: Text.Outline
                    styleColor: "#000000"

                    DesignEffect {
                        visible: true
                        backgroundBlurVisible: true
                        layerBlurVisible: false
                        effects: [
                            DesignDropShadow {
                                showBehind: true
                            }
                        ]
                    }
                }
            }
            Item {
                id: rpm
                x: 679
                y: 0
                width: 281
                height: 318

                Rectangle {
                    id: rpmRectangle
                    anchors.centerIn: parent // Rechteck ist der Ankerpunkt
                    width: rpmText.width
                    height: 8
                    color: mainRoot.rpmColor
                    border.width: 1
                    DesignEffect {
                        visible: true
                        backgroundBlurVisible: true
                        layerBlurVisible: false
                        effects: [
                            DesignDropShadow {
                                showBehind: true
                            }
                        ]
                    }
                }

                Text {
                    id: rpmText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: rpmRectangle.top // Anker an Oberkante Rechteck
                    anchors.bottomMargin: -10 // Gewünschter Abstand
                    color: mainRoot.rpmColor
                    text: mainRoot.rpm
                    font.pixelSize: 70
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
                    layer.enabled: true
                    enabled: true
                    smooth: true
                    antialiasing: true
                    font.family: "Abel"
                    style: Text.Outline
                    styleColor: "#000000"

                    DesignEffect {
                        visible: true
                        backgroundBlurVisible: true
                        layerBlurVisible: false
                        effects: [
                            DesignDropShadow {
                                showBehind: true
                            }
                        ]
                    }

                }
                Text {
                    id: rpmText2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: rpmRectangle.bottom // Anker an Unterkante Rechteck
                    anchors.topMargin: -2
                    width: contentWidth
                    height: contentHeight
                    color: mainRoot.rpmColor
                    text: qsTr("RPM")
                    font.pixelSize: 40
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    layer.enabled: true
                    enabled: true
                    smooth: true
                    antialiasing: true
                    font.family: "Abel"
                    style: Text.Outline
                    styleColor: "#000000"

                    DesignEffect {
                        visible: true
                        backgroundBlurVisible: true
                        layerBlurVisible: false
                        effects: [
                            DesignDropShadow {
                                showBehind: true
                            }
                        ]
                    }
                }
            }

            Item {
                anchors.fill: parent

                Node {
                    id: standAloneScene
                    DirectionalLight { ambientColor: Qt.rgba(1.0, 1.0, 1.0, 1.0) }
                    Node {
                        id: node
                        Model {
                            id: model
                            source: "#Cube"
                            materials: [
                                DefaultMaterial { diffuseColor: Qt.rgba(0.053, 0.130, 0.219, 1) }
                            ]
                        }
                    }
                    OrthographicCamera {
                        id: cameraOrthographicFront
                        y: 500; z: 1000
                        lookAtNode: node
                    }
                }
                View3D {
                    anchors.fill: parent
                    importScene: standAloneScene
                    camera: cameraOrthographicFront
                }
                MouseArea {
                    anchors.fill:parent
                    property real pressedX
                    property real pressedY
                    onMouseXChanged: Qt.callLater(update)
                    onMouseYChanged: Qt.callLater(update)
                    onPressed: {
                        [pressedX,pressedY] = [mouseX,mouseY];
                    }
                    function update() {
                        let [dx,dy] = [mouseX - pressedX,mouseY - pressedY];
                        [pressedX,pressedY] = [mouseX,mouseY];
                        node.rotate(dx, Qt.vector3d(0, 1, 0), Node.SceneSpace);
                        node.rotate(dy, Qt.vector3d(1, 0, 0), Node.SceneSpace);
                    }
                }

                Item {
                    id: __materialLibrary__
                }
            }
        }
    }

    AppMenuGridView {
        id: appMenu
        objectName: "appMenu"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 200
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


    Rectangle {
        id: climateRoot
        anchors.left: taskbarBlurBackground.left // Anker an Unterkante Rechteck
        anchors.verticalCenter: taskbarBlurBackground.verticalCenter
        anchors.leftMargin: 250
        // Dynamische Breite basierend auf dem Inhalt des RowLayout + 20px Puffer
        width: rowLayout.implicitWidth + 20
        height: 100
        color: "#AA202020"
        radius: 25

        // Temperatur von C++ Backend
        property real temperature: climateProvider.temperature
        property string languageInternal: "de"
        property alias language: climateRoot.languageInternal

        function temperatureF() {
            return climateRoot.temperature * 9 / 5 + 32;
        }

        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: 20

            Image {
                id: fanImage
                source: "icons/fan.png"
                sourceSize.height: 65
                sourceSize.width: 65
                width: 65
                height: 65
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                antialiasing: true
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                Text {
                    id: tempText
                    text: {
                        if (isNaN(climateRoot.temperature)) return "--";
                        if (languageManager.currentLanguage === "de") {
                            return Number(climateRoot.temperature).toFixed(1) + " " + qsTr("°C");
                        } else {
                            return Number(climateRoot.temperatureF()).toFixed(1) + " " + qsTr("°F");
                        }
                    }
                    font.pixelSize: 38
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: qsTr("Climate")
                    font.pixelSize: 18
                    color: "#cccccc"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
    Rectangle {
        id: volumeRoot
        anchors.right: taskbarBlurBackground.right // Anker an Unterkante Rechteck
        anchors.verticalCenter: taskbarBlurBackground.verticalCenter
        anchors.rightMargin: 250
        // Dynamische Breite basierend auf dem Inhalt des RowLayout + 20px Puffer
        width: volRowLayout.implicitWidth + 20
        height: 100
        color: "#AA202020"
        radius: 25

        // Temperatur von C++ Backend
        property real volume: volumeProvider.volume

        RowLayout {
            id: volRowLayout
            anchors.centerIn: parent
            spacing: 20

            Image {
                id: speakerImage
                source: "icons/volume.png"
                sourceSize.height: 65
                sourceSize.width: 65
                width: 65
                height: 65
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                antialiasing: true
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter

                Text {
                    id: volText
                    text: isNaN(volumeRoot.volume)
                          ? "--"
                          : Number(volumeRoot.volume).toFixed(0) + " %"
                    font.pixelSize: 38
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: qsTr("Volume")
                    font.pixelSize: 18
                    color: "#cccccc"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Taskbar {
        id: myAppTaskbar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: taskbarBlurBackground.verticalCenter
        height: 100

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
        TextField {
            id: appIdInput
            placeholderText: "App-ID eingeben (z. B. YouTube)"
            onAccepted: {
                if (text.length > 0) {
                    appProvider.addApp(text, "qrc:/Car_infotainmentContent/icons/placeholder.png", "#FF0000");
                } else {
                    console.log("Bitte eine App-ID eingeben.");
                }
            }
        }
    }

}





/*##^##
Designer {
    D{i:0}D{i:27;cameraSpeed3d:25;cameraSpeed3dMultiplier:1}
}
##^##*/
