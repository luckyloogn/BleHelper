import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts

import FluentUI

Button {
    id: control

    property color color: {
        if (!enabled) {
            return disableColor;
        }
        if (pressed) {
            return pressedColor;
        }
        return hovered ? hoverColor : normalColor;
    }
    property string contentDescription: ""
    property color disableColor: FluTheme.itemNormalColor
    property bool disabled: false
    property color hoverColor: FluTheme.itemHoverColor
    property color iconColor: {
        if (FluTheme.dark) {
            if (!enabled) {
                return Qt.rgba(130 / 255, 130 / 255, 130 / 255, 1);
            }
            return Qt.rgba(1, 1, 1, 1);
        } else {
            if (!enabled) {
                return Qt.rgba(161 / 255, 161 / 255, 161 / 255, 1);
            }
            return Qt.rgba(0, 0, 0, 1);
        }
    }
    property Component iconDelegate: {
        if (iconSource >= FluIcon.GlobalNavButton && iconSource <= FluIcon.ClickedOutLoudSolidBold) {
            return com_icon;
        }
        return com_my_icon;
    }
    property int iconSize: 20
    property int iconSource
    property color normalColor: FluTheme.itemNormalColor
    property color pressedColor: FluTheme.itemPressColor
    property int radius: 4
    property color textColor: FluTheme.fontPrimaryColor

    Accessible.description: contentDescription
    Accessible.name: control.text
    Accessible.role: Accessible.Button
    display: Button.IconOnly
    enabled: !disabled
    focusPolicy: Qt.TabFocus
    font: FluTextStyle.Caption
    horizontalPadding: 6
    verticalPadding: 6

    background: Rectangle {
        color: control.color
        radius: control.radius

        FluFocusRectangle {
            visible: control.activeFocus
        }
    }
    contentItem: FluLoader {
        sourceComponent: {
            if (display === Button.TextUnderIcon) {
                return com_column;
            }
            return com_row;
        }
    }

    Accessible.onPressAction: control.clicked()

    Component {
        id: com_icon

        FluIcon {
            id: text_icon

            font.pixelSize: iconSize
            horizontalAlignment: Text.AlignHCenter
            iconColor: control.iconColor
            iconSize: control.iconSize
            iconSource: control.iconSource
            verticalAlignment: Text.AlignVCenter
        }
    }
    Component {
        id: com_my_icon

        MyFluIcon {
            id: text_icon

            font.pixelSize: iconSize
            horizontalAlignment: Text.AlignHCenter
            iconColor: control.iconColor
            iconSize: control.iconSize
            iconSource: control.iconSource
            verticalAlignment: Text.AlignVCenter
        }
    }
    Component {
        id: com_row

        RowLayout {
            FluLoader {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                sourceComponent: iconDelegate
                visible: display !== Button.TextOnly
            }
            FluText {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                color: control.textColor
                font: control.font
                text: control.text
                visible: display !== Button.IconOnly
            }
        }
    }
    Component {
        id: com_column

        ColumnLayout {
            FluLoader {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                sourceComponent: iconDelegate
                visible: display !== Button.TextOnly
            }
            FluText {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                color: control.textColor
                font: control.font
                text: control.text
                visible: display !== Button.IconOnly
            }
        }
    }
    FluTooltip {
        id: tool_tip

        delay: 1000
        text: control.text
        visible: {
            if (control.text === "") {
                return false;
            }
            if (control.display !== Button.IconOnly) {
                return false;
            }
            return hovered;
        }
    }
}
