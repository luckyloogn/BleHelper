import QtQuick
import QtQuick.Controls

import FluentUI

FluMenu {
    id: menu

    property Item inputItem

    focus: false
    width: {
        if (cut.visible || copy.visible || paste.visible || undo.visible || redo.visible) {
            return 186;
        }
        return 160;
    }

    Component.onCompleted: {
        if ((inputItem instanceof TextInput) || (inputItem instanceof TextEdit)) {
            cut.visible = (inputItem.selectedText !== "" && !inputItem.readOnly);
            copy.visible = (inputItem.selectedText !== "");
            paste.visible = inputItem.canPaste;
            undo.visible = inputItem.canUndo;
            redo.visible = inputItem.canRedo;
            select_all.visible = (inputItem.text !== "");
        } else {
            cut.visible = false;
            copy.visible = false;
            paste.visible = false;
            undo.visible = false;
            redo.visible = false;
            select_all.visible = false;
        }
    }
    onVisibleChanged: {
        if (inputItem) {
            inputItem.forceActiveFocus();
        }
    }

    Button {
        id: cut

        height: visible ? implicitBackgroundHeight : 0

        background: Item {
            implicitHeight: 36
            implicitWidth: 150

            Rectangle {
                anchors.centerIn: parent
                anchors.fill: parent
                anchors.margins: 4
                color: {
                    if (cut.hovered) {
                        return FluTheme.itemHoverColor;
                    }
                    return FluTheme.itemNormalColor;
                }
                radius: 4
            }
        }
        contentItem: Item {
            anchors.fill: parent

            FluIcon {
                id: cut_icon

                iconSize: 16
                iconSource: FluentIcons.Cut

                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                id: cut_text

                text: qsTr("Cut")

                anchors {
                    left: cut_icon.right
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                color: FluTheme.fontTertiaryColor
                font.pixelSize: FluTextStyle.Body.pixelSize * 0.85
                text: "Ctrl+X"

                anchors {
                    baseline: cut_text.baseline
                    right: parent.right
                    rightMargin: 16
                }
            }
        }

        onClicked: {
            inputItem.cut();
            menu.close();
        }
    }
    Button {
        id: copy

        height: visible ? implicitBackgroundHeight : 0

        background: Item {
            implicitHeight: 36
            implicitWidth: 150

            Rectangle {
                anchors.centerIn: parent
                anchors.fill: parent
                anchors.margins: 4
                color: {
                    if (copy.hovered) {
                        return FluTheme.itemHoverColor;
                    }
                    return FluTheme.itemNormalColor;
                }
                radius: 4
            }
        }
        contentItem: Item {
            anchors.fill: parent

            FluIcon {
                id: copy_icon

                iconSize: 16
                iconSource: FluentIcons.Copy

                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                id: copy_text

                text: qsTr("Copy")

                anchors {
                    left: copy_icon.right
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                color: FluTheme.fontTertiaryColor
                font.pixelSize: FluTextStyle.Body.pixelSize * 0.85
                text: "Ctrl+C"

                anchors {
                    baseline: copy_text.baseline
                    right: parent.right
                    rightMargin: 16
                }
            }
        }

        onClicked: {
            inputItem.copy();
            menu.close();
        }
    }
    Button {
        id: paste

        height: visible ? implicitBackgroundHeight : 0

        background: Item {
            implicitHeight: 36
            implicitWidth: 150

            Rectangle {
                anchors.centerIn: parent
                anchors.fill: parent
                anchors.margins: 4
                color: {
                    if (paste.hovered) {
                        return FluTheme.itemHoverColor;
                    }
                    return FluTheme.itemNormalColor;
                }
                radius: 4
            }
        }
        contentItem: Item {
            anchors.fill: parent

            FluIcon {
                id: paste_icon

                iconSize: 16
                iconSource: FluentIcons.Paste

                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                id: paste_text

                text: qsTr("Paste")

                anchors {
                    left: paste_icon.right
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                color: FluTheme.fontTertiaryColor
                font.pixelSize: FluTextStyle.Body.pixelSize * 0.85
                text: "Ctrl+V"

                anchors {
                    baseline: paste_text.baseline
                    right: parent.right
                    rightMargin: 16
                }
            }
        }

        onClicked: {
            inputItem.paste();
            menu.close();
        }
    }
    Button {
        id: undo

        height: visible ? implicitBackgroundHeight : 0

        background: Item {
            implicitHeight: 36
            implicitWidth: 150

            Rectangle {
                anchors.centerIn: parent
                anchors.fill: parent
                anchors.margins: 4
                color: {
                    if (undo.hovered) {
                        return FluTheme.itemHoverColor;
                    }
                    return FluTheme.itemNormalColor;
                }
                radius: 4
            }
        }
        contentItem: Item {
            anchors.fill: parent

            FluIcon {
                id: undo_icon

                iconSize: 16
                iconSource: FluentIcons.Undo

                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                id: undo_text

                text: qsTr("Undo")

                anchors {
                    left: undo_icon.right
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                color: FluTheme.fontTertiaryColor
                font.pixelSize: FluTextStyle.Body.pixelSize * 0.85
                text: "Ctrl+Z"

                anchors {
                    baseline: undo_text.baseline
                    right: parent.right
                    rightMargin: 16
                }
            }
        }

        onClicked: {
            inputItem.undo();
            menu.close();
        }
    }
    Button {
        id: redo

        height: visible ? implicitBackgroundHeight : 0

        background: Item {
            implicitHeight: 36
            implicitWidth: 150

            Rectangle {
                anchors.centerIn: parent
                anchors.fill: parent
                anchors.margins: 4
                color: {
                    if (redo.hovered) {
                        return FluTheme.itemHoverColor;
                    }
                    return FluTheme.itemNormalColor;
                }
                radius: 4
            }
        }
        contentItem: Item {
            anchors.fill: parent

            FluIcon {
                id: redo_icon

                iconSize: 16
                iconSource: FluentIcons.Redo

                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                id: redo_text

                text: qsTr("Redo")

                anchors {
                    left: redo_icon.right
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                color: FluTheme.fontTertiaryColor
                font.pixelSize: FluTextStyle.Body.pixelSize * 0.85
                text: "Ctrl+Y"

                anchors {
                    baseline: redo_text.baseline
                    right: parent.right
                    rightMargin: 16
                }
            }
        }

        onClicked: {
            inputItem.redo();
            menu.close();
        }
    }
    Button {
        id: select_all

        height: visible ? implicitBackgroundHeight : 0

        background: Item {
            implicitHeight: 36
            implicitWidth: 150

            Rectangle {
                anchors.centerIn: parent
                anchors.fill: parent
                anchors.margins: 4
                color: {
                    if (select_all.hovered) {
                        return FluTheme.itemHoverColor;
                    }
                    return FluTheme.itemNormalColor;
                }
                radius: 4
            }
        }
        contentItem: Item {
            anchors.fill: parent

            FluText {
                id: select_all_text

                text: qsTr("Select All")

                anchors {
                    left: parent.left
                    leftMargin: {
                        if (cut.visible || copy.visible || paste.visible || undo.visible || redo.visible) {
                            return 44;
                        }

                        return 16;
                    }
                    verticalCenter: parent.verticalCenter
                }
            }
            FluText {
                color: FluTheme.fontTertiaryColor
                font.pixelSize: FluTextStyle.Body.pixelSize * 0.85
                text: "Ctrl+A"

                anchors {
                    baseline: select_all_text.baseline
                    right: parent.right
                    rightMargin: 16
                }
            }
        }

        onClicked: {
            inputItem.selectAll();
            menu.close();
        }
    }
}
