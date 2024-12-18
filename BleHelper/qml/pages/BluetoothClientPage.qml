import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../controls"

MyFluNestedPageView {
    id: nested_page_view

    headerLeftPadding: 16
    headerRightPadding: 16
    padding: 0
    title: qsTr("Bluetooth Client")

    Component.onCompleted: {
        if (ClientManager.isDeviceConnected === true) {
            nested_page_view.setCurrentIndex(1);
        }
    }

    Connections {
        function onErrorOccurred(error) {
            if (error === ClientManager.PairingError) {
                showError(qsTr("Pairing error!"));
            } else if (error === ClientManager.ConnectionError) {
                showError(qsTr("The attempt to connect to the remote device failed."));
            } else if (error === ClientManager.RemoteHostClosedError) {
                error_occurred_dialog.show(qsTr("The remote device closed the connection."));
            } else if (error === ClientManager.UnknownError) {
                error_occurred_dialog.show(qsTr("Sorry, an unknown error occurred."));
            }
        }
        function onIsDeviceConnectedChanged() {
            if (ClientManager.isDeviceConnected === true) {
                nested_page_view.setCurrentIndex(1);
            } else {
                nested_page_view.setCurrentIndex(0);
            }
        }

        target: ClientManager
    }
    FluLoader {
        // Flipable(id: flipable)控件位于MainWindow, 当"右键->移动到新窗口"时, 由于NewWindow没有Flipable控件,
        // id: flipable不存在或flipable为null时, FluLoader不激活, 不加载返回按钮, 使用FluLoader可避免undefined或null导致的报错
        active: flipable !== undefined && flipable !== null

        sourceComponent: Component {
            Item {
                parent: flipable
                visible: nested_page_view.currentIndex > 0 && flipable.flipped === false

                anchors {
                    left: parent.left
                    leftMargin: 5
                    top: parent.top
                    topMargin: FluTools.isMacos() ? 20 : 5
                }
                FluIconButton {
                    height: 30
                    iconSize: 13
                    iconSource: FluentIcons.ChromeBack
                    width: 30
                    z: 65535

                    onClicked: {
                        nested_page_view.previousPage();
                    }
                }

                // 下面的Rectangle设置为和窗口颜色一样, 覆盖掉FluNavigationView左上角的返回按钮,
                // 避免多个返回图标重叠显示加粗破坏ui统一性
                Rectangle {
                    color: {
                        if (Window.active) {
                            return FluTheme.windowActiveBackgroundColor;
                        }
                        return FluTheme.windowBackgroundColor;
                    }
                    height: 32
                    width: 32
                }
            }
        }
    }
    FluContentDialog {
        id: error_occurred_dialog

        function show(msg) {
            error_occurred_dialog.message = msg;
            error_occurred_dialog.open();
        }

        buttonFlags: FluContentDialogType.NegativeButton
        message: qsTr("Unknown error.")
        negativeText: qsTr("Close")
        title: qsTr("Error")

        onNegativeClicked: {
            error_occurred_dialog.close();
        }
    }
    ScannerPage {
    }
    ConnectionPage {
    }
}
