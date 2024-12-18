import QtQuick
import QtQuick.Controls

import FluentUI

Text {
    id: control

    enum Icon {
        Scan = 65,
        Details,
        Filter,
        DescendingSort,
        AscendingSort,
        Pair,
        Unpair,
        DeviceName,
        DeviceAddress,
        DeviceRssi,
        State,
        Client,
        Server,
        Read,
        Write,
        Notify,
        Indicate,
        Favorite,
        Unfavorite
    }

    property color iconColor: {
        if (FluTheme.dark) {
            if (!enabled) {
                return Qt.rgba(130 / 255, 130 / 255, 130 / 255, 1);
            }
            return Qt.rgba(1, 1, 1, 1);
        } else {
            if (!enabled) {
                return Qt.rgba(161 / 255, 161 / 255, 161 / 255, 1);
            }
            return Qt.rgba(0, 0, 0, 1);
        }
    }
    property int iconSize: 24
    property int iconSource

    color: iconColor
    font.family: font_loader.name
    font.pixelSize: iconSize
    horizontalAlignment: Text.AlignHCenter
    opacity: iconSource > 0
    text: (String.fromCharCode(iconSource).toString(16))
    verticalAlignment: Text.AlignVCenter

    FontLoader {
        id: font_loader

        source: "qrc:/resources/fonts/BleHelperIcons.ttf"
    }
}
