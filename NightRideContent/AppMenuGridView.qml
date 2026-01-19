// AppMenuGridView.qml
import QtQuick 2.15
import QtQuick.Controls 2.15 // Or QtQuick.Controls if not using specific 2.15 features
import QtQuick.Layouts 1.15  // Or QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle {
    id: container
    color: "#DD202020" // Example background
    radius: 25

    // --- Configuration Properties ---
    // Define how large each item in the grid should be
    property int cellWidthProp: 100
    property int cellHeightProp: 100

    // Define spacing:
    property int internalPadding: 10     // Padding inside the container, around the GridView content
    property int visualCellSpacing: 10   // Visual spacing/gap you want *between* cells

    // Define layout growth thresholds:
    readonly property int thresholdWidthStage1: 580 // Width at which height starts to grow
    readonly property int maxHeightStage2: 600      // Max height (at thresholdWidthStage1) before width grows again
    readonly property int maxWidthStage3: 800      // Absolute max width of the container

    // Minimum dimensions for the container, even if empty
    readonly property int minContainerWidth: cellWidthProp + 2 * internalPadding > 0 ? cellWidthProp + 2 * internalPadding : 120
    readonly property int minContainerHeight: cellHeightProp + 2 * internalPadding > 0 ? cellHeightProp + 2 * internalPadding : 120

    readonly property int numItems: appProvider.appItems.length

    // --- JavaScript function to calculate dimensions and overflow ---
    function calculateLayoutDimensions() {
        if (numItems === 0) {
            return { w: minContainerWidth, h: minContainerHeight, ovf: false };
        }

        let _padding = 2 * internalPadding; // Total padding for width or height
        let itemW = cellWidthProp;
        let itemH = cellHeightProp;
        let spacing = visualCellSpacing; // The gap between items

        let calculatedWidth, calculatedHeight;
        let isOverflowing = false;

        // --- STAGE 1: Grow width, single row, up to thresholdWidthStage1 ---
        let contentWidth_S1 = numItems * itemW + (numItems > 0 ? (numItems - 1) * spacing : 0);
        calculatedWidth = contentWidth_S1 + _padding;
        calculatedHeight = itemH + _padding; // Height of a single row of items + padding

        if (calculatedWidth <= thresholdWidthStage1) {
            // Stays in Stage 1. Dimensions are set for now.
            // These will be further clamped by maxWidthStage3 / maxHeightStage2 at the end.
        } else {
            // --- STAGE 2: Width fixed at thresholdWidthStage1, grow height up to maxHeightStage2 ---
            calculatedWidth = thresholdWidthStage1;
            let availableGridWidth_S2 = calculatedWidth - _padding;
            let itemsPerRow_S2 = 1; // Default to 1 if items are too wide
            if (itemW <= availableGridWidth_S2) { // Check if at least one item fits
                 itemsPerRow_S2 = Math.max(1, Math.floor((availableGridWidth_S2 + spacing) / (itemW + spacing)));
            } else if (numItems > 0) { // Items exist but a single one is too wide for thresholdWidthStage1
                isOverflowing = true; // Cannot even fit one item at this fixed width
            }


            let numRows_S2 = Math.ceil(numItems / itemsPerRow_S2);
            if (itemsPerRow_S2 === 0 && numItems > 0) numRows_S2 = numItems; // effectively infinite rows if no items fit per row

            let contentHeight_S2 = numRows_S2 * itemH + (numRows_S2 > 0 ? (numRows_S2 - 1) * spacing : 0);
            calculatedHeight = contentHeight_S2 + _padding;

            if (calculatedHeight <= maxHeightStage2 && !isOverflowing) {
                // Stays in Stage 2.
            } else if (!isOverflowing) { // isOverflowing might have been set if itemsPerRow_S2 was 0
                // --- STAGE 3: Height fixed at maxHeightStage2, width grows from thresholdWidthStage1 up to maxWidthStage3 ---
                calculatedHeight = maxHeightStage2;
                let availableGridHeight_S3 = calculatedHeight - _padding;
                let rowsFitting_S3 = 1;
                if (itemH <= availableGridHeight_S3) {
                    rowsFitting_S3 = Math.max(1, Math.floor((availableGridHeight_S3 + spacing) / (itemH + spacing)));
                } else if (numItems > 0) {
                    isOverflowing = true;
                }


                let itemsPerRow_S3 = Math.ceil(numItems / rowsFitting_S3);
                if (rowsFitting_S3 === 0 && numItems > 0) itemsPerRow_S3 = numItems;

                let contentWidth_S3 = itemsPerRow_S3 * itemW + (itemsPerRow_S3 > 0 ? (itemsPerRow_S3 - 1) * spacing : 0);
                calculatedWidth = contentWidth_S3 + _padding;

                if (calculatedWidth <= maxWidthStage3 && !isOverflowing) {
                    // Stays in Stage 3.
                } else if (!isOverflowing) {
                    // --- STAGE 4: Overflow - Max dimensions reached ---
                    calculatedWidth = maxWidthStage3; // Already clamped by maxWidthStage3
                    calculatedHeight = maxHeightStage2; // Already clamped by maxHeightStage2
                    isOverflowing = true;
                }
            }
             // If Stage 2 itself overflows height immediately
            if (calculatedHeight > maxHeightStage2 && calculatedWidth === thresholdWidthStage1 && !isOverflowing) {
                 isOverflowing = true; // Mark overflow if stuck in stage 2 but too tall
                 calculatedHeight = maxHeightStage2; // Clamp height
            }
        }

        // Final clamping to absolute max dimensions and min dimensions
        calculatedWidth = Math.max(minContainerWidth, Math.min(calculatedWidth, maxWidthStage3));
        calculatedHeight = Math.max(minContainerHeight, Math.min(calculatedHeight, maxHeightStage2));


        // If not already marked as overflowing, do a final capacity check with the determined dimensions
        if (!isOverflowing) {
            let finalGridW_forCapacity = calculatedWidth - _padding;
            let finalGridH_forCapacity = calculatedHeight - _padding;

            let itemsInRow_capacity = 0;
            if (itemW > 0 && finalGridW_forCapacity >= itemW) { // check itemW > 0 to prevent division by zero or negative results if itemW is misconfigured
                itemsInRow_capacity = Math.floor((finalGridW_forCapacity + spacing) / (itemW + spacing));
            } else if (itemW > finalGridW_forCapacity && numItems > 0) { // Single item wider than available space
                 itemsInRow_capacity = 0;
            }


            let rowsInCol_capacity = 0;
            if (itemH > 0 && finalGridH_forCapacity >= itemH) {
                rowsInCol_capacity = Math.floor((finalGridH_forCapacity + spacing) / (itemH + spacing));
            } else if (itemH > finalGridH_forCapacity && numItems > 0) { // Single item taller than available space
                rowsInCol_capacity = 0;
            }

            if (numItems > 0 && (itemsInRow_capacity <= 0 || rowsInCol_capacity <= 0)) {
                // This means if there are items, but the capacity in at least one dimension is zero (or less)
                isOverflowing = true;
            } else if (itemsInRow_capacity > 0 && rowsInCol_capacity > 0 && numItems > itemsInRow_capacity * rowsInCol_capacity) {
                isOverflowing = true;
            }
        }
        // console.log( "Num:", numItems, "=> W:", calculatedWidth, "H:", calculatedHeight, "Ovf:", isOverflowing,
        //             "| S1Wmax:", thresholdWidthStage1, "S2Hmax:", maxHeightStage2, "S3Wmax:", maxWidthStage3);
        return { w: calculatedWidth, h: calculatedHeight, ovf: isOverflowing };
    }

    // Reactive properties driven by the calculation function
    readonly property var _calculatedLayout: calculateLayoutDimensions()

    width: _calculatedLayout.w
    height: _calculatedLayout.h
    property bool contentOverflows: _calculatedLayout.ovf

    // Animation for size changes
    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }

    // --- GridView to display the items ---
    GridView {
        id: grid
        anchors.fill: parent
        cellWidth: container.cellWidthProp + container.visualCellSpacing
        cellHeight: container.cellHeightProp + container.visualCellSpacing
        model: appProvider.appItems

        delegate: Item {
            id: iconItem
            property var gridRef: grid
            property int delegateIndex: index
            width: container.cellWidthProp
            height: container.cellHeightProp

            transform: Scale {
                id: itemScale
                origin.x: width / 2
                origin.y: height / 2
            }

            // New state for press animation
            states: [
                State {
                    name: "dragging"
                    when: dragArea.drag.active
                    PropertyChanges {
                        target: iconItem
                        z: 2
                        opacity: 0.9
                    }
                    PropertyChanges {
                        target: itemScale
                        xScale: 1.1
                        yScale: 1.1
                    }
                },
                State {
                    name: "pressed"
                    when: dragArea.pressed && !dragArea.drag.active
                    PropertyChanges {
                        target: itemScale
                        xScale: 1.2
                        yScale: 1.2
                    }
                }
            ]

            transitions: Transition {
                from: "*"
                to: "*"
                NumberAnimation {
                    properties: "opacity, xScale, yScale"
                    duration: 1500
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on x { SmoothedAnimation { duration: 250; velocity: 600 } }
            Behavior on y { SmoothedAnimation { duration: 250; velocity: 600 } }

            // Drag support
            Drag.active: dragArea.drag.active
            Drag.hotSpot.x: dragArea.mouseX
            Drag.hotSpot.y: dragArea.mouseY
            Drag.mimeData: { "index": index }

            // Drop support
            DropArea {
                anchors.fill: parent
                onDropped: {
                    let from = drag.source.index;
                    let to = index;
                    console.log("Swap from", from, "to", to);
                    if (drag.source.dragAllowed && from !== to) {
                        appProvider.moveItem(from, to);
                    }
                }
            }

            MouseArea {
                id: dragArea
                anchors.fill: parent
                property bool dragAllowed: false
                property real mouseX: 0
                property real mouseY: 0
                hoverEnabled: true

                Timer {
                    id: holdTimer
                    interval: 1500
                    running: false
                    repeat: false
                    onTriggered: {
                        dragArea.dragAllowed = true;
                        console.log("Drag enabled on", index);
                    }
                }

                drag {
                    target: dragArea.dragAllowed ? iconItem : null
                    axis: Drag.XAndYAxis
                    minimumX: 1
                    minimumY: 1
                }

                onPressed: function(mouse) {
                    dragArea.mouseX = mouse.x;
                    dragArea.mouseY = mouse.y;
                    holdTimer.restart();
                }
                onReleased: {
                    holdTimer.stop();
                    var pos = iconItem.gridRef.mapFromItem(iconItem, dragArea.mouseX, dragArea.mouseY);
                    var itemsPerRow = Math.floor(iconItem.gridRef.width / iconItem.gridRef.cellWidth);
                    var newCol = Math.floor(pos.x / iconItem.gridRef.cellWidth);
                    var newRow = Math.floor(pos.y / iconItem.gridRef.cellHeight);
                    var targetIndex = newRow * itemsPerRow + newCol;
                    if (targetIndex >= iconItem.gridRef.count)
                        targetIndex = iconItem.gridRef.count - 1;
                    console.log("Released - swap from", iconItem.delegateIndex, "to", targetIndex);
                    if (dragArea.dragAllowed && iconItem.delegateIndex !== targetIndex)
                        appProvider.moveItem(iconItem.delegateIndex, targetIndex);
                    // Snap back to grid cell position
                    iconItem.x = iconItem.gridRef.cellWidth * (iconItem.delegateIndex % itemsPerRow);
                    iconItem.y = iconItem.gridRef.cellHeight * Math.floor(iconItem.delegateIndex / itemsPerRow);
                    dragArea.dragAllowed = false;
                }
                onPositionChanged: function(mouse) {
                    dragArea.mouseX = mouse.x;
                    dragArea.mouseY = mouse.y;
                }
                onEntered: { iconItem.scale = 1.05; iconItem.z = 1; }
                onExited: { iconItem.scale = 1; iconItem.z = 0; }
                Behavior on scale { NumberAnimation { duration: 150 } }
            }

            // Inhalt wie gehabt
            Column {
                id: itemContent
                spacing: 5
                anchors.centerIn: parent

                Loader {
                    id: iconLoader
                    width: 40
                    height: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    property var itemModelData: modelData
                    sourceComponent: (itemModelData.iconSource && itemModelData.iconSource !== "") ? imageComponent : rectangleComponent
                    DropShadow {
                        anchors.fill: iconLoader.item   // Ändere hier: benutze iconLoader.item als Quelle
                        source: iconLoader.item         // Ändere hier: benutze iconLoader.item als Quelle
                        horizontalOffset: 0
                        verticalOffset: 4
                        radius: 7.0
                        samples: 17
                        color: "#40000000"
                        cached: true
                    }
                }

                Text {
                    text: modelData.name
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    width: container.cellWidthProp * 0.9
                }
            }
        }
    }

    // --- Components for Icon Loader ---
    Component {
        id: imageComponent
        Image {
            width: parent.width // Fill the Loader's width
            height: parent.height // Fill the Loader's height
            source: parent.itemModelData.iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            // For debugging image status (can be commented out)
            // onStatusChanged: {
            //     if (status === Image.Error) console.error("Image Error:", source, "for", parent.itemModelData.name);
            // }
        }
    }

    Component {
        id: rectangleComponent // Fallback if no iconSource
        Rectangle {
            width: parent.width
            height: parent.height
            color: parent.itemModelData.colorCode ? parent.itemModelData.colorCode : "gray" // Use colorCode or default
            radius: 5
        }
    }
}
