import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../controls"

MyFluPopup {
    id: popup

    property CharacteristicInfo characteristicInfo: null
    property ServiceInfo serviceInfo: null

    signal sendButtonClicked(ServiceInfo serviceInfo, CharacteristicInfo characteristicInfo, string hexEncoded, int writeMode)

    function asciiToHex(ascii) {
        let result = "";
        for (let i = 0; i < ascii.length; i++) {
            result += ascii.charCodeAt(i).toString(16).padStart(2, "0") + " ";
        }
        return result.trim().toUpperCase();
    }
    function decimalToHex(decimal) {
        let result = "";
        let arr = decimal.split(" ");
        for (let i = 0; i < arr.length; i++) {
            result += parseInt(arr[i], 10).toString(16).padStart(2, "0") + " ";
        }
        return result.trim().toUpperCase();
    }
    function hexToAscii(hex) {
        let result = "";
        let arr = hex.split(" ");
        for (let i = 0; i < arr.length; i++) {
            result += String.fromCharCode(parseInt(arr[i], 16));
        }
        return result;
    }
    function hexToDecimal(hex) {
        let result = "";
        let arr = hex.split(" ");
        for (let i = 0; i < arr.length; i++) {
            result += parseInt(arr[i], 16).toString(10).padStart(3, "0") + " ";
        }
        return result.trim();
    }

    /**
     * 显示
     * @param {QtObject} context - 上下文, 在哪里调用show, 就传入它的id, 或者传入this
     * @param {QtObject} serviceInfo - ServiceInfo
     * @param {QtObject} characteristicInfo - CharacteristicInfo
     * @returns {void} 无返回值
     */
    function show(context: QtObject, serviceInfo: QtObject, characteristicInfo: QtObject) {
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
        popup.serviceInfo = serviceInfo;
        popup.characteristicInfo = characteristicInfo;
        popup.open();
    }

    bottomMargin: 4
    height: implicitHeight
    leftMargin: 0
    rightMargin: 0
    spacing: 0
    topMargin: 4
    width: 390

    onClosed: {
        popup.characteristicInfo = null;
        popup.serviceInfo = null;
        hex_input.text = "";
    }
    onOpened: {
        if (popup.characteristicInfo) {
            if (popup.characteristicInfo.canWrite && popup.characteristicInfo.canWriteNoResponse) {
                write_mode.enabled = true;
            } else if (!popup.characteristicInfo.canWrite && popup.characteristicInfo.canWriteNoResponse) {
                write_mode.enabled = false;
                write_mode.currentIndex = write_mode.indexOfValue(ClientManager.WriteWithoutResponse);
            } else if (popup.characteristicInfo.canWrite && !popup.characteristicInfo.canWriteNoResponse) {
                write_mode.enabled = false;
                write_mode.currentIndex = write_mode.indexOfValue(ClientManager.WriteWithResponse);
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        /* 标题 */
        FluText {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 16
            font: FluTextStyle.BodyStrong
            text: qsTr("Write New Value")
        }
        FluText {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            color: FluTheme.fontSecondaryColor
            text: popup.characteristicInfo ? popup.characteristicInfo.name : ""
        }
        FluText {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            color: FluTheme.fontSecondaryColor
            text: popup.characteristicInfo ? popup.characteristicInfo.uuid : ""
        }

        /* 分界线 */
        FluDivider {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.topMargin: 8
        }

        /* 输入框 */
        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 16
            columnSpacing: 0
            columns: 2
            rowSpacing: 8
            rows: 3

            FluText {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("Hex: ")
            }
            MyFluTextBox {
                id: hex_input

                function formatInput(input) {
                    // 去掉所有非十六进制字符
                    var cleanedText = text.replace(/[^0-9A-Fa-f]/g, "");

                    // 自动插入空格，每2个字符插入一个空格
                    var formattedText = cleanedText.replace(/(.{2})(?=.)/g, "$1 ");

                    return formattedText;
                }

                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                placeholderText: qsTr("Hex")

                validator: RegularExpressionValidator {
                    // 只允许十六进制字符和空格(不允许空格无法进行粘贴)
                    regularExpression: /^[0-9A-Fa-f\s]*$/
                }

                onTextChanged: {
                    if (text === "") {
                        ascii_input.text = "";
                        decimal_input.text = "";
                    }
                }
                onTextEdited: {
                    if (text !== "") {
                        var formattedText = formatInput(text);
                        if (formattedText !== text) {
                            text = formattedText;
                            cursorPosition = text.length;
                            ascii_input.text = popup.hexToAscii(text);
                            decimal_input.text = popup.hexToDecimal(text);
                        }
                    }
                }
            }
            FluText {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("ASCII: ")
            }
            MyFluTextBox {
                id: ascii_input

                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                placeholderText: qsTr("ASCII")

                onTextChanged: {
                    if (text === "") {
                        hex_input.text = "";
                        decimal_input.text = "";
                    }
                }
                onTextEdited: {
                    if (text !== "") {
                        hex_input.text = popup.asciiToHex(text);
                        decimal_input.text = popup.hexToDecimal(popup.asciiToHex(text));
                    }
                }
            }
            FluText {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("Decimal: ")
            }
            MyFluTextBox {
                id: decimal_input

                function formatInput(input) {
                    // 移除所有非数字字符
                    input = input.replace(/\D/g, '');
                    var chunks = [];

                    // 每3位为一组
                    for (var i = 0; i < input.length; i += 3) {
                        chunks.push(input.substring(i, i + 3));
                    }

                    // 检查每一组是否在0到255之间
                    chunks = chunks.filter(function (chunk) {
                        return parseInt(chunk) <= 255;
                    });

                    // 将每组3位数字连接起来并加上空格
                    var formattedText = chunks.join(' ');
                    return formattedText;
                }

                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhDigitsOnly  // 限制为数字
                placeholderText: qsTr("Decimal")

                onTextChanged: {
                    if (text === "") {
                        hex_input.text = "";
                        ascii_input.text = "";
                    }
                }
                onTextEdited: {
                    if (text !== "") {
                        var formattedText = formatInput(text);
                        if (formattedText !== text) {
                            text = formattedText;
                            cursorPosition = text.length;
                            hex_input.text = popup.decimalToHex(text);
                            ascii_input.text = popup.hexToAscii(popup.decimalToHex(text));
                        }
                    }
                }
            }
            FluText {
                Layout.alignment: Qt.AlignVCenter
                text: "Mode: "
            }
            MyFluComboBox {
                id: write_mode

                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "value"

                model: ListModel {
                    ListElement {
                        text: qsTr("Write with Response (Write Request)")
                        value: ClientManager.WriteWithResponse
                    }
                    ListElement {
                        text: qsTr("Write without Response (Write Command)")
                        value: ClientManager.WriteWithoutResponse
                    }
                }
            }
        }

        /* 取消 发送 按钮 */
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
                text: qsTr("Cancel")

                onClicked: {
                    popup.close();
                }
            }
            FluFilledButton {
                text: qsTr("Send")

                onClicked: {
                    let hexParts = hex_input.text.split(' ');
                    if (hexParts.length > 0) {
                        hexParts[hexParts.length - 1] = hexParts[hexParts.length - 1].padStart(2, '0');
                    }
                    let hexEncoded = hexParts.join('');
                    popup.sendButtonClicked(popup.serviceInfo, popup.characteristicInfo, hexEncoded, write_mode.currentValue);
                    popup.close();
                }
            }
        }
    }
}
