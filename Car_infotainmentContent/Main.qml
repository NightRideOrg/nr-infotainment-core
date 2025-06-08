import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick3D
import QtWayland.Compositor
import QtWayland.Compositor.XdgShell
import io.qt.examples.customextension 1.0

// Wichtig: Stellen Sie sicher, dass Qt Design Studio/Ihr Projekt Taskbar.qml finden kann.
// Wenn Taskbar.qml im selben Ordner wie main.qml liegt, ist kein spezieller Import nötig.
// Ansonsten: import "./components" o.ä. und Taskbar.qml in den Ordner components legen.
// import QtQuick.Studio.Components 1.0
// import QtQuick.Studio.DesignEffects

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
        source: "qrc:/Images/1239183-3840x2160-desktop-4k-green-forest-background-photo.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    Item {
        id: window
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        height: parent.height - 160

        // Replace the SurfaceAggregator with a proper compositor setup
        Item {
            id: puremaps
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width / 2
            clip: true // Verhindert, dass der Inhalt über die Grenzen hinaus gezeichnet wird

            // --- Fixed: Use Rectangle as base container instead of SurfaceAggregator ---
            Rectangle {
                id: compositorSurface
                anchors.fill: parent
                color: "transparent"

                // Hier kommt die UI des Compositor-Screens hin (vorher in CompositorScreen.qml)
                WaylandMouseTracker {
                    id: mouseTracker
                    anchors.fill: parent
                    windowSystemCursorEnabled: !clientCursor.visible

                    // Hintergrundbild für den Compositor-Bereich
                    Image {
                        id: background
                        anchors.fill: parent
                        fillMode: Image.Tile
                        // KORREKTER PFAD zum Bild aus deiner resources.qrc
                        source: "qrc:/Images/1239183-3840x2160-desktop-4k-green-forest-background-photo.jpg"
                        smooth: true
                    }

                    // Client-Mauszeiger
                    WaylandCursorItem {
                        id: clientCursor
                        x: mouseTracker.mouseX
                        y: mouseTracker.mouseY
                        seat: comp.defaultSeat // Verweis auf den defaultSeat des Compositors
                    }

                    // Seitenleiste zur Anzeige der Client-Fenster
                    Rectangle {
                        id: sidebar
                        width: 250
                        height: parent.height
                        anchors.left: parent.left
                        anchors.top: parent.top
                        color: "#AA202020" // Etwas dunkler für besseren Look
                        radius: 10

                        Column {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 5

                            Repeater {
                                model: comp.itemList
                                Rectangle {
                                    height: 54
                                    width: sidebar.width - 10
                                    color: "#CCFFFFFF"
                                    radius: 5
                                    Text {
                                        text: "window: " + modelData.shellSurface.toplevel.title + "\n["
                                            + modelData.shellSurface.toplevel.appId
                                            + (modelData.isCustom ? "]\nfont size: " + modelData.fontSize : "]\nNo extension")
                                        color: modelData.isCustom ? "black" : "darkgray"
                                    }
                                    MouseArea {
                                        enabled: modelData.isCustom
                                        anchors.fill: parent
                                        onWheel: (wheel) => {
                                            if (wheel.angleDelta.y > 0)
                                                modelData.fontSize++
                                            else if (wheel.angleDelta.y < 0 && modelData.fontSize > 3)
                                                modelData.fontSize--
                                        }
                                        onDoubleClicked: {
                                            comp.customExtension.close(modelData.surface)
                                        }
                                    }
                                }
                            }
                            Text {
                                visible: comp.itemList.length > 0
                                width: sidebar.width - 10
                                color: "white"
                                text: "Mouse wheel to change font size. Double click to close"
                                wrapMode: Text.Wrap
                            }
                        }
                    }

                    // Button zum Umschalten der Fensterdekoration
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        width: 100
                        height: 100
                        property bool on : true
                        color: on ? "#DEC0DE" : "#FACADE"
                        Text {
                            anchors.fill: parent
                            anchors.margins: 4
                            text: "Toggle window decorations"
                            wrapMode: Text.WordWrap
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                parent.on = !parent.on
                                comp.setDecorations(parent.on);
                            }
                        }
                    }
                }
            }

            // --- Fixed: Proper WaylandCompositor setup ---
            WaylandCompositor {
                id: comp
                property alias customExtension: custom
                property var itemList: []

                // KORREKTUR: WaylandOutput mit korrekter Konfiguration
                defaultOutput: WaylandOutput {
                    id: waylandOutput
                    compositor: comp
                    window: mainRoot
                }

                // Der Rest deiner Compositor-Logik bleibt gleich...
                function itemForSurface(surface) {
                    var n = itemList.length
                    for (var i = 0; i < n; i++) {
                        if (itemList[i].surface === surface)
                            return itemList[i]
                    }
                }

                Component {
                    id: chromeComponent
                    ShellSurfaceItem {
                        id: chrome
                        property bool isCustom
                        property int fontSize: 12
                        
                        // Basisgröße definieren
                        property int baseWidth: 800
                        property int baseHeight: 600

                        // Anpassung der Größe
                        width: baseWidth
                        height: baseHeight
                        anchors.centerIn: parent

                        // Berechnung der Skalierung nach Surface-Erstellung
                        Connections {
                            target: chrome.shellSurface
                            function onSurfaceChanged() {
                                if (chrome.shellSurface && chrome.shellSurface.surface) {
                                    var surfaceSize = chrome.shellSurface.surface.size;
                                    if (surfaceSize.width > 0 && surfaceSize.height > 0) {
                                        chrome.baseWidth = surfaceSize.width;
                                        chrome.baseHeight = surfaceSize.height;
                                    }
                                }
                            }
                        }

                        // Rest der chrome-Eigenschaften
                        onSurfaceDestroyed: {
                            var index = comp.itemList.indexOf(chrome)
                            if (index > -1) {
                                comp.itemList.splice(index, 1)
                            }
                            chrome.destroy()
                        }
                        transform: [
                            Rotation {
                                id: yRot
                                origin.x: chrome.width / 2; origin.y: chrome.height / 2
                                angle: 0
                                axis { x: 0; y: 1; z: 0 }
                            }
                        ]
                        NumberAnimation {
                            id: spinAnimation
                            running: false; loops: 2; target: yRot; property: "angle"
                            from: 0; to: 360; duration: 400
                        }
                        function doSpin(ms) { spinAnimation.start() }
                        NumberAnimation {
                            id: bounceAnimation
                            running: false; target: chrome; property: "y"
                            from: 0; to: comp.defaultOutput.geometry.height - chrome.height
                            easing.type: Easing.OutBounce; duration: 1000
                        }
                        function doBounce(ms) { bounceAnimation.start() }
                        onFontSizeChanged: {
                            custom.setFontSize(surface, fontSize)
                        }
                    }
                }

                // Fixed: Proper customObjectComponent definition
                Component {
                    id: customObjectComponent
                    Rectangle {
                        id: customRect
                        property var obj
                        property alias color: customRect.color
                        property alias text: customText.text

                        width: 200
                        height: 100
                        radius: 5

                        Text {
                            id: customText
                            anchors.centerIn: parent
                            color: "white"
                            font.pixelSize: 16
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("Custom object clicked:", customText.text)
                            }
                        }
                    }
                }

                XdgShell {
                    onToplevelCreated: (toplevel, xdgSurface) => {
                        // Ensure we have valid dimensions
                        let windowWidth = Math.max(800, compositorSurface.width || 800);
                        let windowHeight = Math.max(600, compositorSurface.height || 600);

                        // Fallback if values are not set
                        if (!windowWidth || isNaN(windowWidth)) windowWidth = 800;
                        if (!windowHeight || isNaN(windowHeight)) windowHeight = 600;

                        // Create Item
                        var item = chromeComponent.createObject(compositorSurface, {
                            "shellSurface": xdgSurface,
                            "width": windowWidth,
                            "height": windowHeight
                        });

                        comp.itemList.push(item);

                        // Pass a QSize object (single argument)
                        toplevel.sendConfigure(Qt.size(windowWidth, windowHeight));

                        // Then activate fullscreen without parameters
                        Qt.callLater(() => {
                            toplevel.sendFullscreen();
                        });
                    }
                }

                CustomExtension {
                    id: custom
                    onSurfaceAdded: (surface) => {
                        var item = itemForSurface(surface)
                        item.isCustom = true
                    }
                    onBounce: (surface, ms) => { itemForSurface(surface).doBounce(ms) }
                    onSpin: (surface, ms) => { itemForSurface(surface).doSpin(ms) }
                    onCustomObjectCreated: (obj) => {
                        customObjectComponent.createObject(compositorSurface, {
                            "color": obj.color, "text": obj.text, "obj": obj
                        })
                    }
                }

                function setDecorations(shown) {
                    var n = itemList.length
                    for (var i = 0; i < n; i++) {
                        if (itemList[i].isCustom)
                            custom.showDecorations(itemList[i].surface.client, shown)
                    }
                }
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
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 3
                        verticalOffset: 3
                        radius: 8.0
                        color: "#80000000"
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
                    layer.effect: DropShadow {
                        horizontalOffset: 3
                        verticalOffset: 3
                        radius: 8.0
                        color: "#80000000"
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

                    layer.effect: DropShadow {
                        horizontalOffset: 3
                        verticalOffset: 3
                        radius: 8.0
                        color: "#80000000"
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
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 3
                        verticalOffset: 3
                        radius: 8.0
                        color: "#80000000"
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
                    layer.effect: DropShadow {
                        horizontalOffset: 3
                        verticalOffset: 3
                        radius: 8.0
                        color: "#80000000"
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

                    layer.effect: DropShadow {
                        horizontalOffset: 3
                        verticalOffset: 3
                        radius: 8.0
                        color: "#80000000"
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
                            x: -143.638
                            y: -79.831
                            source: "#Cube"
                            z: 79.83064
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
                source: "qrc:/Car_infotainmentContent/icons/fan.png"
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
                source: "qrc:/Car_infotainmentContent/icons/volume.png"
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
                myAppTaskbar.addIcon("Spotify", "qrc:/Car_infotainmentContent/icons/Spotify.png", "limegreen");
            }
        }
        Button {
            text: "Karten hinzufügen"
            onClicked: {
                myAppTaskbar.addIcon("Karten", "qrc:/Car_infotainmentContent/icons/map.png", "tomato");
            }
        }
        Button {
            text: "Spotify2 hinzufügen"
            onClicked: {
                myAppTaskbar.addIcon("Spotify2", "qrc:/Car_infotainmentContent/icons/map.png", "tomato");
            }
        }
        Button {
            text: "Spotify3 hinzufügen"
            onClicked: {
                myAppTaskbar.addIcon("Spotify3", "qrc:/Car_infotainmentContent/icons/map.png", "tomato");
            }
        }
        Button {
            text: "Navigation hinzufügen"
            onClicked: {
                myAppTaskbar.addIcon("Navigation", "qrc:/Car_infotainmentContent/icons/placeholder.png", "dodgerblue");
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
            placeholderText: "App-ID eingeben (z. B. YouTube)"
            onAccepted: {
                if (text.length > 0) {
                    appProvider.addApp(text, "qrc:/Car_infotainmentContent/icons/placeholder.png", "#FF0000");
                } else {
                    console.log("Bitte eine App-ID eingeben.");
                }
            }
        }
    }

    Component.onCompleted: {
        var testImage = Qt.resolvedUrl("qrc:/Car_infotainmentContent/icons/map.png");
        console.log("Test image URL:", testImage);
    }
}