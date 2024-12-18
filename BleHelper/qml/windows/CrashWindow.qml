import Qt.labs.platform
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import BleHelper
import FluentUI

FluWindow {
    id: window

    fixSize: true
    height: 400
    showMinimize: false
    title: qsTr("BLE Helper")
    width: 300

    Component.onCompleted: {
        window.stayTop = true;
    }

    FluImage {
        height: 240
        source: "qrc:/resources/images/ic_crash.png"
        sourceSize: Qt.size(480, 480)
        width: 240

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }
    }
    FluText {
        elide: Text.ElideNone
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Sorry for the trouble! The application ran into a problem and needs to restart.")
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap

        anchors {
            left: parent.left
            leftMargin: 24
            right: parent.right
            rightMargin: 24
            top: parent.top
            topMargin: 232
        }
    }
    ColumnLayout {
        spacing: 12

        anchors {
            bottom: parent.bottom
            bottomMargin: 24
            left: parent.left
            leftMargin: 24
            right: parent.right
            rightMargin: 24
        }
        FluFilledButton {
            Layout.fillWidth: true
            text: qsTr("Restart")

            onClicked: {
                FluRouter.exit(931);
            }
        }
        FluButton {
            Layout.fillWidth: true
            text: qsTr("Close")

            onClicked: {
                FluRouter.exit();
            }
        }
    }
}
