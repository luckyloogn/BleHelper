import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../controls"

MyFluPopup {
    id: popup

    property var attributeInfo: null
    property int attributeType: ClientManager.Unknown
    property string attributeUuid: ""

    signal saveButtonClicked(string attributeUuid, string newName, int attributeType, QtObject attributeInfo)

    /**
     * 显示
     * @param {QtObject} context - 上下文, 在哪里调用show, 就传入它的id, 或者传入this
     * @param {string} uuid - uuid
     * @param {string} currentName - 当前名称
     * @param {int} attributeType - 重命名对象. 支持以下值:
     *   - ClientManager.Service
     *   - ClientManager.Characteristic
     * @returns {void} 无返回值
     */
    function show(context: QtObject, uuid: string, currentName: string, attributeType: int) {
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

        // 赋值
        popup.attributeUuid = uuid;
        new_name_text_box.text = currentName;
        popup.attributeType = attributeType;
        popup.open();
    }

    /**
     * 显示
     * @param {QtObject} context - 上下文, 在哪里调用show, 就传入它的id, 或者传入this
     * @param {QtObject} info - ServiceInfo 或者 CharacteristicInfo (传入 modelData)
     * @returns {void} 无返回值
     */
    function showWithInfo(context: QtObject, info: QtObject) {
        var attributeType = ClientManager.Unknown;
        if (info instanceof ServiceInfo) {
            attributeType = ClientManager.Service;
        } else if (info instanceof CharacteristicInfo) {
            attributeType = ClientManager.Characteristic;
        }
        popup.attributeInfo = info;
        popup.show(context, info.uuid, info.name, attributeType);
    }

    bottomMargin: 4
    height: implicitHeight
    spacing: 0
    topMargin: 4
    width: 325

    onClosed: {
        popup.attributeUuid = "";
        new_name_text_box.text = "";
        popup.attributeType = ClientManager.Unknown;
        popup.attributeInfo = null;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        /* 标题 */
        FluText {
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 16
            font: FluTextStyle.BodyStrong
            text: {
                if (attributeType === ClientManager.Service) {
                    return qsTr("Rename Service");
                } else if (attributeType === ClientManager.Characteristic) {
                    return qsTr("Rename Characteristic");
                } else {
                    return qsTr("Rename");
                }
            }
        }
        FluText {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            color: FluTheme.fontSecondaryColor
            elide: Text.ElideRight
            text: popup.attributeUuid
        }

        /* 分界线 */
        FluDivider {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.topMargin: 8
        }

        /* 输入框 */
        FluTextBox {
            id: new_name_text_box

            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 16
            placeholderText: qsTr("Enter new name")
        }

        /* 取消 保存 按钮 */
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
                text: qsTr("Save")

                onClicked: {
                    popup.saveButtonClicked(popup.attributeUuid, new_name_text_box.text, popup.attributeType, popup.attributeInfo);
                    popup.close();
                }
            }
        }
    }
}
