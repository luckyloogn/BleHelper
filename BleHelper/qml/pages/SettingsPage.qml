import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../controls"
import "../models"

FluScrollablePage {
    id: page

    padding: 0

    header: Item {
        implicitHeight: 50

        FluText {
            font: FluTextStyle.Title
            text: qsTr("Settings")

            anchors {
                left: parent.left
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
        }
    }

    ColumnLayout {
        Layout.bottomMargin: 16
        Layout.fillWidth: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        Layout.topMargin: 16
        spacing: 4

        /* Appearance */
        FluText {
            Layout.bottomMargin: 5
            Layout.topMargin: 10
            font: FluTextStyle.BodyStrong
            text: qsTr("Appearance")
        }
        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Application Theme")

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            MyFluComboBox {
                textRole: "text"
                valueRole: "value"
                width: Math.max(180, implicitWidth)

                model: ListModel {
                    ListElement {
                        text: qsTr("Use System Setting")
                        value: FluThemeType.System
                    }
                    ListElement {
                        text: qsTr("Light")
                        value: FluThemeType.Light
                    }
                    ListElement {
                        text: qsTr("Dark")
                        value: FluThemeType.Dark
                    }
                }

                Component.onCompleted: {
                    currentIndex = indexOfValue(FluTheme.darkMode);
                }
                onActivated: {
                    if (FluTheme.darkMode !== currentValue) {
                        FluTheme.darkMode = currentValue;
                        SettingsManager.saveDarkMode(FluTheme.darkMode);
                    }
                }

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }
        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Navigation Pane Display Mode")

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            MyFluComboBox {
                textRole: "text"
                valueRole: "value"
                width: Math.max(180, implicitWidth)

                model: ListModel {
                    ListElement {
                        text: qsTr("Open")
                        value: FluNavigationViewType.Open
                    }
                    ListElement {
                        text: qsTr("Compact")
                        value: FluNavigationViewType.Compact
                    }
                    ListElement {
                        text: qsTr("Minimal")
                        value: FluNavigationViewType.Minimal
                    }
                    ListElement {
                        text: qsTr("Auto")
                        value: FluNavigationViewType.Auto
                    }
                }

                Component.onCompleted: {
                    currentIndex = indexOfValue(GlobalModel.navigationViewType);
                }
                onActivated: {
                    if (GlobalModel.navigationViewType !== currentValue) {
                        GlobalModel.navigationViewType = currentValue;
                        SettingsManager.saveNavigationViewType(GlobalModel.navigationViewType);
                    }
                }

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }
        MyFluExpander {
            Layout.fillWidth: true
            contentHeight: accent_color_expander_content_container.implicitHeight
            expand: true
            headerHeight: 70
            headerText: qsTr("Accent Color")

            content: ColumnLayout {
                id: accent_color_expander_content_container

                anchors.fill: parent

                ColumnLayout {
                    Layout.bottomMargin: 16
                    Layout.topMargin: 16
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16

                        FluText {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.fillWidth: true
                            text: qsTr("Preset Colors")
                        }
                        Row {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            spacing: 4

                            Repeater {
                                model: GlobalModel.presetColors

                                delegate: Rectangle {
                                    border.color: modelData.darker
                                    color: accent_color_item_mouse_area.containsMouse ? Qt.lighter(modelData.normal, 1.1) : modelData.normal
                                    height: 30
                                    radius: 4
                                    width: 30

                                    FluIcon {
                                        anchors.centerIn: parent
                                        color: FluTheme.dark ? Qt.rgba(0, 0, 0, 1) : Qt.rgba(1, 1, 1, 1)
                                        iconSize: 16
                                        iconSource: FluentIcons.AcceptMedium
                                        visible: modelData === FluTheme.accentColor
                                    }
                                    MouseArea {
                                        id: accent_color_item_mouse_area

                                        anchors.fill: parent
                                        hoverEnabled: true

                                        onClicked: {
                                            FluTheme.accentColor = modelData;
                                            SettingsManager.saveAccentNormalColor(FluTheme.accentColor.normal);
                                            theme_color_picker.current = FluTheme.accentColor.normal;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    FluDivider {
                        Layout.fillWidth: true
                        orientation: Qt.Horizontal
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        spacing: 12

                        FluText {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.fillWidth: true
                            text: qsTr("Custom Colors")
                        }
                        MyFluColorPicker {
                            id: theme_color_picker

                            Layout.alignment: Qt.AlignVCenter
                            current: FluTheme.accentColor.normal
                            dialogHeight: 465
                            enabled: false
                            height: 30
                            isAlphaEnabled: false
                            visible: !GlobalModel.presetColors.includes(FluTheme.accentColor)
                            width: 30

                            background: Rectangle {
                                border.color: FluTheme.dividerColor
                                color: theme_color_picker.current
                                radius: 5
                            }

                            onAccepted: {
                                FluTheme.accentColor = GlobalModel.createAccentColor(current);
                                SettingsManager.saveAccentNormalColor(current);
                            }

                            FluIcon {
                                anchors.centerIn: parent
                                color: FluTheme.dark ? Qt.rgba(0, 0, 0, 1) : Qt.rgba(1, 1, 1, 1)
                                iconSize: 16
                                iconSource: FluentIcons.AcceptMedium
                            }
                        }
                        FluButton {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            text: qsTr("View Colors")

                            onClicked: theme_color_picker.clicked()
                        }
                    }
                }
            }
        }
        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Animation Effects")

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            FluToggleSwitch {
                checked: FluTheme.animationEnabled
                text: checked ? qsTr("On") : qsTr("Off")
                textRight: false

                onClicked: {
                    FluTheme.animationEnabled = checked;
                    SettingsManager.saveAnimationEnabled(FluTheme.animationEnabled);
                }

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }
        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Transparency Effects")

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            FluToggleSwitch {
                checked: FluTheme.blurBehindWindowEnabled
                text: checked ? qsTr("On") : qsTr("Off")
                textRight: false

                onClicked: {
                    FluTheme.blurBehindWindowEnabled = checked;
                    SettingsManager.saveBlurBehindWindowEnabled(FluTheme.blurBehindWindowEnabled);
                }

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }
        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Use Native Text Rendering")

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            FluToggleSwitch {
                checked: FluTheme.nativeText
                text: checked ? qsTr("On") : qsTr("Off")
                textRight: false

                onClicked: {
                    FluTheme.nativeText = checked;
                    SettingsManager.saveNativeTextEnabled(FluTheme.nativeText);
                }

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }

        /* Localization */
        FluText {
            Layout.bottomMargin: 5
            Layout.topMargin: 15
            font: FluTextStyle.BodyStrong
            text: qsTr("Localization")
        }
        FluFrame {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            padding: 16

            FluText {
                text: qsTr("Language")

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
            MyFluComboBox {
                model: SettingsManager.supportedLanguages
                textRole: "name"
                valueRole: "code"
                width: Math.max(180, implicitWidth)

                Component.onCompleted: {
                    currentIndex = indexOfValue(GlobalModel.language);
                }
                onActivated: {
                    if (GlobalModel.language !== currentValue) {
                        GlobalModel.language = currentValue;
                        SettingsManager.saveLanguage(GlobalModel.language);
                    }
                }

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }

        /* About */
        FluText {
            Layout.bottomMargin: 5
            Layout.topMargin: 15
            font: FluTextStyle.BodyStrong
            text: qsTr("About")
        }
        MyFluExpander {
            Layout.fillWidth: true
            contentHeight: about_expander_content_container.implicitHeight
            expand: false
            headerHeight: 70

            content: Item {
                anchors.fill: parent

                ColumnLayout {
                    id: about_expander_content_container

                    anchors.fill: parent
                    spacing: 0

                    FluText {
                        Layout.leftMargin: 16
                        Layout.topMargin: 16
                        text: qsTr("Author: ") + ApplicationInfo.author
                    }
                    FluText {
                        Layout.leftMargin: 16
                        Layout.topMargin: 2
                        text: qsTr("Built on: ") + ApplicationInfo.buildDateTime
                    }
                    FluDivider {
                        Layout.fillWidth: true
                        Layout.topMargin: 16
                        orientation: Qt.Horizontal
                    }
                    MyFluTextButton {
                        Layout.leftMargin: 10
                        Layout.topMargin: 4
                        text: qsTr("Check out this project on GitHub")

                        onClicked: {
                            Qt.openUrlExternally(ApplicationInfo.repositoryUrl);
                        }
                    }
                    FluDivider {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        orientation: Qt.Horizontal
                    }
                    FluText {
                        Layout.leftMargin: 16
                        Layout.topMargin: 16
                        text: qsTr("Dependencies & References")
                    }
                    MyFluTextButton {
                        Layout.bottomMargin: 12
                        Layout.leftMargin: 12
                        Layout.topMargin: 4
                        horizontalPadding: 4
                        text: "FluentUI"
                        verticalPadding: 4

                        onClicked: {
                            Qt.openUrlExternally("https://github.com/zhuzichu520/FluentUI");
                        }
                    }
                }
            }
            headerDelegate: Component {
                Item {
                    function checkForUpdates() {
                        console.debug("start check update...");
                        var url = ApplicationInfo.updateCheckUrl;
                        var xhr = new XMLHttpRequest();
                        xhr.open("GET", url, true);
                        xhr.onreadystatechange = function () {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                if (xhr.status === 200) {
                                    // 200 OK: 请求成功，服务器返回了请求的数据
                                    var data = JSON.parse(xhr.responseText);
                                    var latestReleaseVersionName = data.tag_name;
                                    var latestReleaseInfo = data.body;
                                    if (latestReleaseVersionName !== ApplicationInfo.versionName) {
                                        update_dialog.show(latestReleaseVersionName, latestReleaseInfo);
                                    } else {
                                        showInfo(qsTr("The application is up to date."));
                                    }
                                    check_for_update_button.enabled = false;
                                    check_for_update_success_icon.visible = true;
                                    check_for_update_progress_ring.visible = false;
                                } else {
                                    showError(qsTr("Failed to connect to server. Check your network connection and try again."));
                                    console.debug("Check update error: " + xhr.status);
                                    check_for_update_button.enabled = true;
                                    check_for_update_progress_ring.visible = false;
                                }
                            }
                        };
                        xhr.send();
                    }

                    RowLayout {
                        spacing: 12

                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        FluImage {
                            source: "qrc:/resources/images/icons/logo.svg"
                            sourceSize.height: 30
                            sourceSize.width: 30
                        }
                        Column {
                            FluText {
                                text: qsTr("BLE Helper")
                            }
                            FluText {
                                text: ApplicationInfo.versionName
                                textColor: FluTheme.fontSecondaryColor
                            }
                        }
                    }
                    Item {
                        height: 20
                        width: 20

                        anchors {
                            right: check_for_update_button.left
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        FluProgressRing {
                            id: check_for_update_progress_ring

                            anchors.centerIn: parent
                            anchors.fill: parent
                            strokeWidth: 2
                            visible: false

                            background: Item {
                            }
                        }
                        FluIcon {
                            id: check_for_update_success_icon

                            anchors.centerIn: parent
                            iconSource: FluentIcons.CheckMark
                            visible: false
                        }
                    }
                    FluButton {
                        id: check_for_update_button

                        text: qsTr("Check for Updates")

                        onClicked: {
                            check_for_update_button.enabled = false;
                            check_for_update_success_icon.visible = false;
                            check_for_update_progress_ring.visible = true;
                            checkForUpdates();
                        }

                        anchors {
                            right: parent.right
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    FluContentDialog {
                        id: update_dialog

                        property string newVerson
                        property string releaseInfo

                        function show(newVerson, releaseInfo) {
                            update_dialog.newVerson = newVerson;
                            update_dialog.releaseInfo = releaseInfo;
                            update_dialog.open();
                        }

                        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
                        message: qsTr("There is a new update available: ") + qsTr("BLE Helper") + " " + newVerson + "\n\n" + releaseInfo
                        negativeText: qsTr("Cancel")
                        positiveText: qsTr("Update Now")
                        title: qsTr("Software Update")

                        onPositiveClicked: {
                            Qt.openUrlExternally(ApplicationInfo.updateUrl);
                        }
                    }
                }
            }
        }
    }
}
