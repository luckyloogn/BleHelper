import QtQuick
import QtQuick.Controls

import FluentUI

TextEdit {
    id: control

    property color textColor: FluTheme.dark ? FluColors.White : FluColors.Grey220

    activeFocusOnPress: false
    activeFocusOnTab: false
    bottomPadding: 0
    color: textColor
    font: FluTextStyle.Body
    leftPadding: 0
    padding: 0
    persistentSelection: false
    readOnly: true
    renderType: FluTheme.nativeText ? Text.NativeRendering : Text.QtRendering
    rightPadding: 0
    selectByMouse: true
    selectedTextColor: color
    selectionColor: FluTools.withOpacity(FluTheme.primaryColor, 0.5)
    topPadding: 0

    onSelectedTextChanged: {
        control.forceActiveFocus();
    }

    MouseArea {
        acceptedButtons: Qt.RightButton
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor

        onClicked: {
            if (control.echoMode !== TextInput.Password) {
                control.persistentSelection = true;
                menu_loader.active = true;
            }
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
