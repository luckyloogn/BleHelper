import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import BleHelper
import FluentUI

import "../controls"

FluWindow {
    id: window

    autoDestroy: true
    height: 600
    launchMode: FluWindowType.SingleInstance
    minimumHeight: 576
    minimumWidth: 768
    showStayTop: true
    width: 800

    onInitArgument: arg => {
        window.title = arg.title;
        loader.setSource(arg.url, {
            "animationEnabled": false
        });
    }

    FluLoader {
        id: loader

        anchors.fill: parent
    }
}
