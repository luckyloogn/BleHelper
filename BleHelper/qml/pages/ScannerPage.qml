import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../controls"

FluPage {
    id: page

    padding: 0
    title: qsTr("Scanner")

    Component.onCompleted: {
        if (ClientManager.filteredDevices.length === 0) {
            start_scan_delay_timer.restart();
        }
    }

    Connections {
        function onIsDeviceConnectedChanged() {
            if (ClientManager.isDeviceConnected === true) {
                connecting_dialog.close();
            }
        }
        function onRequestPairingSucceeded(devInfo) {
            if (devInfo.isPaired) {
                showSuccess(qsTr("Successfully paired with \"%1\".").arg(devInfo.name));
            } else {
                showSuccess(qsTr("Successfully unpaired with \"%1\".").arg(devInfo.name));
            }
        }

        target: ClientManager
    }
    Timer {
        id: start_scan_delay_timer

        interval: 500

        onTriggered: {
            if (ClientManager.isBluetoothOn && !ClientManager.isScanning) {
                ClientManager.startScan();
            }
        }
    }
    FluContentDialog {
        id: bluetooth_disabled_dialog

        buttonFlags: FluContentDialogType.PositiveButton | FluContentDialogType.NegativeButton
        message: qsTr("This application cannot be used without Bluetooth. Please switch Bluetooth ON to continue.")
        negativeText: qsTr("Cancel")
        positiveText: qsTr("Turn on Bluetooth")
        title: qsTr("Tip")

        onPositiveClicked: {
            ClientManager.enableBluetooth();
            start_scan_delay_timer.restart();
        }
    }
    FluContentDialog {
        id: connecting_dialog

        property string device_name: ""

        function show(name, address) {
            connecting_dialog.device_name = name;
            connecting_dialog.open();
        }

        buttonFlags: FluContentDialogType.NegativeButton
        message: qsTr("Connecting to \"%1\"...").arg(device_name)
        negativeText: qsTr("Cancel")
        title: qsTr("Connecting")

        contentDelegate: Component {
            Item {
                implicitHeight: 36
                implicitWidth: parent.width

                MyFluProgressBar {
                    anchors.centerIn: parent
                    strokeWidth: 3
                    width: parent.width - 40
                }
            }
        }

        onNegativeClicked: {
            ClientManager.disconnectFromDevice();
        }
    }
    FluMenu {
        id: device_item_more_menu

        property string address: ""
        property bool isFavorite: false
        property bool isPaired: false
        property string name: ""

        function show(address, name, isFavorite, isPaired) {
            device_item_more_menu.address = address;
            device_item_more_menu.name = name;
            device_item_more_menu.isFavorite = isFavorite;
            device_item_more_menu.isPaired = isPaired;
            device_item_more_menu.popup();
        }

        height: implicitHeight
        width: implicitWidth

        FluMenuItem {
            iconSpacing: 8
            text: device_item_more_menu.isFavorite ? qsTr("Unfavorite") : qsTr("Favorite")

            iconDelegate: MyFluIcon {
                iconSize: 12
                iconSource: device_item_more_menu.isFavorite ? MyFluIcon.Unfavorite : MyFluIcon.Favorite
            }

            onTriggered: {
                if (device_item_more_menu.isFavorite) {
                    ClientManager.deleteDeviceFromFavorites(device_item_more_menu.address);
                    showSuccess(qsTr("\"%1\" has been deleted from the favorites.").arg(device_item_more_menu.name));
                } else {
                    ClientManager.insertDeviceToFavorites(device_item_more_menu.address, device_item_more_menu.name);
                    showSuccess(qsTr("\"%1\" has been inserted to the favorites.").arg(device_item_more_menu.name));
                }
            }
        }
        FluMenuItem {
            iconSpacing: 8
            text: device_item_more_menu.isPaired ? qsTr("Unpair") : qsTr("Pair")

            iconDelegate: MyFluIcon {
                iconSize: 12
                iconSource: device_item_more_menu.isPaired ? MyFluIcon.Unpair : MyFluIcon.Pair
            }

            onTriggered: {
                device_item_more_menu.close();
                if (device_item_more_menu.isPaired) {
                    ClientManager.unpairWithDevice(device_item_more_menu.address);
                } else {
                    ClientManager.pairWithDevice(device_item_more_menu.address);
                }
            }
        }
    }
    MyFluPopup {
        id: filter_popup

        height: implicitHeight
        parent: filter_button
        spacing: 0
        width: implicitWidth
        x: parent.width - width
        y: parent.height + 5

        onOpened: {
            // Popup 不会每次都重新实例化（即不会重新创建其内容）
            filter_by_name_text_box.text = ClientManager.filterParams.name;
            filter_by_address_text_box.text = ClientManager.filterParams.address;
            filter_by_rssi_slider.value = ClientManager.filterParams.rssiValue;
            filter_is_only_favourite_check_box.checked = ClientManager.filterParams.isOnlyFavourite;
            filter_is_only_connected_check_box.checked = ClientManager.filterParams.isOnlyConnected;
            filter_is_only_paired_check_box.checked = ClientManager.filterParams.isOnlyPaired;
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            /* 标题 清除按钮 */
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8

                FluText {
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("Filter")
                }
                Item {
                    Layout.fillWidth: true // 占位符，用于推开两侧的元素
                }
                FluTextButton {
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("Clear")

                    onClicked: {
                        filter_by_name_text_box.text = "";
                        filter_by_address_text_box.text = "";
                        filter_by_rssi_slider.value = filter_by_rssi_slider.from;
                        filter_is_only_favourite_check_box.checked = false;
                        filter_is_only_connected_check_box.checked = false;
                        filter_is_only_paired_check_box.checked = false;
                    }
                }
            }
            FluDivider {
                Layout.bottomMargin: 8
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.topMargin: 8
            }

            /* 过滤项目 */
            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8
                columnSpacing: 16
                columns: 4
                rowSpacing: 8
                rows: 4

                MyFluIcon {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    iconSize: 16
                    iconSource: MyFluIcon.DeviceName
                }
                FluTextBox {
                    id: filter_by_name_text_box

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
                FluTextBox {
                    id: filter_by_address_text_box

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
                    id: filter_by_rssi_slider

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
                        text: filter_by_rssi_slider.value + qsTr("dBm")

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
                    id: filter_is_only_favourite_check_box

                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    Layout.fillWidth: true
                    checked: ClientManager.filterParams.isOnlyFavourite
                    text: qsTr("Favorites")
                }
                FluCheckBox {
                    id: filter_is_only_connected_check_box

                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    Layout.fillWidth: true
                    checked: ClientManager.filterParams.isOnlyConnected
                    text: qsTr("Connected")
                }
                FluCheckBox {
                    id: filter_is_only_paired_check_box

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
                        filter_popup.close();
                    }
                }
                FluFilledButton {
                    Layout.alignment: Qt.AlignVCenter
                    text: qsTr("Apply")

                    onClicked: {
                        filter_popup.close();
                        ClientManager.filterParams.name = filter_by_name_text_box.text;
                        ClientManager.filterParams.address = filter_by_address_text_box.text;
                        ClientManager.filterParams.rssiValue = filter_by_rssi_slider.value;
                        ClientManager.filterParams.isOnlyFavourite = filter_is_only_favourite_check_box.checked;
                        ClientManager.filterParams.isOnlyConnected = filter_is_only_connected_check_box.checked;
                        ClientManager.filterParams.isOnlyPaired = filter_is_only_paired_check_box.checked;
                        ClientManager.updateFilteredDevices();
                    }
                }
            }
        }
    }
    FluFrame {
        id: bluetooth_control_container

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
        FluIcon {
            id: bluetooth_icon

            iconSize: 20
            iconSource: FluentIcons.Bluetooth
            padding: 6

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
        }
        FluText {
            text: qsTr("Bluetooth")

            anchors {
                left: bluetooth_icon.right
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
        }
        FluToggleSwitch {
            property bool isBluetoothOn: ClientManager.isBluetoothOn

            checked: isBluetoothOn
            text: isBluetoothOn ? qsTr("On") : qsTr("Off")
            textRight: false

            onClicked: {
                if (checked) {
                    ClientManager.enableBluetooth();
                } else {
                    ClientManager.disableBluetooth();
                }
            }
            onIsBluetoothOnChanged: {
                checked = isBluetoothOn;
            }

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
        }
    }
    FluFrame {
        id: find_device_container

        height: 70
        padding: 16

        anchors {
            left: parent.left
            leftMargin: 16
            right: parent.right
            rightMargin: 16
            top: bluetooth_control_container.bottom
            topMargin: 4
        }
        FluIcon {
            id: search_icon

            iconSize: 20
            iconSource: FluentIcons.Search
            padding: 6

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
        }
        FluText {
            text: qsTr("Find devices")

            anchors {
                left: search_icon.right
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
        }
        FluProgressRing {
            height: 20
            strokeWidth: 2
            visible: ClientManager.isScanning
            width: 20

            background: Item {
            }

            anchors {
                right: toggle_scan_button.left
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
        }
        FluFilledButton {
            id: toggle_scan_button

            text: {
                if (ClientManager.isScanning) {
                    qsTr("Stop Scanning");
                } else {
                    qsTr("Start Scanning");
                }
            }

            onClicked: {
                if (ClientManager.isBluetoothOn === false) {
                    bluetooth_disabled_dialog.open();
                    return;
                }
                if (ClientManager.isScanning) {
                    ClientManager.stopScan();
                } else {
                    ClientManager.startScan();
                }
            }

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
        }
    }
    RowLayout {
        id: subtitle_filter_sort_container

        anchors {
            left: parent.left
            leftMargin: 16
            right: parent.right
            rightMargin: 16
            top: find_device_container.bottom
            topMargin: 30
        }
        FluText {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            font: FluTextStyle.BodyStrong
            text: qsTr("Devices")
        }
        Row {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            spacing: 4

            MyFluIconButton {
                id: filter_button

                display: Button.TextBesideIcon
                horizontalPadding: 4
                iconSize: 12
                iconSource: MyFluIcon.Filter
                text: qsTr("Filter")
                verticalPadding: 4

                onClicked: {
                    filter_popup.open();
                }
            }
            MyFluIconButton {
                display: Button.TextBesideIcon
                horizontalPadding: 4
                iconSize: 12
                iconSource: MyFluIcon.DescendingSort
                text: qsTr("Sort by RSSI")
                verticalPadding: 4

                onClicked: {
                    ClientManager.sortByRssi();
                    showSuccess(qsTr("Sort by RSSI in descending order."));
                }
            }
        }
    }
    ListView {
        clip: true
        focus: true
        model: ClientManager.filteredDevices
        spacing: 4

        ScrollBar.vertical: FluScrollBar {
            policy: ScrollBar.AsNeeded
        }
        delegate: Item {
            required property int index
            required property var modelData

            height: 70
            width: ListView.view.width

            FluFrame {
                anchors {
                    fill: parent
                    leftMargin: 16
                    rightMargin: 16
                }
                Rectangle {
                    anchors.fill: parent
                    color: {
                        if (device_item_mouse_area.containsMouse) {
                            return FluTheme.itemHoverColor;
                        }
                        return FluTheme.itemNormalColor;
                    }
                    radius: 4

                    Behavior on color {
                        enabled: FluTheme.animationEnabled

                        ColorAnimation {
                            duration: 167
                            easing.type: Easing.OutCubic
                        }
                    }
                }
                MouseArea {
                    id: device_item_mouse_area

                    anchors.fill: parent
                    enabled: modelData.isConnected
                    hoverEnabled: true

                    onClicked: {
                        ClientManager.isDeviceConnectedChanged();
                    }
                }
                RowLayout {
                    spacing: 16

                    anchors {
                        left: parent.left
                        leftMargin: 16
                        verticalCenter: parent.verticalCenter
                    }
                    FluIcon {
                        iconSize: 20
                        iconSource: FluentIcons.Bluetooth
                        padding: 6
                    }
                    Column {
                        FluText {
                            text: modelData.name
                        }
                        RowLayout {
                            spacing: 10

                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                color: FluColors.Grey120
                                text: modelData.address
                            }
                            FluDivider {
                                Layout.alignment: Qt.AlignVCenter
                                height: 12
                                orientation: Qt.Vertical
                            }
                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                color: FluColors.Grey120
                                text: modelData.rssi + qsTr(" dBm")
                            }
                            FluDivider {
                                Layout.alignment: Qt.AlignVCenter
                                height: 12
                                orientation: Qt.Vertical
                                visible: modelData.isFavorite
                            }
                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                color: FluColors.Grey120
                                text: qsTr("Favorited")
                                visible: modelData.isFavorite
                            }
                            FluDivider {
                                Layout.alignment: Qt.AlignVCenter
                                height: 12
                                orientation: Qt.Vertical
                                visible: modelData.isConnected
                            }
                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                color: FluColors.Grey120
                                text: qsTr("Connected")
                                visible: modelData.isConnected
                            }
                            FluDivider {
                                Layout.alignment: Qt.AlignVCenter
                                height: 12
                                orientation: Qt.Vertical
                                visible: modelData.isPaired
                            }
                            FluText {
                                Layout.alignment: Qt.AlignVCenter
                                color: FluColors.Grey120
                                text: qsTr("Paired")
                                visible: modelData.isPaired
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: 4

                    anchors {
                        right: parent.right
                        rightMargin: 16
                        verticalCenter: parent.verticalCenter
                    }
                    FluButton {
                        text: modelData.isConnected ? qsTr("Disconnect") : qsTr("Connect")

                        onClicked: {
                            if (modelData.isConnected) {
                                ClientManager.disconnectFromDevice();
                                showSuccess(qsTr("Disconnect"));
                            } else {
                                connecting_dialog.show(modelData.name, modelData.address);
                                ClientManager.connectToDevice(modelData.address);
                            }
                        }
                    }
                    FluIconButton {
                        iconSize: 16
                        iconSource: FluentIcons.More
                        text: qsTr("More Options")

                        onClicked: {
                            device_item_more_menu.show(modelData.address, modelData.name, modelData.isFavorite, modelData.isPaired);
                        }
                    }
                }
            }
        }

        anchors {
            bottom: parent.bottom
            bottomMargin: 16
            left: parent.left
            right: parent.right
            top: subtitle_filter_sort_container.bottom
            topMargin: 5
        }
    }
}
