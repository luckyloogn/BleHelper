import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import FluentUI

Popup {
    id: control

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    dim: false
    height: Math.min(implicitHeight, d.parentHeight)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    margins: 0
    modal: false
    padding: 0
    parent: Overlay.overlay
    spacing: 0
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)

    Overlay.modal: Rectangle {
        color: FluTools.withOpacity(control.palette.shadow, 0.5)
    }
    Overlay.modeless: Rectangle {
        color: FluTools.withOpacity(control.palette.shadow, 0.12)
    }
    background: Rectangle {
        border.color: FluTheme.dark ? Qt.rgba(26 / 255, 26 / 255, 26 / 255, 1) : Qt.rgba(191 / 255, 191 / 255, 191 / 255, 1)
        border.width: 1
        color: FluTheme.dark ? Qt.rgba(45 / 255, 45 / 255, 45 / 255, 1) : Qt.rgba(252 / 255, 252 / 255, 252 / 255, 1)
        implicitHeight: 36
        implicitWidth: 150
        radius: 5

        FluShadow {
        }
    }
    enter: Transition {
        NumberAnimation {
            duration: FluTheme.animationEnabled && control.animationEnabled ? 167 : 0
            from: 0
            property: "opacity"
            to: 1
        }
    }
    exit: Transition {
        NumberAnimation {
            duration: FluTheme.animationEnabled && control.animationEnabled ? 167 : 0
            from: 1
            property: "opacity"
            to: 0
        }
    }
}
