import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Window

import FluentUI

Button {
    id: control

    property string blueText: qsTr("Blue")
    property string cancelText: qsTr("Cancel")
    property int colorHandleRadius: 8
    property color current: Qt.rgba(1, 1, 1, 1)
    property real dialogHeight: 475
    property real dialogWidth: 335
    property string greenText: qsTr("Green")
    property string hueText: qsTr("Hue")
    property bool isAlphaEnabled: true
    property bool isAlphaSliderVisible: true
    property bool isAlphaTextInputVisible: true
    property bool isColorChannelTextInputVisible: true
    property bool isColorSliderVisible: true
    property bool isHexInputVisible: true
    property bool isMoreButtonVisible: true
    property string lessText: qsTr("Less")
    property string moreText: qsTr("More")
    property string okText: qsTr("OK")
    property string opacityText: qsTr("Opacity")
    property string redText: qsTr("Red")
    property string saturationText: qsTr("Saturation")
    property string titleText: qsTr("Color Picker")
    property string valueText: qsTr("Value")

    signal accepted

    height: 36
    implicitHeight: height
    implicitWidth: width
    width: 36

    background: Rectangle {
        id: layout_color

        border.color: {
            if (hovered) {
                return FluTheme.primaryColor;
            }
            if (FluTheme.dark) {
                return Qt.rgba(100 / 255, 100 / 255, 100 / 255, 1);
            }
            return Qt.rgba(200 / 255, 200 / 255, 200 / 255, 1);
        }
        border.width: 1
        color: "#00000000"
        radius: 5

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            color: control.current
            radius: 5
        }
    }
    contentItem: Item {
    }

    onClicked: {
        color_dialog.open();
    }

    FluPopup {
        id: color_dialog

        closePolicy: Popup.CloseOnEscape
        implicitHeight: control.dialogHeight
        implicitWidth: control.dialogWidth

        contentItem: Flickable {
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            contentHeight: layout_content.height + 70
            contentWidth: width
            implicitHeight: Math.min(layout_content.height, 560, color_dialog.height)
            implicitWidth: parent.width

            ScrollBar.vertical: FluScrollBar {
            }

            Item {
                id: layout_content

                height: childrenRect.height
                width: parent.width

                FluText {
                    id: text_titile

                    font: FluTextStyle.Subtitle
                    text: control.titleText

                    anchors {
                        left: parent.left
                        leftMargin: 20
                        top: parent.top
                        topMargin: 20
                    }
                }
                Item {
                    id: layout_sb

                    height: 256
                    width: 256

                    anchors {
                        left: parent.left
                        leftMargin: 12
                        top: text_titile.bottom
                    }
                    FluClip {
                        id: layout_color_hue

                        property color blackColor: {
                            var c = whiteColor;
                            c = Qt.rgba(c.r * blackPercent, c.g * blackPercent, c.b * blackPercent, 1);
                            return c;
                        }
                        property real blackPercent: blackCursor.x / (layout_black.width - 12)
                        property color colorValue
                        property color hueColor: {
                            var v = 1.0 - xPercent;
                            var c;
                            if (0.0 <= v && v < 0.16) {
                                c = Qt.rgba(1.0, 0.0, v / 0.16, 1.0);
                            } else if (0.16 <= v && v < 0.33) {
                                c = Qt.rgba(1.0 - (v - 0.16) / 0.17, 0.0, 1.0, 1.0);
                            } else if (0.33 <= v && v < 0.5) {
                                c = Qt.rgba(0.0, ((v - 0.33) / 0.17), 1.0, 1.0);
                            } else if (0.5 <= v && v < 0.76) {
                                c = Qt.rgba(0.0, 1.0, 1.0 - (v - 0.5) / 0.26, 1.0);
                            } else if (0.76 <= v && v < 0.85) {
                                c = Qt.rgba((v - 0.76) / 0.09, 1.0, 0.0, 1.0);
                            } else if (0.85 <= v && v <= 1.0) {
                                c = Qt.rgba(1.0, 1.0 - (v - 0.85) / 0.15, 0.0, 1.0);
                            } else {
                                c = Qt.rgba(1.0, 0.0, 0.0, 1.0);
                            }
                            return c;
                        }
                        property color opacityColor: {
                            var c = blackColor;
                            c = Qt.rgba(c.r, c.g, c.b, opacityPercent);
                            return c;
                        }
                        property real opacityPercent: opacityCursor.x / (layout_opacity.width - 12)
                        property color whiteColor: {
                            var c = hueColor;
                            c = Qt.rgba((1 - c.r) * yPercent + c.r, (1 - c.g) * yPercent + c.g, (1 - c.b) * yPercent + c.b, 1.0);
                            return c;
                        }
                        property real xPercent: pickerCursor.x / width
                        property real yPercent: pickerCursor.y / height

                        function updateColor() {
                            var r;
                            var g;
                            var b;
                            var opacityPercent = Number(text_box_alpha.text) / 100;
                            if (combo_box_color_spec.currentValue === "RGB") {
                                r = Number(text_box_red_hue.text) / 255;
                                g = Number(text_box_green_saturation.text) / 255;
                                b = Number(text_box_blue_value.text) / 255;
                            } else if (combo_box_color_spec.currentValue === "HSV") {
                                // hsv2rgb
                                var h = Number(text_box_red_hue.text) / 359;
                                var s = Number(text_box_green_saturation.text) / 100;
                                var v = Number(text_box_blue_value.text) / 100;
                                var c = Qt.hsva(h, s, v, opacityPercent);
                                r = c.r;
                                g = c.g;
                                b = c.b;
                            }
                            var blackPercent = Math.max(r, g, b);
                            r = r / blackPercent;
                            g = g / blackPercent;
                            b = b / blackPercent;
                            var yPercent = Math.min(r, g, b);
                            if (r === g && r === b) {
                                r = 1;
                                b = 1;
                                g = 1;
                            } else {
                                r = (yPercent - r) / (yPercent - 1);
                                g = (yPercent - g) / (yPercent - 1);
                                b = (yPercent - b) / (yPercent - 1);
                            }
                            var xPercent;
                            if (r === 1.0 && g === 0.0 && b <= 1.0) {
                                if (b === 0.0) {
                                    xPercent = 0;
                                } else {
                                    xPercent = 1.0 - b * 0.16;
                                }
                            } else if (r <= 1.0 && g === 0.0 && b === 1.0) {
                                xPercent = 1.0 - (1.0 - r) * 0.17 - 0.16;
                            } else if (r === 0.0 && g <= 1.0 && b === 1.0) {
                                xPercent = 1.0 - (g * 0.17 + 0.33);
                            } else if (r === 0.0 && g === 1.0 && b <= 1.0) {
                                xPercent = 1.0 - (1.0 - b) * 0.26 - 0.5;
                            } else if (r <= 1.0 && g === 1.0 && b === 0.0) {
                                xPercent = 1.0 - (r * 0.09 + 0.76);
                            } else if (r === 1.0 && g <= 1.0 && b === 0.0) {
                                xPercent = 1.0 - (1.0 - g) * 0.15 - 0.85;
                            } else {
                                xPercent = 0;
                            }
                            pickerCursor.x = xPercent * width;
                            pickerCursor.y = yPercent * height;
                            blackCursor.x = blackPercent * (layout_black.width - 12);
                            opacityCursor.x = opacityPercent * (layout_opacity.width - 12);
                        }
                        function updateColorText(color) {
                            if (combo_box_color_spec.currentValue === "RGB") {
                                text_box_red_hue.text = String(Math.round(color.r * 255));
                                text_box_green_saturation.text = String(Math.round(color.g * 255));
                                text_box_blue_value.text = String(Math.round(color.b * 255));
                            } else if (combo_box_color_spec.currentValue === "HSV") {
                                text_box_red_hue.text = String(Math.round(Math.abs(color.hsvHue * 359)));
                                text_box_green_saturation.text = String(Math.round(color.hsvSaturation * 100));
                                text_box_blue_value.text = String(Math.round(color.hsvValue * 100));
                            }
                            text_box_alpha.text = String(Math.round(color.a * 100));
                            var colorString = color.toString().slice(1);
                            if (control.isAlphaEnabled && color.a === 1) {
                                colorString = "FF" + colorString;
                            }
                            if (!text_box_hex.activeFocus) {
                                text_box_hex.text = colorString.toUpperCase();
                            }
                        }

                        height: parent.height - 2 * colorHandleRadius
                        radius: [4, 4, 4, 4]
                        width: parent.width - 2 * colorHandleRadius
                        x: colorHandleRadius
                        y: colorHandleRadius

                        onOpacityColorChanged: {
                            layout_color_hue.colorValue = opacityColor;
                            updateColorText(opacityColor);
                        }

                        Rectangle {
                            anchors.fill: parent

                            gradient: Gradient {
                                orientation: Gradient.Horizontal

                                GradientStop {
                                    color: "#FF0000"
                                    position: 0.0
                                }
                                GradientStop {
                                    color: "#FFFF00"
                                    position: 0.16
                                }
                                GradientStop {
                                    color: "#00FF00"
                                    position: 0.33
                                }
                                GradientStop {
                                    color: "#00FFFF"
                                    position: 0.5
                                }
                                GradientStop {
                                    color: "#0000FF"
                                    position: 0.76
                                }
                                GradientStop {
                                    color: "#FF00FF"
                                    position: 0.85
                                }
                                GradientStop {
                                    color: "#FF0000"
                                    position: 1.0
                                }
                            }
                        }
                        Rectangle {
                            anchors.fill: parent

                            gradient: Gradient {
                                GradientStop {
                                    color: "#FFFFFFFF"
                                    position: 1.0
                                }
                                GradientStop {
                                    color: "#00000000"
                                    position: 0.0
                                }
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            border.color: FluTheme.dividerColor
                            border.width: 1
                            color: "#00000000"
                            radius: 4
                        }
                    }
                    Item {
                        id: pickerCursor

                        Rectangle {
                            border.color: "black"
                            border.width: 2
                            color: "transparent"
                            height: colorHandleRadius * 2
                            radius: colorHandleRadius
                            width: colorHandleRadius * 2

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                border.color: "white"
                                border.width: 2
                                color: "transparent"
                                radius: width / 2
                            }
                        }
                    }
                    MouseArea {
                        function handleMouse(mouse) {
                            if (mouse.buttons & Qt.LeftButton) {
                                text_box_red_hue.focus = false;
                                text_box_green_saturation.focus = false;
                                text_box_blue_value.focus = false;
                                text_box_alpha.focus = false;
                                text_box_hex.focus = false;
                                pickerCursor.x = Math.max(0, Math.min(mouse.x - colorHandleRadius, width - 2 * colorHandleRadius));
                                pickerCursor.y = Math.max(0, Math.min(mouse.y - colorHandleRadius, height - 2 * colorHandleRadius));
                            }
                        }

                        anchors.fill: parent
                        preventStealing: true
                        x: colorHandleRadius
                        y: colorHandleRadius

                        onPositionChanged: mouse => handleMouse(mouse)
                        onPressed: mouse => handleMouse(mouse)
                    }
                }
                FluClip {
                    radius: [4, 4, 4, 4]
                    width: 44

                    anchors {
                        bottom: layout_sb.bottom
                        bottomMargin: colorHandleRadius
                        left: layout_sb.right
                        leftMargin: 4
                        top: layout_sb.top
                        topMargin: colorHandleRadius
                    }
                    Grid {
                        id: target_grid_color

                        anchors.fill: parent
                        columns: width / 5 + 1
                        padding: 0
                        rows: height / 5 + 1

                        Repeater {
                            model: (target_grid_color.columns - 1) * (target_grid_color.rows - 1)

                            Rectangle {
                                color: (model.index % 2 == 0) ? "gray" : "white"
                                height: 6
                                width: 6
                            }
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        border.color: FluTheme.dividerColor
                        border.width: 1
                        color: layout_color_hue.colorValue
                        radius: 4
                    }
                }
                ColumnLayout {
                    spacing: 20

                    anchors {
                        left: parent.left
                        leftMargin: 18
                        right: parent.right
                        rightMargin: 18
                        top: layout_sb.bottom
                        topMargin: 10
                    }
                    Column {
                        id: layout_slider_bar

                        Layout.fillWidth: true
                        spacing: 8
                        visible: control.isColorSliderVisible || (control.isAlphaEnabled && control.isAlphaSliderVisible)

                        Rectangle {
                            id: layout_black

                            height: 12
                            radius: 6
                            visible: control.isColorSliderVisible
                            width: parent.width

                            gradient: Gradient {
                                orientation: Gradient.Horizontal

                                GradientStop {
                                    color: "#FF000000"
                                    position: 0.0
                                }
                                GradientStop {
                                    color: layout_color_hue.hueColor
                                    position: 1.0
                                }
                            }

                            Item {
                                id: blackCursor

                                x: layout_black.width - 12

                                Rectangle {
                                    border.color: "black"
                                    border.width: 2
                                    color: "transparent"
                                    height: 12
                                    radius: 6
                                    width: 12

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        border.color: "white"
                                        border.width: 2
                                        color: "transparent"
                                        radius: width / 2
                                    }
                                }
                            }
                            MouseArea {
                                function handleMouse(mouse) {
                                    if (mouse.buttons & Qt.LeftButton) {
                                        text_box_red_hue.focus = false;
                                        text_box_green_saturation.focus = false;
                                        text_box_blue_value.focus = false;
                                        text_box_alpha.focus = false;
                                        text_box_hex.focus = false;
                                        blackCursor.x = Math.max(0, Math.min(mouse.x - 6, width - 2 * 6));
                                        blackCursor.y = 0;
                                    }
                                }

                                anchors.fill: parent
                                preventStealing: true

                                onPositionChanged: mouse => handleMouse(mouse)
                                onPressed: mouse => handleMouse(mouse)
                            }
                        }
                        FluClip {
                            id: layout_opacity

                            height: 12
                            radius: [6, 6, 6, 6]
                            visible: control.isAlphaEnabled && control.isAlphaSliderVisible
                            width: parent.width

                            Grid {
                                id: grid_opacity

                                anchors.fill: parent
                                clip: true
                                columns: width / 4 + 1
                                rows: height / 4

                                Repeater {
                                    model: grid_opacity.columns * grid_opacity.rows

                                    Rectangle {
                                        color: (model.index % 2 == 0) ? "gray" : "white"
                                        height: 4
                                        width: 4
                                    }
                                }
                            }
                            Rectangle {
                                anchors.fill: parent

                                gradient: Gradient {
                                    orientation: Gradient.Horizontal

                                    GradientStop {
                                        color: "#00000000"
                                        position: 0.0
                                    }
                                    GradientStop {
                                        color: layout_color_hue.blackColor
                                        position: 1.0
                                    }
                                }
                            }
                            Item {
                                id: opacityCursor

                                x: layout_opacity.width - 12

                                Rectangle {
                                    border.color: "black"
                                    border.width: 2
                                    color: "transparent"
                                    height: 12
                                    radius: 6
                                    width: 12

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        border.color: "white"
                                        border.width: 2
                                        color: "transparent"
                                        radius: width / 2
                                    }
                                }
                            }
                            MouseArea {
                                id: mouse_opacity

                                function handleMouse(mouse) {
                                    if (mouse.buttons & Qt.LeftButton) {
                                        text_box_red_hue.focus = false;
                                        text_box_green_saturation.focus = false;
                                        text_box_blue_value.focus = false;
                                        text_box_alpha.focus = false;
                                        text_box_hex.focus = false;
                                        opacityCursor.x = Math.max(0, Math.min(mouse.x - 6, width - 2 * 6));
                                        opacityCursor.y = 0;
                                    }
                                }

                                anchors.fill: parent
                                preventStealing: true

                                onPositionChanged: mouse => handleMouse(mouse)
                                onPressed: mouse => handleMouse(mouse)
                            }
                        }
                    }
                    Row {
                        id: more_button_container

                        Layout.alignment: Qt.AlignRight
                        spacing: 0
                        visible: control.isMoreButtonVisible

                        FluButton {
                            id: more_button

                            anchors.verticalCenter: parent.verticalCenter
                            checkable: true
                            text: checked ? control.lessText : control.moreText
                            textColor: {
                                if (FluTheme.dark) {
                                    if (pressed) {
                                        return Qt.color("#969696");
                                    }
                                    if (hovered) {
                                        return Qt.color("#CCCCCC");
                                    }
                                    return Qt.rgba(1, 1, 1, 1);
                                } else {
                                    if (pressed) {
                                        return Qt.color("#868686");
                                    }
                                    if (hovered) {
                                        return Qt.color("#5C5C5C");
                                    }
                                    return Qt.rgba(0, 0, 0, 1);
                                }
                            }

                            background: Item {
                            }
                        }
                        FluIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            iconColor: more_button.textColor
                            iconSize: 12
                            iconSource: FluentIcons.ChevronUp
                            rotation: more_button.expand ? 0 : 180

                            Behavior on rotation {
                                enabled: FluTheme.animationEnabled

                                NumberAnimation {
                                    duration: 167
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                    Column {
                        Layout.fillWidth: true
                        spacing: 5

                        RowLayout {
                            width: parent.width

                            MyFluComboBox {
                                id: combo_box_color_spec

                                Layout.preferredWidth: 120
                                model: ["RGB", "HSV"]
                                visible: {
                                    if (!control.isMoreButtonVisible) {
                                        return control.isColorChannelTextInputVisible;
                                    }
                                    return control.isColorChannelTextInputVisible && more_button.checked;
                                }

                                onCurrentValueChanged: {
                                    layout_color_hue.updateColorText(layout_color_hue.colorValue);
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                visible: combo_box_color_spec.visible
                            }
                            MyFluTextBox {
                                id: text_box_hex

                                Layout.preferredWidth: 136
                                leftPadding: 20
                                visible: {
                                    if (!control.isMoreButtonVisible) {
                                        return control.isHexInputVisible;
                                    }
                                    return control.isHexInputVisible && more_button.checked;
                                }

                                validator: RegularExpressionValidator {
                                    regularExpression: {
                                        if (control.isAlphaEnabled) {
                                            return /^[0-9A-Fa-f]{8}$/;
                                        }
                                        return /^[0-9A-Fa-f]{6}$/;
                                    }
                                }

                                onTextEdited: {
                                    if (text !== "") {
                                        var len = control.isAlphaEnabled ? 8 : 6;
                                        var colorString = text_box_hex.text.padStart(len, "0");
                                        var red = parseInt(colorString.substring(len - 6, len - 4), 16) / 255;
                                        var green = parseInt(colorString.substring(len - 4, len - 2), 16) / 255;
                                        var blue = parseInt(colorString.substring(len - 2, len), 16) / 255;
                                        var alpha = 1;
                                        if (control.isAlphaEnabled) {
                                            alpha = parseInt(colorString.substring(0, 2), 16) / 255;
                                        }
                                        var c = Qt.rgba(red, green, blue, alpha);
                                        layout_color_hue.colorValue = c;
                                        layout_color_hue.updateColorText(c);
                                        text_box_red_hue.textEdited();
                                        text_box_green_saturation.textEdited();
                                        text_box_blue_value.textEdited();
                                        text_box_alpha.textEdited();
                                    }
                                }

                                FluText {
                                    text: "#"

                                    anchors {
                                        left: parent.left
                                        leftMargin: 5
                                        verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                        Row {
                            spacing: 10
                            visible: {
                                if (!control.isMoreButtonVisible) {
                                    return control.isColorChannelTextInputVisible;
                                }
                                return control.isColorChannelTextInputVisible && more_button.checked;
                            }

                            MyFluTextBox {
                                id: text_box_red_hue

                                width: 120

                                validator: RegularExpressionValidator {
                                    regularExpression: {
                                        if (combo_box_color_spec.currentValue === "RGB") {
                                            return /^(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)$/;
                                        } else if (combo_box_color_spec.currentValue === "HSV") {
                                            return /^(?:[0-9]?[0-9]|[1-2][0-9]{2}|3[0-5][0-9]|359)$/;
                                        }
                                    }
                                }

                                onTextEdited: {
                                    if (text !== "") {
                                        layout_color_hue.updateColor();
                                    }
                                }
                            }
                            FluText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: {
                                    if (combo_box_color_spec.currentValue === "RGB") {
                                        return control.redText;
                                    } else if (combo_box_color_spec.currentValue === "HSV") {
                                        return control.hueText;
                                    }
                                }
                            }
                        }
                        Row {
                            spacing: 10
                            visible: {
                                if (!control.isMoreButtonVisible) {
                                    return control.isColorChannelTextInputVisible;
                                }
                                return control.isColorChannelTextInputVisible && more_button.checked;
                            }

                            MyFluTextBox {
                                id: text_box_green_saturation

                                width: 120

                                validator: RegularExpressionValidator {
                                    regularExpression: {
                                        if (combo_box_color_spec.currentValue === "RGB") {
                                            return /^(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)$/;
                                        } else if (combo_box_color_spec.currentValue === "HSV") {
                                            return /^(100|[1-9]?\d)$/;
                                        }
                                    }
                                }

                                onTextEdited: {
                                    if (text !== "") {
                                        layout_color_hue.updateColor();
                                    }
                                }
                            }
                            FluText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: {
                                    if (combo_box_color_spec.currentValue === "RGB") {
                                        return control.greenText;
                                    } else if (combo_box_color_spec.currentValue === "HSV") {
                                        return control.saturationText;
                                    }
                                }
                            }
                        }
                        Row {
                            spacing: 10
                            visible: {
                                if (!control.isMoreButtonVisible) {
                                    return control.isColorChannelTextInputVisible;
                                }
                                return control.isColorChannelTextInputVisible && more_button.checked;
                            }

                            MyFluTextBox {
                                id: text_box_blue_value

                                width: 120

                                validator: RegularExpressionValidator {
                                    regularExpression: {
                                        if (combo_box_color_spec.currentValue === "RGB") {
                                            return /^(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)$/;
                                        } else if (combo_box_color_spec.currentValue === "HSV") {
                                            return /^(100|[1-9]?\d)$/;
                                        }
                                    }
                                }

                                onTextEdited: {
                                    if (text !== "") {
                                        layout_color_hue.updateColor();
                                    }
                                }
                            }
                            FluText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: {
                                    if (combo_box_color_spec.currentValue === "RGB") {
                                        return control.blueText;
                                    } else if (combo_box_color_spec.currentValue === "HSV") {
                                        return control.valueText;
                                    }
                                }
                            }
                        }
                        Row {
                            spacing: 10
                            visible: {
                                if (!control.isMoreButtonVisible) {
                                    return control.isAlphaEnabled && control.isAlphaTextInputVisible;
                                }
                                return control.isAlphaEnabled && control.isAlphaTextInputVisible && more_button.checked;
                            }

                            MyFluTextBox {
                                id: text_box_alpha

                                width: 120

                                validator: RegularExpressionValidator {
                                    regularExpression: /^(100|[1-9]?\d)$/
                                }

                                onTextEdited: {
                                    if (text !== "") {
                                        opacityCursor.x = Number(text) / 100 * (layout_opacity.width - 12);
                                    }
                                }

                                FluText {
                                    id: text_opacity

                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "%"
                                    x: Math.min(text_box_alpha.implicitWidth, text_box_alpha.width) - 38
                                }
                            }
                            FluText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: control.opacityText
                            }
                        }
                    }
                }
            }
        }

        onClosed: {
            combo_box_color_spec.currentIndex = 0;
            more_button.checked = false;
            text_box_hex.focus = false;
        }
        onOpened: {
            layout_color_hue.updateColorText(current);
            if (!control.isAlphaEnabled) {
                text_box_alpha.text = 100;
            }
            text_box_red_hue.textEdited();
            text_box_green_saturation.textEdited();
            text_box_blue_value.textEdited();
            text_box_alpha.textEdited();
        }

        Rectangle {
            id: layout_actions

            anchors.bottom: parent.bottom
            color: {
                if (FluTheme.dark) {
                    return Qt.rgba(32 / 255, 32 / 255, 32 / 255, 1);
                }
                return Qt.rgba(243 / 255, 243 / 255, 243 / 255, 1);
            }
            height: 60
            radius: 5
            width: parent.width
            z: 999

            RowLayout {
                spacing: 10

                anchors {
                    centerIn: parent
                    fill: parent
                    margins: spacing
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    FluButton {
                        anchors.centerIn: parent
                        text: control.cancelText
                        width: parent.width

                        onClicked: {
                            color_dialog.close();
                        }
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    FluFilledButton {
                        anchors.centerIn: parent
                        text: control.okText
                        width: parent.width

                        onClicked: {
                            current = layout_color_hue.colorValue;
                            control.accepted();
                            color_dialog.close();
                        }
                    }
                }
            }
        }
    }
}
