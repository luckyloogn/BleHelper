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
            text: qsTr("Scanner")

            anchors {
                left: parent.left
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
        }
    }

    FluText {
        font: FluTextStyle.Title
        text: qsTr("Scanner")

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }
}
