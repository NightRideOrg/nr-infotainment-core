import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtCore

Rectangle {
    id: taskbarRoot

    // --- Speicher für die Icon-Konfiguration ---
    ListModel {
        id: dynamicIconModel
    }
    Settings {
        id: taskbarSettings
    }

    // --- Funktionen zum Speichern/Laden der Konfiguration ---
    function saveConfiguration() {
        var iconsData = [];
        for (var i = 0; i < dynamicIconModel.count; i++) {
            var icon = dynamicIconModel.get(i);
            iconsData.push({
                itemName: icon.itemName,
                iconSource: icon.iconSource,
                itemColor: icon.itemColor
            });
        }
        taskbarSettings.setValue("dynamicIcons", JSON.stringify(iconsData));
    }

    function loadConfiguration() {
        var savedData = taskbarSettings.value("dynamicIcons");
        if (savedData) {
            try {
                var iconsArray = JSON.parse(savedData);
                for (var i = 0; i < iconsArray.length; i++) {
                    var iconData = iconsArray[i];
                    addIcon(iconData.itemName, iconData.iconSource, iconData.itemColor);
                }
            } catch (e) {
                console.error("Fehler beim Laden der Konfiguration:", e);
            }
        }
    }

    // --- Automatisches Speichern bei Modelländerungen ---
    Connections {
        target: dynamicIconModel
        function onRowsInserted(parentModelIndex, firstRow, lastRow) {
            console.log("Taskbar: Rows inserted, saving configuration."); // Zum Debuggen
            saveConfiguration();
        }

        function onRowsRemoved(parentModelIndex, firstRow, lastRow) {
            console.log("Taskbar: Rows removed, saving configuration."); // Zum Debuggen
            saveConfiguration();
        }
    }

    // --- Konfiguration beim Start laden ---
    Component.onCompleted: {
        loadConfiguration();
    }

    // --- GRÖSSENDEFINITIONEN ---
    // 1. Gewünschte sichtbare Größe des Icon-Bildes selbst
    readonly property int visibleIconDimension: 65 // Ihre gewünschte Icon-Größe

    // 2. Zusätzlicher Platz auf JEDER Seite des Icons für den Schatten
    //    Schatten: vOffset: 4, radius: 7 => max. Ausdehnung ~11px (4+7)
    //    Ein Wert von 12px sollte sicherstellen, dass nichts abgeschnitten wird.
    readonly property int shadowSpaceAroundIcon: 12

    // 3. Gesamtgröße eines Icon-Containers im Layout (Bild + Platz für Schatten)
    readonly property int totalIconItemLayoutSize: visibleIconDimension + (2 * shadowSpaceAroundIcon) // 65 + 2*12 = 89

    // --- Taskleisten-Eigenschaften ---
    height: totalIconItemLayoutSize + (2 * taskbarPadding) // z.B. 89 + 2*15 = 119
    color: "#AA202020"
    radius: 25

    readonly property int taskbarPadding: 15
    readonly property int iconSpacing: 10 // Abstand zwischen den totalIconItemLayoutSize-Elementen

    // --- Signale und Model (unverändert) ---
    signal dynamicIconClicked(string itemName, string iconSource)
    signal appDrawerClicked()

    // --- API Funktionen (unverändert) ---
    function addIcon(name, source, color) {
            for (let i = 0; i < dynamicIconModel.count; i++) {
                if (dynamicIconModel.get(i).itemName === name) {
                    console.log("Icon " + name + " existiert bereits.");
                    return;
                }
            }
            dynamicIconModel.append({
                itemName: name,
                itemColor: color || "transparent",
                iconSource: source
            });
            console.log("Icon hinzugefügt: " + name + ", Source: " + source);
        }

    function removeIconByName(name) {
        for (let i = 0; i < dynamicIconModel.count; i++) {
            if (dynamicIconModel.get(i).itemName === name) {
                dynamicIconModel.remove(i);
                console.log("Icon entfernt: " + name);
                return;
            }
        }
        console.log("Icon zum Entfernen nicht gefunden: " + name);
    }
    function removeIconByIndex(index) {
        if (index >= 0 && index < dynamicIconModel.count) {
            let item = dynamicIconModel.get(index);
            dynamicIconModel.remove(index);
            console.log("Icon an Index " + index + " entfernt: " + item.itemName);
        } else {
            console.log("Ungültiger Index zum Entfernen: " + index);
        }
    }

    function removeLastDynamicIcon() {
        if (dynamicIconModel.count > 0) {
            let item = dynamicIconModel.get(dynamicIconModel.count - 1);
            dynamicIconModel.remove(dynamicIconModel.count - 1);
            console.log("Letztes dynamisches Icon entfernt: " + item.itemName);
        }
    }


    // --- Breitenberechnung der Taskleiste (angepasst an totalIconItemLayoutSize) ---
    readonly property real appDrawerItemActualWidth: appDrawerButton.width // width ist jetzt totalIconItemLayoutSize
    readonly property real dynamicIconsListViewActualWidth: iconListView.visible ? iconListView.contentWidth : 0
    readonly property real spacingBetweenSections: iconListView.visible ? mainLayout.spacing : 0
    width: appDrawerItemActualWidth + spacingBetweenSections + dynamicIconsListViewActualWidth + (2 * taskbarPadding)

    Behavior on width {
        NumberAnimation {
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }

    RowLayout {
        id: mainLayout
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: taskbarRoot.taskbarPadding
        height: taskbarRoot.totalIconItemLayoutSize // Höhe des Layouts basiert auf Gesamtgröße
        spacing: taskbarRoot.iconSpacing

        // --- App Drawer Icon ---
        Item {
            id: appDrawerButton
            width: taskbarRoot.totalIconItemLayoutSize  // Container ist größer
            height: taskbarRoot.totalIconItemLayoutSize // Container ist größer
            Layout.alignment: Qt.AlignVCenter
            layer.enabled: true
            layer.smooth: true
            clip: false

            Image {
                id: appDrawerImage
                width: taskbarRoot.visibleIconDimension  // Bild hat die gewünschte sichtbare Größe
                height: taskbarRoot.visibleIconDimension // Bild hat die gewünschte sichtbare Größe
                anchors.centerIn: parent                 // Zentriert im größeren Container
                source: "qrc:/NightRideContent/icons/app-drawer.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                antialiasing: true

                Rectangle { // Fallback
                    color: "gray"
                    anchors.fill: parent
                    radius: 8
                    visible: appDrawerImage.status !== Image.Ready
                    Text { text:"AD"; anchors.centerIn: parent; color:"blue"}
                }
            }

            DropShadow {
                anchors.fill: appDrawerImage // Bezieht sich auf das appDrawerImage (visibleIconDimension)
                source: appDrawerImage
                horizontalOffset: 0
                verticalOffset: 4
                radius: 7.0
                samples: 17
                color: "#40000000"
                cached: true
            }

            MouseArea {
                anchors.fill: parent // Füllt den gesamten (größeren) appDrawerButton Container
                hoverEnabled: true
                onClicked: taskbarRoot.appDrawerClicked()
                onEntered: { appDrawerButton.scale = 1.1; appDrawerButton.z = 1; }
                onExited: { appDrawerButton.scale = 1.0; appDrawerButton.z = 0; }
                Behavior on scale { NumberAnimation { duration: 150 } }
            }
        }

        // --- ListView für dynamische Icons ---
        ListView {
            id: iconListView
            Layout.fillHeight: true // Nimmt die Höhe des RowLayout (totalIconItemLayoutSize)
            width: contentWidth
            visible: model.count > 0
            orientation: Qt.Horizontal
            spacing: taskbarRoot.iconSpacing // Abstand zwischen den Gesamt-Items
            interactive: false
            model: dynamicIconModel
            clip: false

            delegate: Item {
                id: delegateRoot
                width: taskbarRoot.totalIconItemLayoutSize  // Container ist größer
                height: taskbarRoot.totalIconItemLayoutSize // Container ist größer
                layer.enabled: true
                layer.smooth: true
                clip: false

                Image {
                    id: iconVisual
                    width: taskbarRoot.visibleIconDimension  // Bild hat die gewünschte sichtbare Größe
                    height: taskbarRoot.visibleIconDimension // Bild hat die gewünschte sichtbare Größe
                    anchors.centerIn: parent                 // Zentriert im größeren Container
                    source: model.iconSource
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    antialiasing: true

                    Rectangle { // Fallback
                        anchors.fill: parent
                        color: model.itemColor
                        visible: iconVisual.status !== Image.Ready
                        radius: 8
                        Text {
                            text: model.itemName ? model.itemName.substring(0,1) : "?"
                            anchors.centerIn: parent
                            color: "white"
                            font.pixelSize: 24
                            font.bold: true
                            visible: iconVisual.status !== Image.Ready
                        }
                    }
                    onStatusChanged: {
                        if (status === Image.Error) console.error("Fehler beim Laden von Icon: " + source);
                    }

                }

                DropShadow {
                    anchors.fill: iconVisual // Bezieht sich auf das iconVisual (visibleIconDimension)
                    source: iconVisual
                    horizontalOffset: 0
                    verticalOffset: 4
                    radius: 7.0
                    samples: 17
                    color: "#40000000"
                    cached: true
                }

                MouseArea {
                    anchors.fill: parent // Füllt das gesamte (größere) delegateRoot Item
                    hoverEnabled: true
                    onClicked: taskbarRoot.dynamicIconClicked(model.itemName, model.iconSource)
                    onEntered: { delegateRoot.scale = 1.1; delegateRoot.z = 1; }
                    onExited: { delegateRoot.scale = 1.0; delegateRoot.z = 0; }
                    Behavior on scale { NumberAnimation { duration: 150 } }
                }
            }

            // Animationen (unverändert)
            add: Transition {
                ParallelAnimation {
                    NumberAnimation { target: ViewTransition.item; property: "opacity"; from: 0; to: 1.0; duration: 400 }
                    NumberAnimation { target: ViewTransition.item; property: "scale"; from: 0.5; to: 1.0; duration: 400 }
                }
            }
            remove: Transition {
                ParallelAnimation {
                    NumberAnimation { target: ViewTransition.item; property: "opacity"; from: 1.0; to: 0; duration: 400 }
                    NumberAnimation { target: ViewTransition.item; property: "scale"; from: 1.0; to: 0.5; duration: 400 }
                }
            }
            displaced: Transition {
                SequentialAnimation {
                    PauseAnimation { duration: 0 }
                    NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.InOutQuad }
                }
            }
        }
    }
}
