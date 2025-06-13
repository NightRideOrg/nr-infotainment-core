import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick3D
import QtQuick3D.Helpers
import QtWayland.Compositor
import QtWayland.Compositor.XdgShell
import io.qt.examples.customextension 1.0

// Wichtig: Stellen Sie sicher, dass Qt Design Studio/Ihr Projekt Taskbar.qml finden kann.
// Wenn Taskbar.qml im selben Ordner wie main.qml liegt, ist kein spezieller Import nötig.
// Ansonsten: import "./components" o.ä. und Taskbar.qml in den Ordner components legen.
// import QtQuick.Studio.Components 1.0
// import QtQuick.Studio.DesignEffects
import Generated.QtQuick3D.Volvi

Window {
    id: mainRoot
    width: 1920
    height: 1080 // Angepasst für Demozwecke
    visible: true
    color: "#a9a9a9"
    property int speed: 20
    property bool show_rpm: false
    property int rpm: 7000
    property string rpmColor: "#ffffff"
    // property bool name: value
    property bool turnL: false
    property bool turnR: false
    property bool blinkState: false
    property bool high_beam: false
    property bool low_beam: false
    property bool foglight: false

    Timer {
        id: blinkTimer
        interval: 330 // 1 second
        repeat: true
        onTriggered: {
            blinkState = !blinkState;
        }
    }
    function updateBlinker() {
        if (turnL || turnR) {
            blinkTimer.start();
            console.log("Blinker started: turnL =", turnL, "turnR =", turnR);
        } else {
            blinkTimer.stop();
            blinkState = false;
        }
    }
    onTurnLChanged: updateBlinker()
    onTurnRChanged: updateBlinker()

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


                    // Client-Mauszeiger
                    WaylandCursorItem {
                        id: clientCursor
                        x: mouseTracker.mouseX
                        y: mouseTracker.mouseY
                        seat: comp.defaultSeat // Verweis auf den defaultSeat des Compositors
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
                    var n = itemList.length;
                    for (var i = 0; i < n; i++) {
                        if (itemList[i].surface === surface)
                            return itemList[i];
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
                            var index = comp.itemList.indexOf(chrome);
                            if (index > -1) {
                                comp.itemList.splice(index, 1);
                            }
                            chrome.destroy();
                        }
                        transform: [
                            Rotation {
                                id: yRot
                                origin.x: chrome.width / 2
                                origin.y: chrome.height / 2
                                angle: 0
                                axis {
                                    x: 0
                                    y: 1
                                    z: 0
                                }
                            }
                        ]
                        NumberAnimation {
                            id: spinAnimation
                            running: false
                            loops: 2
                            target: yRot
                            property: "angle"
                            from: 0
                            to: 360
                            duration: 400
                        }
                        function doSpin(ms) {
                            spinAnimation.start();
                        }
                        NumberAnimation {
                            id: bounceAnimation
                            running: false
                            target: chrome
                            property: "y"
                            from: 0
                            to: comp.defaultOutput.geometry.height - chrome.height
                            easing.type: Easing.OutBounce
                            duration: 1000
                        }
                        function doBounce(ms) {
                            bounceAnimation.start();
                        }
                        onFontSizeChanged: {
                            custom.setFontSize(surface, fontSize);
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
                                console.log("Custom object clicked:", customText.text);
                            }
                        }
                    }
                }

                XdgShell {
                    onToplevelCreated: (toplevel, xdgSurface) => {
                        // Ensure we have valid dimensions
                        let windowWidth = Math.max(800, compositorSurface.width || 800);
                        let windowHeight = Math.max(600, compositorSurface.height || 600);

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
                    onSurfaceAdded: surface => {
                        var item = itemForSurface(surface);
                        item.isCustom = true;
                    }
                    onBounce: (surface, ms) => {
                        itemForSurface(surface).doBounce(ms);
                    }
                    onSpin: (surface, ms) => {
                        itemForSurface(surface).doSpin(ms);
                    }
                    onCustomObjectCreated: obj => {
                        customObjectComponent.createObject(compositorSurface, {
                            "color": obj.color,
                            "text": obj.text,
                            "obj": obj
                        });
                    }
                }

                function setDecorations(shown) {
                    var n = itemList.length;
                    for (var i = 0; i < n; i++) {
                        if (itemList[i].isCustom)
                            custom.showDecorations(itemList[i].surface.client, shown);
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
                    DirectionalLight {
                        x: -0
                        y: 194.481
                        eulerRotation.z: 0.00002
                        eulerRotation.y: -0.00001
                        eulerRotation.x: -45.22048
                        z: 352.30603
                        brightness: 1
                        ambientColor: Qt.rgba(1.0, 1.0, 1.0, 1.0)
                    }

                    Node {
                        id: node
                        Volvi {
                            x: 0
                            y: 0
                            z: 0
                        }

                        SpotLight {
                            id: low_beam_L
                            x: -72.907
                            y: 67.096
                            shadowMapQuality: Light.ShadowMapQualityMedium
                            castsShadow: true
                            coneAngle: 45
                            innerConeAngle: 30
                            constantFade: 1
                            linearFade: 0.2
                            quadraticFade: 1
                            brightness: 1500
                            z: -206.05139
                            color: "#FFD1A3"
                            shadowBias: 3
                            shadowFactor: 85
                            shadowMapFar: 1000
                            visible: mainRoot.low_beam
                        }

                        SpotLight {
                            id: low_beam_R
                            x: 72.396
                            y: 66.901
                            shadowMapQuality: Light.ShadowMapQualityMedium
                            castsShadow: true
                            shadowBias: 3
                            shadowFactor: 85
                            shadowMapFar: 1000
                            coneAngle: 45
                            innerConeAngle: 30
                            constantFade: 1
                            linearFade: 0.2
                            quadraticFade: 1
                            brightness: 1500
                            color: "#FFD1A3"
                            z: -207.28381
                            visible: mainRoot.low_beam
                        }
                        SpotLight {
                            id: high_beam_L
                            x: -59.38
                            y: 64.129
                            z: -206.05139
                            color: "#FFF3E0"
                            coneAngle: 40
                            innerConeAngle: 30
                            constantFade: 1
                            linearFade: 0
                            quadraticFade: 1
                            shadowBias: 10
                            shadowFactor: 75
                            shadowMapFar: 5000
                            brightness: 600
                            visible: mainRoot.high_beam
                        }
                        SpotLight {
                            id: high_beam_R
                            x: 60.911
                            y: 64.129
                            z: -206.05139
                            color: "#FFF3E0"
                            coneAngle: 40
                            innerConeAngle: 30
                            constantFade: 1
                            linearFade: 0
                            quadraticFade: 1
                            shadowBias: 10
                            shadowFactor: 75
                            shadowMapFar: 5000
                            brightness: 800
                            visible: mainRoot.high_beam
                        }
                        SpotLight {
                            id: fog_lamps_L
                            x: -75
                            y: 40
                            z: -210
                            color: "#FFF3E0"
                            coneAngle: 40
                            innerConeAngle: 30
                            constantFade: 1
                            linearFade: 0
                            quadraticFade: 1
                            shadowBias: 10
                            shadowFactor: 75
                            shadowMapFar: 5000
                            brightness: 800
                            visible: mainRoot.foglight
                        }
                        SpotLight {
                            id: fog_lamps_R
                            x: 75
                            y: 40
                            z: -210
                            color: "#FFF3E0"
                            coneAngle: 40
                            innerConeAngle: 30
                            constantFade: 1
                            linearFade: 0
                            quadraticFade: 1
                            shadowBias: 10
                            shadowFactor: 75
                            shadowMapFar: 5000
                            brightness: 600
                            visible: mainRoot.foglight
                        }

                        SpotLight {
                            id: direction_indicator_L
                            x: -83
                            y: 67
                            constantFade: 1
                            eulerRotation.z: 0
                            eulerRotation.y: 28
                            eulerRotation.x: -0
                            shadowMapQuality: Light.ShadowMapQualityMedium
                            castsShadow: true
                            shadowBias: 5
                            shadowFactor: 50
                            shadowMapFar: 2000
                            coneAngle: 70
                            innerConeAngle: 45
                            linearFade: 0.02
                            quadraticFade: 0.8
                            brightness: 280
                            z: -198
                            visible: mainRoot.turnL && mainRoot.blinkState
                            color: "#FFA500"
                        }

                        SpotLight {
                            id: direction_indicator_R
                            x: 83
                            y: 67
                            constantFade: 1
                            eulerRotation.z: 0
                            eulerRotation.y: -28
                            eulerRotation.x: -0
                            shadowMapQuality: Light.ShadowMapQualityMedium
                            castsShadow: true
                            shadowBias: 5
                            shadowFactor: 50
                            shadowMapFar: 2000
                            coneAngle: 70
                            innerConeAngle: 45
                            linearFade: 0.02
                            quadraticFade: 0.8
                            brightness: 280
                            z: -198
                            visible: mainRoot.turnR && mainRoot.blinkState
                            color: "#FFA500"
                        }
                    }
                    PerspectiveCamera {
                        id: cameraPerspectiveFront
                        y: 250
                        z: 400
                        lookAtNode: node
                    }

                    Model {
                        id: cube
                        x: 0
                        y: -50
                        source: "#Cube"
                        scale.z: 120
                        scale.y: 1
                        scale.x: 29.26823
                        z: 0
                        materials: principledMaterial
                    }
                }

                View3D {
                    anchors.fill: parent
                    importScene: standAloneScene
                    camera: cameraPerspectiveFront
                    environment: ExtendedSceneEnvironment {
                        backgroundMode: SceneEnvironment.SkyBox
                        lightProbe: Texture {
                            source: "qrc:/Car_infotainmentContent/images/urban_street_03_2k.hdr"
                        }

                        glowEnabled: true
                        glowStrength: 1.25
                        glowBloom: 0.25
                        glowBlendMode: ExtendedSceneEnvironment.GlowBlendMode.Additive
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    property real pressedX
                    property real pressedY
                    onMouseXChanged: Qt.callLater(update)
                    onMouseYChanged: Qt.callLater(update)
                    onPressed: {
                        [pressedX, pressedY] = [mouseX, mouseY];
                    }
                    function update() {
                        let [dx, dy] = [mouseX - pressedX, mouseY - pressedY];
                        [pressedX, pressedY] = [mouseX, mouseY];
                        node.rotate(dx, Qt.vector3d(0, 1, 0), Node.SceneSpace);
                    // node.rotate(dy, Qt.vector3d(1, 0, 0), Node.SceneSpace);
                    }
                }

                Item {
                    id: __materialLibrary__

                    PrincipledMaterial {
                        id: principledMaterial
                        roughness: 1
                        metalness: 0
                        baseColor: "#000000"
                        objectName: "New Material"
                    }
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
                        if (isNaN(climateRoot.temperature))
                            return "--";
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
                    text: isNaN(volumeRoot.volume) ? "--" : Number(volumeRoot.volume).toFixed(0) + " %"
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
        onDynamicIconClicked: function(itemName, iconSource) {
            console.log("MAIN: Dynamisches Icon geklickt: " + itemName + ", Quelle: " + iconSource);

            switch (itemName) {
                case "pure-maps":
                    appLauncher.launchApp("pure-maps")
                    break;
                case "spotify":
                    appLauncher.launchApp("spotify")
                    break;
                default:
                    console.warn("Unbekannter Item-Name: " + itemName);
            }
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
            text: "Blinker Rechts"
            onClicked: {
                mainRoot.turnR = !mainRoot.turnR
            }
        }
        Button {
            text: "Blinker Links"
            onClicked: {
                mainRoot.turnL = !mainRoot.turnL
            }
        }
        Button {
            text: "Nebel Licht"
            onClicked: mainRoot.foglight = !mainRoot.foglight
        }
        Button {
            text: "Fernlicht"
            onClicked: mainRoot.high_beam = !mainRoot.high_beam
        }
        Button {
            text: "Abblendlicht"
            onClicked: mainRoot.low_beam = !mainRoot.low_beam
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
        TextField {
            id: appappInput
            placeholderText: "App-ID eingeben (z. B. YouTube)"
            onAccepted: {
                if (text.length > 0) {
                    myAppTaskbar.addIcon(text, "qrc:/Car_infotainmentContent/icons/placeholder.png", "dodgerblue");
                } else {
                    console.log("Bitte eine App-ID eingeben.");
                }
            }
        }
    }

    Component.onCompleted: {
        updateBlinker(); // <-- Blinker-Status initial prüfen
        var testImage = Qt.resolvedUrl("qrc:/Car_infotainmentContent/icons/map.png");
        console.log("Test image URL:", testImage);
    }
}
