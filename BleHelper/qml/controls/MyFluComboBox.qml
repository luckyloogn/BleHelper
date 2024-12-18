import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Templates as T

import FluentUI

T.ComboBox {
    id: control

    property color disableColor: FluTheme.dark ? Qt.rgba(59 / 255, 59 / 255, 59 / 255, 1) : Qt.rgba(252 / 255, 252 / 255, 252 / 255, 1)
    property bool disabled: false
    property color hoverColor: FluTheme.dark ? Qt.rgba(68 / 255, 68 / 255, 68 / 255, 1) : Qt.rgba(251 / 255, 251 / 255, 251 / 255, 1)
    property color normalColor: FluTheme.dark ? Qt.rgba(62 / 255, 62 / 255, 62 / 255, 1) : Qt.rgba(254 / 255, 254 / 255, 254 / 255, 1)
    property alias textBox: text_field

    signal commit(string text)

    enabled: !disabled
    focusPolicy: Qt.TabFocus
    font: FluTextStyle.Body
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding, implicitIndicatorHeight + topPadding + bottomPadding)
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
    leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)

    background: Rectangle {
        border.color: FluTheme.dark ? "#505050" : "#DFDFDF"
        border.width: 1
        color: {
            if (!control.enabled) {
                return disableColor;
            }
            return hovered ? hoverColor : normalColor;
        }
        implicitHeight: 32
        implicitWidth: 140
        radius: 4
        visible: !control.flat || control.down

        FluFocusRectangle {
            anchors.margins: -2
            radius: 4
            visible: !control.editable && control.visualFocus
        }
        FluClip {
            anchors.fill: parent
            radius: [4, 4, 4, 4]
            visible: control.editable && contentItem && contentItem.activeFocus

            Rectangle {
                anchors.bottom: parent.bottom
                color: FluTheme.primaryColor
                height: 2
                width: parent.width
            }
        }
    }
    contentItem: T.TextField {
        id: text_field

        function handleCommit(event) {
            control.commit(control.editText);
            accepted();
        }

        autoScroll: control.editable
        bottomPadding: 6 - control.padding
        color: {
            if (!control.enabled) {
                return FluTheme.dark ? Qt.rgba(131 / 255, 131 / 255, 131 / 255, 1) : Qt.rgba(160 / 255, 160 / 255, 160 / 255, 1);
            }
            return FluTheme.dark ? Qt.rgba(255 / 255, 255 / 255, 255 / 255, 1) : Qt.rgba(27 / 255, 27 / 255, 27 / 255, 1);
        }
        enabled: control.editable
        font: control.font
        inputMethodHints: control.inputMethodHints
        leftPadding: !control.mirrored ? 10 : control.editable && activeFocus ? 3 : 1
        readOnly: control.down
        renderType: FluTheme.nativeText ? Text.NativeRendering : Text.QtRendering
        rightPadding: control.mirrored ? 10 : control.editable && activeFocus ? 3 : 1
        selectByMouse: true
        selectedTextColor: color
        selectionColor: FluTools.withOpacity(FluTheme.primaryColor, 0.5)
        text: control.editable ? control.editText : control.displayText
        topPadding: 6 - control.padding
        validator: control.validator
        verticalAlignment: Text.AlignVCenter

        Component.onCompleted: {
            forceActiveFocus();
        }
        Keys.onEnterPressed: event => handleCommit(event)
        Keys.onReturnPressed: event => handleCommit(event)
        onActiveFocusChanged: {
            if (text_field.activeFocus) {
                selectAll();
            } else {
                deselect();
            }
        }
    }
    delegate: FluItemDelegate {
        id: item_delegate

        required property int index
        required property var model

        font: control.font
        highlighted: control.highlightedIndex === item_delegate.index
        horizontalPadding: 16
        hoverEnabled: control.hoverEnabled
        palette.highlightedText: control.palette.highlightedText
        palette.text: control.palette.text
        text: model[control.textRole]
        verticalPadding: 8
        width: ListView.view.width

        background: Rectangle {
            color: {
                if (FluTheme.dark) {
                    return Qt.rgba(1, 1, 1, 0.05);
                } else {
                    return Qt.rgba(0, 0, 0, 0.05);
                }
            }
            radius: 4
            visible: item_delegate.down || item_delegate.highlighted || item_delegate.visualFocus

            anchors {
                fill: parent
                leftMargin: 6
                rightMargin: 6
            }
        }
        contentItem: FluText {
            color: {
                if (item_delegate.down) {
                    return FluTheme.dark ? FluColors.Grey80 : FluColors.Grey120;
                }
                return FluTheme.dark ? FluColors.White : FluColors.Grey220;
            }
            elide: Text.ElideRight
            font: item_delegate.font
            text: item_delegate.text
        }
    }
    indicator: Item {
        width: 30
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2

        Button {
            id: indicator_button

            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            enabled: control.enabled && control.editable

            background: Item {
                Rectangle {
                    anchors.centerIn: parent
                    color: {
                        if (!indicator_button.enabled) {
                            return FluTheme.itemNormalColor;
                        }
                        if (indicator_button.pressed) {
                            return FluTheme.itemPressColor;
                        }
                        return indicator_button.hovered ? FluTheme.itemHoverColor : FluTheme.itemNormalColor;
                    }
                    implicitHeight: 24
                    implicitWidth: 24
                    radius: 4
                }
            }
            contentItem: Item {
                FluIcon {
                    anchors.fill: parent
                    anchors.topMargin: control.pressed || indicator_button.pressed ? 2 : 0
                    iconSize: 12
                    iconSource: FluentIcons.ChevronDown
                    opacity: control.enabled ? 1 : 0.3

                    Behavior on anchors.topMargin {
                        enabled: FluTheme.animationEnabled

                        NumberAnimation {
                            duration: 167
                            easing.type: Easing.InOutBounce
                        }
                    }
                }
            }

            onClicked: {
                control.popup.visible = true;
            }
        }
    }
    popup: T.Popup {
        id: popup

        function getHeight() {
            return Math.min(contentItem.implicitHeight + topPadding + bottomPadding, control.Window.height - topMargin - bottomMargin);
        }

        bottomMargin: 6
        bottomPadding: 6
        height: getHeight()
        modal: true
        topMargin: 6
        topPadding: 6
        width: control.width
        y: 0

        background: Rectangle {
            border.color: FluTheme.dark ? Qt.rgba(26 / 255, 26 / 255, 26 / 255, 1) : Qt.rgba(191 / 255, 191 / 255, 191 / 255, 1)
            color: FluTheme.dark ? Qt.rgba(43 / 255, 43 / 255, 43 / 255, 1) : Qt.rgba(1, 1, 1, 1)
            radius: 5

            FluShadow {
                elevation: 5
                radius: 5
            }
        }
        contentItem: ListView {
            id: content_list

            boundsMovement: Flickable.StopAtBounds
            clip: true
            currentIndex: control.currentIndex
            highlightMoveDuration: FluTheme.animationEnabled ? 167 : 0
            implicitHeight: contentHeight
            model: control.delegateModel
            spacing: 4

            T.ScrollIndicator.vertical: ScrollIndicator {
            }
            highlight: Item {
                clip: true

                Rectangle {
                    color: FluTheme.primaryColor
                    height: content_list.currentItem && content_list.currentItem.pressed ? 10 : 16
                    radius: 1.5
                    width: 3

                    Behavior on height {
                        enabled: FluTheme.animationEnabled

                        NumberAnimation {
                            duration: 167
                            easing.type: Easing.OutCubic
                        }
                    }

                    anchors {
                        left: parent.left
                        leftMargin: 6
                        verticalCenter: parent.verticalCenter
                    }
                }
                Rectangle {
                    color: {
                        if (FluTheme.dark) {
                            return Qt.rgba(1, 1, 1, 0.05);
                        } else {
                            return Qt.rgba(0, 0, 0, 0.05);
                        }
                    }
                    radius: 4
                    visible: control.highlightedIndex !== control.currentIndex

                    anchors {
                        fill: parent
                        leftMargin: 6
                        rightMargin: 6
                    }
                }
            }
        }
        enter: Transition {
            NumberAnimation {
                duration: FluTheme.animationEnabled ? 167 : 0
                easing.type: Easing.OutCubic
                from: 0
                property: "opacity"
                to: 1
            }
            NumberAnimation {
                duration: FluTheme.animationEnabled ? 167 : 0
                easing.type: Easing.OutCubic
                from: 0
                property: "height"
                to: popup.getHeight()
            }
            NumberAnimation {
                duration: FluTheme.animationEnabled ? 167 : 0
                easing.type: Easing.OutCubic
                from: 0
                property: "y"
                to: control.height / 2 - (content_list.currentItem ? content_list.currentItem.y + content_list.currentItem.height / 2 : 0)
            }
        }
        exit: Transition {
            NumberAnimation {
                duration: FluTheme.animationEnabled ? 167 : 0
                easing.type: Easing.OutCubic
                from: 1
                property: "opacity"
                to: 0
            }
        }
    }
}
