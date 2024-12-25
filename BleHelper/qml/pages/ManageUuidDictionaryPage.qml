import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../components"
import "../controls"
import "../models"

MyFluPivot {
    id: pivot

    headerLeftPadding: 16
    headerRightPadding: 16
    padding: 0
    title: qsTr("Manage UUID Dictionary")

    commandBar: FluIconButton {
        id: more_options_button

        iconSize: 16
        iconSource: FluentIcons.More
        text: qsTr("More Options")

        onClicked: {
            more_options_menu.open();
        }

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
    }

    FluMenu {
        id: more_options_menu

        parent: pivot.commandBar
        x: parent.width - width
        y: parent.height

        FluMenuItem {
            text: qsTr("Import")

            onClicked: {
                file_dialog.show(FileDialog.OpenFile, function (fileName) {
                    if (ClientManager.importUuidDictionary(fileName)) {
                        ClientManager.refreshAllAttributesName();
                        showSuccess(qsTr("Import succeeded."));
                    } else {
                        showError(qsTr("Import failed."));
                    }
                });
            }
        }
        FluMenuItem {
            text: qsTr("Export")

            onClicked: {
                file_dialog.show(FileDialog.SaveFile, function (fileName) {
                    if (ClientManager.exportUuidDictionary(fileName)) {
                        showSuccess(qsTr("Export succeeded."));
                    } else {
                        showError(qsTr("Export failed."));
                    }
                });
            }
        }
        FluMenuItem {
            text: qsTr("Delete All")

            onClicked: {
                delete_all_alarm_aialog.open();
            }
        }
    }
    FluContentDialog {
        id: delete_all_alarm_aialog

        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
        message: qsTr("Are you sure to delete all?")
        negativeText: qsTr("Cancel")
        positiveText: qsTr("OK")
        title: qsTr("Delete")

        onPositiveClicked: {
            ClientManager.deleteAllAttributesFromUuidDictionary(ClientManager.Service | ClientManager.Characteristic);
            ClientManager.refreshAllAttributesName();
        }
    }
    FileDialog {
        id: file_dialog

        property var callback
        property string fileName: ""

        function show(fileMode, callback) {
            file_dialog.fileMode = fileMode;
            if (fileMode === FileDialog.SaveFile) {
                var date = new Date();
                var locale = Qt.locale(GlobalModel.language.replace('_', '-'));
                var fileName = "uuid_dictionary_" + date.toLocaleString(locale, "yyyyMMddhhmmss");
                file_dialog.selectedFile = currentFolder + "/" + fileName + ".json";
            }
            file_dialog.callback = callback;
            file_dialog.open();
        }

        currentFolder: StandardPaths.standardLocations(StandardPaths.DownloadLocation)[0]
        fileMode: FileDialog.SaveFile
        nameFilters: ["Json files (*.json)"]

        onAccepted: {
            file_dialog.callback(FluTools.toLocalPath(selectedFile));
        }
    }
    FluPivotItem {
        argument: {
            "model": ClientManager.serviceUuidDictionary,
            "attributeType": ClientManager.Service
        }
        contentItem: uuid_dictionary_component
        title: qsTr("Services")
    }
    FluPivotItem {
        argument: {
            "model": ClientManager.characteristicUuidDictionary,
            "attributeType": ClientManager.Characteristic
        }
        contentItem: uuid_dictionary_component
        title: qsTr("Characteristics")
    }
    Component {
        id: uuid_dictionary_component

        Item {
            RenameAttributePopup {
                id: attribute_rename_popup

                onSaveButtonClicked: function (attributeUuid, newName, attributeType, attributeInfo) {
                    ClientManager.upsertAttributeToUuidDictionary(attributeUuid, newName, attributeType);
                    ClientManager.refreshAttributeName(attributeUuid, attributeType);
                }
            }
            FluText {
                anchors.centerIn: parent
                font: FluTextStyle.Title
                text: qsTr("Empty")
                visible: argument.model.length === 0
            }
            ListView {
                clip: true
                focus: true
                model: argument.model
                spacing: 4

                ScrollBar.vertical: FluScrollBar {
                }
                delegate: Item {
                    required property int index
                    required property var modelData

                    height: 70
                    width: ListView.view.width

                    FluFrame {
                        padding: 16

                        anchors {
                            fill: parent
                            leftMargin: 16
                            rightMargin: 16
                        }
                        Column {
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            FluText {
                                text: modelData.name
                            }
                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                color: FluTheme.fontSecondaryColor
                                text: modelData.uuid
                            }
                        }
                        Row {
                            spacing: 4

                            anchors {
                                right: parent.right
                                rightMargin: -6
                                verticalCenter: parent.verticalCenter
                            }
                            FluIconButton {
                                iconSize: 16
                                iconSource: FluentIcons.Rename
                                text: qsTr("Rename")

                                onClicked: {
                                    attribute_rename_popup.show(this, modelData.uuid, modelData.name, argument.attributeType);
                                }
                            }
                            FluIconButton {
                                iconSize: 16
                                iconSource: FluentIcons.Delete
                                text: qsTr("Delete")

                                onClicked: {
                                    var uuid = modelData.uuid;
                                    var type = argument.attributeType;
                                    ClientManager.deleteAttributeFromUuidDictionary(uuid, type);
                                    ClientManager.refreshAttributeName(uuid, type);
                                }
                            }
                        }
                    }
                }

                anchors {
                    bottomMargin: 16
                    fill: parent
                    topMargin: 16
                }
            }
        }
    }
}
