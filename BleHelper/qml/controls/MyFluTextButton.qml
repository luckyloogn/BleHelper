import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

import FluentUI

Button {
    id: control

    property color backgroundDisableColor: FluTheme.itemNormalColor
    property color backgroundHoverColor: FluTheme.itemHoverColor
    property color backgroundNormalColor: FluTheme.itemNormalColor
    property color backgroundPressedColor: FluTheme.itemPressColor
    property string contentDescription: ""
    property color disableColor: FluTheme.dark ? Qt.rgba(82 / 255, 82 / 255, 82 / 255, 1) : Qt.rgba(199 / 255, 199 / 255, 199 / 255, 1)
    property bool disabled: false
    property color hoverColor: FluTheme.dark ? Qt.darker(normalColor, 1.15) : Qt.lighter(normalColor, 1.15)
    property color normalColor: FluTheme.primaryColor
    property color pressedColor: FluTheme.dark ? Qt.darker(normalColor, 1.3) : Qt.lighter(normalColor, 1.3)
    property bool textBold: true
    property color textColor: {
        if (!enabled) {
            return disableColor;
        }
        if (pressed) {
            return pressedColor;
        }
        return hovered ? hoverColor : normalColor;
    }

    Accessible.description: contentDescription
    Accessible.name: control.text
    Accessible.role: Accessible.Button
    enabled: !disabled
    focusPolicy: Qt.TabFocus
    font: FluTextStyle.Body
    horizontalPadding: 6
    verticalPadding: 6

    background: Rectangle {
        color: {
            if (!enabled) {
                return backgroundDisableColor;
            }
            if (pressed) {
                return backgroundPressedColor;
            }
            if (hovered) {
                return backgroundHoverColor;
            }
            return backgroundNormalColor;
        }
        radius: 4

        FluFocusRectangle {
            radius: 8
            visible: control.visualFocus
        }
    }
    contentItem: FluText {
        id: btn_text

        color: control.textColor
        font: control.font
        horizontalAlignment: Text.AlignHCenter
        text: control.text
        verticalAlignment: Text.AlignVCenter
    }

    Accessible.onPressAction: control.clicked()
}
