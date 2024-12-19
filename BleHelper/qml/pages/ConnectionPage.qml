import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../components"
import "../controls"

FluPage {
    id: page

    padding: 0
    title: qsTr("Connection")

    RenameAttributePopup {
        id: rename_attribute_popup

        onSaveButtonClicked: function (attributeUuid, newName, attributeType, attributeInfo) {
            ClientManager.renameAttribute(attributeInfo, newName);
        }
    }
    FluFrame {
        id: connected_device_info_container

        height: 70
        padding: 16

        anchors {
            left: parent.left
            leftMargin: 16
            right: parent.right
            rightMargin: 16
            top: parent.top
            topMargin: 16
        }
        Column {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            FluText {
                color: FluTheme.primaryColor
                text: {
                    if (ClientManager.connectedDeviceInfo) {
                        return ClientManager.connectedDeviceInfo.name;
                    }
                    return "";
                }
            }
            FluText {
                color: FluColors.Grey120
                text: {
                    if (ClientManager.connectedDeviceInfo) {
                        return ClientManager.connectedDeviceInfo.address;
                    }
                    return "";
                }
            }
        }
        FluButton {
            text: qsTr("Disconnect")

            onClicked: {
                showSuccess(qsTr("Disconnect"));
                ClientManager.disconnectFromDevice();
            }

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
        }
    }
    FluText {
        id: subtitle_text

        font: FluTextStyle.BodyStrong
        text: qsTr("Services & Characteristics & Descriptors")

        anchors {
            left: connected_device_info_container.left
            top: connected_device_info_container.bottom
            topMargin: 35
        }
    }
    ListView {
        clip: true
        focus: true
        model: ClientManager.services
        spacing: 4

        ScrollBar.vertical: FluScrollBar {
            policy: ScrollBar.AsNeeded
        }
        delegate: Item {
            required property int index
            required property var modelData

            height: service_item.implicitHeight
            width: ListView.view.width

            MyFluExpander {
                id: service_item

                property bool canRename: info ? info.canRename && ClientManager.isUuidNameMappingEnabled : false
                property ServiceInfo info: modelData
                property string name: info ? info.name : ""
                property string type: info ? info.type : ""
                property string uuid: info ? info.uuid : ""

                contentHeight: characteristics_container.implicitHeight
                headerHeight: 70

                content: ColumnLayout {
                    id: characteristics_container

                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        id: characteristics_repeater

                        model: ClientManager.characteristics[service_item.uuid]

                        /* Characteristic Layout */
                        ColumnLayout {
                            required property int index
                            required property var modelData

                            Layout.bottomMargin: index === characteristics_repeater.count - 1 ? 16 : 0
                            Layout.fillWidth: true
                            Layout.leftMargin: 24
                            Layout.rightMargin: 24
                            Layout.topMargin: index === 0 ? 16 : 0
                            spacing: 0

                            ColumnLayout {
                                id: characteristic_item

                                property bool canIndicate: info ? info.canIndicate : false
                                property bool canNotify: info ? info.canNotify : false
                                property bool canRead: info ? info.canRead : false
                                property bool canRename: info ? info.canRename && ClientManager.isUuidNameMappingEnabled : false
                                property bool canWrite: info ? info.canWrite : false
                                property bool canWriteNoResponse: info ? info.canWriteNoResponse : false
                                property CharacteristicInfo info: modelData
                                property string name: info ? info.name : ""
                                property string properties: info ? info.properties : ""
                                property string uuid: info ? info.uuid : ""

                                Layout.fillWidth: true
                                spacing: 0

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    MyFluTextButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.margins: -4
                                        clickable: characteristic_item.canRename
                                        horizontalPadding: 4
                                        text: characteristic_item.name
                                        textColor: FluTheme.fontPrimaryColor
                                        verticalPadding: 4

                                        onClicked: {
                                            rename_attribute_popup.showWithInfo(this, characteristic_item.info);
                                        }
                                    }
                                    Item {
                                        Layout.fillWidth: true // 占位符 将元素推到两侧
                                    }
                                    MyFluIconButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.margins: -4
                                        display: Button.TextBesideIcon
                                        iconSize: 12
                                        iconSource: MyFluIcon.Indicate
                                        text: qsTr("Indicate")
                                        visible: characteristic_item.canIndicate

                                        onClicked: {
                                            // TODO
                                            console.log("Indicate Characteristic: " + characteristic_item.uuid);
                                        }
                                    }
                                    MyFluIconButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.margins: -4
                                        display: Button.TextBesideIcon
                                        iconSize: 12
                                        iconSource: MyFluIcon.Notify
                                        text: qsTr("Notify")
                                        visible: characteristic_item.canNotify

                                        onClicked: {
                                            // TODO
                                            console.log("Notify Characteristic: " + characteristic_item.uuid);
                                        }
                                    }
                                    MyFluIconButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.margins: -4
                                        display: Button.TextBesideIcon
                                        iconSize: 12
                                        iconSource: MyFluIcon.Read
                                        text: qsTr("Read")
                                        visible: characteristic_item.canRead

                                        onClicked: {
                                            // TODO
                                            console.log("Read Characteristic: " + characteristic_item.uuid);
                                        }
                                    }
                                    MyFluIconButton {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.margins: -4
                                        display: Button.TextBesideIcon
                                        iconSize: 12
                                        iconSource: MyFluIcon.Write
                                        text: qsTr("Write")
                                        visible: characteristic_item.canWrite || characteristic_item.canWriteNoResponse

                                        onClicked: {
                                            // TODO
                                            console.log("Write Characteristic: " + characteristic_item.uuid);
                                        }
                                    }
                                }
                                FluText {
                                    color: FluColors.Grey120
                                    text: qsTr("UUID: ") + characteristic_item.uuid
                                }
                                FluText {
                                    color: FluColors.Grey120
                                    text: qsTr("Properties: ") + characteristic_item.properties
                                }
                                FluText {
                                    color: FluColors.Grey120
                                    text: "Descriptors: "
                                    visible: descriptors_repeater.count > 0
                                }
                                Repeater {
                                    id: descriptors_repeater

                                    model: ClientManager.descriptors[characteristic_item.uuid]

                                    /* Descriptor Layout */
                                    ColumnLayout {
                                        required property int index
                                        required property var modelData

                                        Layout.fillWidth: true
                                        Layout.leftMargin: 8
                                        Layout.topMargin: 4
                                        spacing: 0

                                        RowLayout {
                                            id: descriptor_item

                                            property DescriptorInfo info: modelData
                                            property string name: info ? info.name : ""
                                            property string uuid: info ? info.uuid : ""

                                            Layout.fillWidth: true
                                            spacing: 8

                                            FluText {
                                                Layout.alignment: Qt.AlignVCenter
                                                text: descriptor_item.name
                                            }
                                            Item {
                                                Layout.fillWidth: true // 占位符 将元素推到两侧
                                            }
                                            MyFluIconButton {
                                                Layout.alignment: Qt.AlignVCenter
                                                Layout.margins: -4
                                                display: Button.TextBesideIcon
                                                iconSize: 12
                                                iconSource: MyFluIcon.Read
                                                text: qsTr("Read")

                                                onClicked: {
                                                    // TODO
                                                    console.log("Read Descriptor: " + descriptor_item.uuid);
                                                }
                                            }
                                        }
                                        FluText {
                                            color: FluColors.Grey120
                                            text: qsTr("UUID: ") + descriptor_item.uuid
                                        }
                                    }
                                }
                            }
                            FluDivider {
                                Layout.bottomMargin: 8
                                Layout.fillWidth: true
                                Layout.leftMargin: -24
                                Layout.rightMargin: -24
                                Layout.topMargin: 8
                                orientation: Qt.Horizontal
                                visible: index < characteristics_repeater.count - 1
                            }
                        }
                    }
                }
                headerDelegate: Component {
                    Item {
                        /* Service Layout */
                        ColumnLayout {
                            spacing: 0

                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            MyFluTextButton {
                                Layout.margins: -4
                                clickable: service_item.canRename
                                horizontalPadding: 4
                                text: service_item.name
                                verticalPadding: 4

                                onClicked: {
                                    rename_attribute_popup.showWithInfo(this, service_item.info);
                                }
                            }
                            FluText {
                                color: FluColors.Grey120
                                text: service_item.uuid
                            }
                            FluText {
                                color: FluColors.Grey120
                                text: service_item.type
                            }
                        }
                    }
                }

                anchors {
                    fill: parent
                    leftMargin: 16
                    rightMargin: 16
                }
            }
        }

        anchors {
            bottom: parent.bottom
            bottomMargin: 16
            left: parent.left
            right: parent.right
            top: subtitle_text.bottom
            topMargin: 5
        }
    }
}
