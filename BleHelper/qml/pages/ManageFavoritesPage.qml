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

    header: Item {
        implicitHeight: 50

        FluText {
            font: FluTextStyle.Title
            text: qsTr("Manage Favorites")

            anchors {
                left: parent.left
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
        }
        FluIconButton {
            id: more_options_button

            iconSize: 16
            iconSource: FluentIcons.More
            text: qsTr("More Options")

            onClicked: {
                more_options_menu.open();
            }

            anchors {
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
        }
    }

    FluMenu {
        id: more_options_menu

        parent: more_options_button
        x: parent.width - width
        y: parent.height

        FluMenuItem {
            text: qsTr("Unfavorite All")

            onClicked: {
                alarm_aialog.open();
            }
        }
    }
    FluContentDialog {
        id: alarm_aialog

        buttonFlags: FluContentDialogType.NegativeButton | FluContentDialogType.PositiveButton
        message: qsTr("Are you sure to remove all devices from the favorites?")
        negativeText: qsTr("Cancel")
        positiveText: qsTr("OK")
        title: qsTr("Tip")

        onPositiveClicked: {
            ClientManager.deleteAllDevicesFromFavorites();
        }
    }
    FluText {
        font: FluTextStyle.Title
        text: qsTr("No favorite devices found")
        visible: ClientManager.favoriteDevices.length === 0

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }
    ListView {
        clip: true
        focus: true
        model: ClientManager.favoriteDevices
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
                        text: modelData.address
                    }
                }
                MyFluIconButton {
                    iconSize: 16
                    iconSource: MyFluIcon.Unfavorite
                    text: qsTr("Unfavorite")

                    onClicked: {
                        ClientManager.deleteDeviceFromFavorites(modelData.address);
                    }

                    anchors {
                        right: parent.right
                        rightMargin: -horizontalPadding
                        verticalCenter: parent.verticalCenter
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
