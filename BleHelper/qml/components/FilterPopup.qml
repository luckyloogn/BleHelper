import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../controls"

MyFluPopup {
    id: popup

    /**
     * 显示
     * @param {QtObject} context - 上下文, 在哪里调用show, 就传入它的id, 或者传入this
     * @returns {void} 无返回值
     */
    function show(context: QtObject) {
        // 计算弹出位置
        var contextWidth = Math.max(context.width, context.implicitWidth);
        var contextHeight = Math.max(context.height, context.implicitHeight);
        var contextPosInParent = context.mapToItem(popup.parent, 0, 0);
        var popupX = contextPosInParent.x + popup.leftMargin;
        if (popupX + popup.width > popup.parent.width) {
            // 如果右方空间不够，在左方弹出
            popupX = contextPosInParent.x + contextWidth - popup.width - popup.rightMargin;
        }
        var popupY = contextPosInParent.y + contextHeight + popup.topMargin;
        if (popupY + popup.height > popup.parent.height) {
            // 如果下方空间不够，在上方弹出
            popupY = contextPosInParent.y - popup.height - popup.bottomMargin;
        }

        popup.x = popupX;
        popup.y = popupY;

        popup.open();
    }

    bottomMargin: 4
    height: implicitHeight
    spacing: 0
    topMargin: 4
    width: implicitWidth

    onOpened: {
        // Popup 不会每次都重新实例化（即不会重新创建其内容）
        name_text_box.text = ClientManager.filterParams.name;
        address_text_box.text = ClientManager.filterParams.address;
        rssi_slider.value = ClientManager.filterParams.rssiValue;
        only_favourite_check_box.checked = ClientManager.filterParams.isOnlyFavourite;
        only_connected_check_box.checked = ClientManager.filterParams.isOnlyConnected;
        only_paired_check_box.checked = ClientManager.filterParams.isOnlyPaired;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        /* 标题 清除按钮 */
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 10

            FluText {
                Layout.alignment: Qt.AlignVCenter
                font: FluTextStyle.BodyStrong
                text: qsTr("Filter")
            }
            Item {
                Layout.fillWidth: true // 占位符，用于推开两侧的元素
            }
            MyFluTextButton {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("Clear")

                onClicked: {
                    name_text_box.text = "";
                    address_text_box.text = "";
                    rssi_slider.value = rssi_slider.from;
                    only_favourite_check_box.checked = false;
                    only_connected_check_box.checked = false;
                    only_paired_check_box.checked = false;
                }
            }
        }
        FluDivider {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.topMargin: 10
        }

        /* 过滤项目 */
        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 16
            columnSpacing: 16
            columns: 4
            rowSpacing: 8
            rows: 4

            MyFluIcon {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                iconSize: 16
                iconSource: MyFluIcon.DeviceName
            }
            MyFluTextBox {
                id: name_text_box

                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.columnSpan: 3
                Layout.fillWidth: true
                placeholderText: qsTr("Filter by name")
            }
            MyFluIcon {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                iconSize: 16
                iconSource: MyFluIcon.DeviceAddress
            }
            MyFluTextBox {
                id: address_text_box

                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.columnSpan: 3
                Layout.fillWidth: true
                placeholderText: qsTr("Filter by address")
            }
            MyFluIcon {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                iconSize: 16
                iconSource: MyFluIcon.DeviceRssi
            }
            FluSlider {
                id: rssi_slider

                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.bottomMargin: 8
                Layout.columnSpan: 2
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.topMargin: 8
                from: -130
                padding: 0
                to: 0
                tooltipEnabled: false
            }
            Item {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                Layout.fillHeight: true
                Layout.leftMargin: 4
                width: 72

                FluText {
                    text: qsTr("≥")

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                }
                FluText {
                    text: rssi_slider.value + qsTr("dBm")

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
            MyFluIcon {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                iconSize: 16
                iconSource: MyFluIcon.State
            }
            FluCheckBox {
                id: only_favourite_check_box

                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.fillWidth: true
                checked: ClientManager.filterParams.isOnlyFavourite
                text: qsTr("Favorites")
            }
            FluCheckBox {
                id: only_connected_check_box

                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.fillWidth: true
                checked: ClientManager.filterParams.isOnlyConnected
                text: qsTr("Connected")
            }
            FluCheckBox {
                id: only_paired_check_box

                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                Layout.fillWidth: true
                checked: ClientManager.filterParams.isOnlyPaired
                text: qsTr("Paired")
            }
        }

        /* 取消 应用按钮 */
        RowLayout {
            Layout.bottomMargin: 16
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 16
            spacing: 24

            Item {
                Layout.fillWidth: true // 占位符推送按钮到右边
            }
            FluTextButton {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("Cancel")

                onClicked: {
                    popup.close();
                }
            }
            FluFilledButton {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("Apply")

                onClicked: {
                    popup.close();
                    ClientManager.filterParams.name = name_text_box.text;
                    ClientManager.filterParams.address = address_text_box.text;
                    ClientManager.filterParams.rssiValue = rssi_slider.value;
                    ClientManager.filterParams.isOnlyFavourite = only_favourite_check_box.checked;
                    ClientManager.filterParams.isOnlyConnected = only_connected_check_box.checked;
                    ClientManager.filterParams.isOnlyPaired = only_paired_check_box.checked;
                    ClientManager.updateFilteredDevices();
                }
            }
        }
    }
}
