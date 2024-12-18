import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

import FluentUI

ProgressBar {
    id: control

    property color backgroundColor: FluTheme.dark ? Qt.rgba(99 / 255, 99 / 255, 99 / 255, 1) : Qt.rgba(214 / 255, 214 / 255, 214 / 255, 1)
    property color color: FluTheme.primaryColor
    property int duration: 888
    property bool progressVisible: false
    property real strokeWidth: 6

    indeterminate: true

    background: Rectangle {
        color: control.backgroundColor
        implicitHeight: control.strokeWidth
        implicitWidth: 150
        radius: d._radius
    }
    contentItem: FluClip {
        clip: true
        radius: [d._radius, d._radius, d._radius, d._radius]

        Rectangle {
            id: rect_progress

            color: control.color
            height: parent.height
            radius: d._radius
            width: {
                if (control.indeterminate) {
                    return 0.5 * parent.width;
                }
                return control.visualPosition * parent.width;
            }

            SequentialAnimation on x {
                id: animator_x

                loops: Animation.Infinite
                running: control.indeterminate && control.visible

                PropertyAnimation {
                    duration: control.duration
                    from: -rect_progress.width
                    to: control.width + rect_progress.width
                }
            }
        }
    }

    onIndeterminateChanged: {
        if (!indeterminate) {
            animator_x.duration = 0;
            rect_progress.x = 0;
            animator_x.duration = control.duration;
        }
    }

    QtObject {
        id: d

        property real _radius: strokeWidth / 2
    }
    FluText {
        text: (control.visualPosition * 100).toFixed(0) + "%"
        visible: {
            if (control.indeterminate) {
                return false;
            }
            return control.progressVisible;
        }

        anchors {
            left: parent.left
            leftMargin: control.width + 5
            verticalCenter: parent.verticalCenter
        }
    }
}
