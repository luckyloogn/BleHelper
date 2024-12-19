import Qt.labs.platform
import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import BleHelper
import FluentUI

import "../controls"
import "../models"

FluWindow {
    id: window

    fitsAppBarWindows: true
    height: 768
    launchMode: FluWindowType.SingleTask
    minimumHeight: 576
    minimumWidth: 768
    title: qsTr("BLE Helper")
    width: 1024

    appBar: FluAppBar {
        closeClickListener: function () {
            close_dialog.open();
        }
        showDark: false
        z: 8
    }

    Component.onCompleted: {
        var w = SettingsManager.windowWidth();
        var h = SettingsManager.windowHeight();
        width = w > minimumWidth ? w : minimumWidth;
        height = h > minimumHeight ? h : minimumHeight;
        moveWindowToDesktopCenter();
        if (SettingsManager.isWindowMaximized()) {
            showMaximized();
        }
    }
    Component.onDestruction: {
        FluRouter.exit();
    }
    onHeightChanged: {
        save_window_state_delay_timer.restart();
    }
    onVisibilityChanged: function (v) {
        save_window_state_delay_timer.restart();
    }
    onWidthChanged: {
        save_window_state_delay_timer.restart();
    }

    Timer {
        id: save_window_state_delay_timer

        interval: 300

        onTriggered: {
            if (visibility === Window.Maximized || visibility === Window.FullScreen) {
                SettingsManager.saveWindowMaximized(true);
                return;
            } else {
                SettingsManager.saveWindowMaximized(false);
                SettingsManager.saveWindowWidth(width);
                SettingsManager.saveWindowHeight(height);
            }
        }
    }
    SystemTrayIcon {
        id: system_tray

        icon.source: "qrc:/resources/images/icons/logo_64x64.png"
        tooltip: qsTr("BLE Helper")
        visible: true

        menu: Menu {
            MenuItem {
                text: qsTr("Quit")

                onTriggered: {
                    FluRouter.exit();
                }
            }
        }

        onActivated: function (reason) {
            if (reason === SystemTrayIcon.Trigger) {
                window.show();
                window.raise();
                window.requestActivate();
            }
        }
    }
    Timer {
        id: window_hide_delay_timer

        interval: 150

        onTriggered: {
            window.hide();
        }
    }
    FluContentDialog {
        id: close_dialog

        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.NeutralButton | FluContentDialogType.PositiveButton
        message: qsTr("Do you want to quit the application?")
        negativeText: qsTr("Minimize")
        neutralText: qsTr("Cancel")
        positiveText: qsTr("Quit")
        title: qsTr("Quit")

        onNegativeClicked: {
            system_tray.showMessage(qsTr("Tip"), qsTr("BLE Helper") + qsTr(" is now hidden from the tray. Click the tray icon to bring the window back."));
            window_hide_delay_timer.restart();
        }
        onPositiveClicked: {
            FluRouter.exit(0);
        }
    }
    Component {
        id: nav_item_right_button_menu_component

        FluMenu {
            width: 192

            FluMenuItem {
                font: FluTextStyle.Caption
                text: qsTr("Move to new Window")

                onClicked: {
                    var key = "/newWindow" + modelData.url;
                    FluRouter.routes[key] = "qrc:/qml/windows/NewWindow.qml";
                    FluRouter.navigate(key, {
                        "title": modelData.title,
                        "url": modelData.url
                    });
                }
            }
        }
    }
    Component {
        id: easter_eggs_component

        Item {
            property string clockFontColor: Qt.rgba(1, 1, 1, 1)
            property int clockFontPixelSize: 70
            property string currentDate: ""
            property string currentDay: ""
            property string dateDayFontColor: Qt.rgba(1, 1, 1, 1)
            property int dateDayFontPixelSize: 20
            property int hours: 0
            property int minutes: 0
            property int seconds: 0
            property var weekDays: [qsTr("Sunday"), qsTr("Monday"), qsTr("Tuesday"), qsTr("Wednesday"), qsTr("Thursday"), qsTr("Friday"), qsTr("Saturday")]

            Component.onCompleted: {
                var url = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=zh-CN";
                var xhr = new XMLHttpRequest();
                xhr.open("GET", url, true);
                xhr.onreadystatechange = function () {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200 && xhr.responseText !== "") {
                            var data = JSON.parse(xhr.responseText);
                            if (data && data.images && data.images.length > 0) {
                                var imageUrl = "https://www.bing.com" + data.images[0].url;
                                background_image.source = imageUrl;
                            }
                        }
                    }
                };
                xhr.send();
            }
            Component.onDestruction: {
                clock_timer.running = false;
            }

            Timer {
                id: clock_timer

                interval: 1000
                repeat: true
                running: true

                onTriggered: {
                    var date = new Date();
                    hours = date.getHours();
                    minutes = date.getMinutes();
                    seconds = date.getSeconds();
                    if (GlobalModel.language.startsWith("zh")) {
                        currentDate = date.toLocaleDateString();
                    } else {
                        currentDate = date.toLocaleDateString(GlobalModel.language.replace('_', '-'));
                    }
                    currentDay = weekDays[date.getDay()];
                }
            }
            Image {
                id: background_image

                anchors.fill: parent
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
            }
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.25)
            }
            ColumnLayout {
                anchors.centerIn: parent

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 5

                    Text {
                        color: clockFontColor
                        font.pixelSize: clockFontPixelSize
                        text: hours < 10 ? "0" + hours : hours
                    }
                    Text {
                        Layout.bottomMargin: 10
                        color: clockFontColor
                        font.pixelSize: clockFontPixelSize
                        text: ":"
                    }
                    Text {
                        color: clockFontColor
                        font.pixelSize: clockFontPixelSize
                        text: minutes < 10 ? "0" + minutes : minutes
                    }
                    Text {
                        Layout.bottomMargin: 10
                        color: clockFontColor
                        font.pixelSize: clockFontPixelSize
                        text: ":"
                    }
                    Text {
                        color: clockFontColor
                        font.pixelSize: clockFontPixelSize
                        text: seconds < 10 ? "0" + seconds : seconds
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 30

                    FluText {
                        color: dateDayFontColor
                        font.pixelSize: dateDayFontPixelSize
                        text: currentDate
                    }
                    FluText {
                        color: dateDayFontColor
                        font.pixelSize: dateDayFontPixelSize
                        text: currentDay
                    }
                }
            }
        }
    }
    Flipable {
        id: flipable

        property real flipAngle: 0
        property bool flipped: false

        anchors.fill: parent

        back: Item {
            anchors.fill: flipable
            visible: flipable.flipAngle !== 0

            Row {
                id: back_buttons_layout

                z: 8

                Component.onCompleted: {
                    window.setHitTestVisible(back_buttons_layout);
                }

                anchors {
                    left: parent.left
                    leftMargin: 5
                    top: parent.top
                    topMargin: FluTools.isMacos() ? 20 : 5
                }
                FluIconButton {
                    height: 30
                    iconColor: Qt.rgba(1, 1, 1, 1)
                    iconSize: 13
                    iconSource: FluentIcons.ChromeBack
                    width: 30

                    onClicked: {
                        flipable.flipped = false;
                    }
                }
            }
            FluLoader {
                active: flipable.flipped
                anchors.fill: parent
                sourceComponent: easter_eggs_component
            }
        }
        front: Item {
            anchors.fill: flipable
            visible: flipable.flipAngle !== 180

            FluNavigationView {
                id: nav_view

                property int clickCount: 0

                displayMode: GlobalModel.navigationViewType
                height: parent.height
                logo: "qrc:/resources/images/icons/logo_32x32.png"
                pageMode: FluNavigationViewType.NoStack
                title: qsTr("BLE Helper")
                topPadding: {
                    if (window.useSystemAppBar) {
                        return 0;
                    }
                    return FluTools.isMacos() ? 20 : 0;
                }
                width: parent.width
                z: 999

                footerItems: FluObject {
                    FluPaneItemSeparator {
                    }
                    FluPaneItem {
                        title: qsTr("Settings")
                        url: "qrc:/qml/pages/SettingsPage.qml"

                        iconDelegate: FluIcon {
                            iconSize: 16
                            iconSource: FluentIcons.Settings
                        }

                        onTap: {
                            nav_view.push(url);
                        }
                    }
                }
                items: FluObject {
                    FluPaneItem {
                        menuDelegate: nav_item_right_button_menu_component
                        title: qsTr("Bluetooth Client")
                        url: "qrc:/qml/pages/BluetoothClientPage.qml"

                        iconDelegate: MyFluIcon {
                            iconSize: 16
                            iconSource: MyFluIcon.Client
                        }

                        onTap: {
                            nav_view.push(url);
                        }
                    }
                    FluPaneItem {
                        menuDelegate: nav_item_right_button_menu_component
                        title: qsTr("Manage Favorites")
                        url: "qrc:/qml/pages/ManageFavoritesPage.qml"

                        iconDelegate: FluIcon {
                            iconSize: 16
                            iconSource: FluentIcons.FavoriteStar
                        }

                        onTap: {
                            nav_view.push(url);
                        }
                    }
                    FluPaneItem {
                        menuDelegate: nav_item_right_button_menu_component
                        title: qsTr("Manage UUID Dictionary")
                        url: "qrc:/qml/pages/ManageUuidDictionaryPage.qml"

                        iconDelegate: FluIcon {
                            iconSize: 16
                            iconSource: FluentIcons.Dictionary
                        }

                        onTap: {
                            nav_view.push(url);
                        }
                    }
                }

                Component.onCompleted: {
                    window.setHitTestVisible(nav_view.buttonMenu);
                    window.setHitTestVisible(nav_view.buttonBack);
                    window.setHitTestVisible(nav_view.imageLogo);
                    setCurrentIndex(0);
                }
                onLogoClicked: {
                    clickCount += 1;
                    showSuccess(qsTr("Click Time: ") + clickCount);
                    click_count_reset_timer.restart();
                    if (clickCount === 5) {
                        flipable.flipped = true;
                        clickCount = 0;
                    }
                }

                Timer {
                    id: click_count_reset_timer

                    interval: 500

                    onTriggered: {
                        nav_view.clickCount = 0;
                    }
                }
            }
        }
        states: State {
            when: flipable.flipped

            PropertyChanges {
                flipAngle: 180
                target: flipable
            }
        }
        transform: Rotation {
            id: rotation

            angle: flipable.flipAngle
            origin.x: flipable.width / 2
            origin.y: flipable.height / 2

            axis {
                x: 0
                y: 1
                z: 0
            }
        }
        transitions: Transition {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.OutCubic
                property: "flipAngle"
                target: flipable
            }
        }
    }
    Shortcut {
        context: Qt.WindowShortcut
        sequence: "F1"

        onActivated: {
            tour.open();
        }
    }
    FluTour {
        id: tour

        finishText: qsTr("Finish")
        nextText: qsTr("Next")
        previousText: qsTr("Back")
        steps: {
            var data = [];
            data.push({
                "title": qsTr("Hide Easter eggs"),
                "description": qsTr("Try a few more clicks!"),
                "target": () => nav_view.imageLogo
            });
            return data;
        }
    }
}
