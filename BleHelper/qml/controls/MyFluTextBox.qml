import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts

import FluentUI

TextField {
    id: control

    property bool cleanEnabled: true
    property color disableColor: FluTheme.dark ? Qt.rgba(131 / 255, 131 / 255, 131 / 255, 1) : Qt.rgba(160 / 255, 160 / 255, 160 / 255, 1)
    property bool disabled: false
    property int iconSource: 0
    property color normalColor: FluTheme.dark ? Qt.rgba(255 / 255, 255 / 255, 255 / 255, 1) : Qt.rgba(27 / 255, 27 / 255, 27 / 255, 1)
    property color placeholderDisableColor: FluTheme.dark ? Qt.rgba(131 / 255, 131 / 255, 131 / 255, 1) : Qt.rgba(160 / 255, 160 / 255, 160 / 255, 1)
    property color placeholderFocusColor: FluTheme.dark ? Qt.rgba(152 / 255, 152 / 255, 152 / 255, 1) : Qt.rgba(141 / 255, 141 / 255, 141 / 255, 1)
    property color placeholderNormalColor: FluTheme.dark ? Qt.rgba(210 / 255, 210 / 255, 210 / 255, 1) : Qt.rgba(96 / 255, 96 / 255, 96 / 255, 1)

    signal commit(string text)

    color: {
        if (!enabled) {
            return disableColor;
        }
        return normalColor;
    }
    enabled: !disabled
    font: FluTextStyle.Body
    leftPadding: padding + 4
    padding: 7
    persistentSelection: false
    placeholderTextColor: {
        if (!enabled) {
            return placeholderDisableColor;
        }
        if (focus) {
            return placeholderFocusColor;
        }
        return placeholderNormalColor;
    }
    renderType: FluTheme.nativeText ? Text.NativeRendering : Text.QtRendering
    rightPadding: {
        var w = 30;
        if (control.cleanEnabled === false) {
            w = 0;
        }
        if (control.readOnly)
            w = 0;
        return icon_end.visible ? w + 36 : w + 10;
    }
    selectByMouse: true
    selectedTextColor: color
    selectionColor: FluTools.withOpacity(FluTheme.primaryColor, 0.5)
    width: 240

    background: FluTextBoxBackground {
        inputItem: control
    }

    Keys.onEnterPressed: event => d.handleCommit(event)
    Keys.onReturnPressed: event => d.handleCommit(event)

    QtObject {
        id: d

        function handleCommit(event) {
            control.commit(control.text);
        }
    }
    MouseArea {
        acceptedButtons: Qt.RightButton
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor

        onClicked: {
            if (control.echoMode === TextInput.Password) {
                return;
            }
            if (control.readOnly && control.text === "") {
                return;
            }
            control.persistentSelection = true;
            menu_loader.active = true;
        }
    }
    RowLayout {
        height: parent.height
        spacing: 4

        anchors {
            right: parent.right
            rightMargin: 5
        }
        FluIconButton {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: 20
            Layout.preferredWidth: 30
            contentDescription: "Clean"
            horizontalPadding: 0
            iconColor: FluTheme.dark ? Qt.rgba(222 / 255, 222 / 255, 222 / 255, 1) : Qt.rgba(97 / 255, 97 / 255, 97 / 255, 1)
            iconSize: 12
            iconSource: FluentIcons.Cancel
            verticalPadding: 0
            visible: {
                if (control.cleanEnabled === false) {
                    return false;
                }
                if (control.readOnly)
                    return false;
                return control.text !== "";
            }

            onClicked: {
                control.clear();
            }
        }
        FluIcon {
            id: icon_end

            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 7
            iconColor: FluTheme.dark ? Qt.rgba(222 / 255, 222 / 255, 222 / 255, 1) : Qt.rgba(97 / 255, 97 / 255, 97 / 255, 1)
            iconSize: 12
            iconSource: control.iconSource
            visible: control.iconSource != 0
        }
    }
    FluLoader {
        id: menu_loader

        active: false
        sourceComponent: menu_com
    }
    Component {
        id: menu_com

        Item {
            Component.onCompleted: {
                menu.popup();
            }

            MyFluTextBoxMenu {
                id: menu

                inputItem: control

                onClosed: {
                    control.persistentSelection = false;
                    menu_loader.active = false;
                }
            }
        }
    }
}
