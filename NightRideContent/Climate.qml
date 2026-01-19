import QtQuick
import QtQuick.Layouts

Rectangle {
    id: climateRoot
    // Dynamische Breite basierend auf dem Inhalt des RowLayout + 20px Puffer
    width: rowLayout.implicitWidth + 20
    height: 120
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
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: tempText
                text: isNaN(climateRoot.temperature)
                    ? "--"
                    : (climateRoot.language === "de"
                        ? Number(climateRoot.temperature).toFixed(1) + " °C"
                        : Number(temperatureF()).toFixed(1) + " °F")
                font.pixelSize: 38
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: climateRoot.language === "de" ? "Klima" : "Climate"
                font.pixelSize: 18
                color: "#cccccc"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
