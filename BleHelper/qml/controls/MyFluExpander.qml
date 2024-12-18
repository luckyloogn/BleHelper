import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import FluentUI

Item {
    id: control

    default property alias content: container.data
    property int contentHeight: 300
    property color disableColor: FluTheme.dark ? Qt.rgba(59 / 255, 59 / 255, 59 / 255, 1) : Qt.rgba(251 / 255, 251 / 255, 251 / 255, 1)
    property bool disabled: false
    property color dividerColor: FluTheme.dark ? Qt.rgba(80 / 255, 80 / 255, 80 / 255, 1) : Qt.rgba(233 / 255, 233 / 255, 233 / 255, 1)
    property bool expand: false
    property var headerDelegate: com_header
    property int headerHeight: 70
    property int headerLeftPadding: 16
    property int headerRightPadding: 16
    property string headerText: ""
    property color hoverColor: FluTheme.dark ? Qt.rgba(50 / 255, 50 / 255, 50 / 255, 1) : Qt.rgba(246 / 255, 246 / 255, 246 / 255, 1)
    property color normalColor: Window.active ? FluTheme.frameActiveColor : FluTheme.frameColor
    property int radius: 4
    property color textColor: {
        if (FluTheme.dark) {
            if (!control.enabled) {
                return Qt.rgba(131 / 255, 131 / 255, 131 / 255, 1);
            }
            if (control_mouse.pressed) {
                return Qt.rgba(162 / 255, 162 / 255, 162 / 255, 1);
            }
            return Qt.rgba(1, 1, 1, 1);
        } else {
            if (!control.enabled) {
                return Qt.rgba(160 / 255, 160 / 255, 160 / 255, 1);
            }
            if (control_mouse.pressed) {
                return Qt.rgba(96 / 255, 96 / 255, 96 / 255, 1);
            }
            return Qt.rgba(0, 0, 0, 1);
        }
    }

    clip: true
    enabled: !disabled
    implicitHeight: Math.max((layout_header.height + layout_container.height), layout_header.height)
    implicitWidth: 400

    QtObject {
        id: d

        property bool flag: false

        function toggle() {
            d.flag = true;
            expand = !expand;
            d.flag = false;
        }
    }
    Component {
        id: com_header

        Item {
            FluText {
                anchors.verticalCenter: parent.verticalCenter
                color: control.textColor
                text: control.headerText
            }
        }
    }
    Rectangle {
        id: layout_header

        border.color: FluTheme.dividerColor
        color: control.normalColor
        height: control.headerHeight
        radius: control.radius
        width: parent.width

        ColorAnimation on color {
            id: color_animation

            duration: FluTheme.animationEnabled ? 167 : 0
            easing.type: Easing.OutCubic
            from: layout_header.color
            running: false
            to: control_mouse.containsMouse ? control.normalColor : control.hoverColor
        }

        MouseArea {
            id: control_mouse

            anchors.fill: parent
            enabled: control.enabled
            hoverEnabled: true

            onClicked: {
                d.toggle();
            }
            onContainsMouseChanged: {
                if (Window.active) {
                    color_animation.restart();
                }
            }
        }
        RowLayout {
            spacing: 0

            anchors {
                fill: parent
                leftMargin: control.headerLeftPadding
                rightMargin: control.headerRightPadding
            }
            FluLoader {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceComponent: control.headerDelegate
            }
            FluIcon {
                id: icon

                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                iconSize: 12
                iconSource: FluentIcons.ChevronUp
                rotation: control.expand ? 0 : 180

                Behavior on rotation {
                    enabled: FluTheme.animationEnabled

                    NumberAnimation {
                        duration: 167
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
    Item {
        id: layout_container

        clip: true
        height: contentHeight + container.anchors.topMargin
        visible: contentHeight + container.anchors.topMargin !== 0
        width: parent.width
        z: -999

        anchors {
            left: layout_header.left
            top: layout_header.bottom
            topMargin: -1
        }
        Rectangle {
            id: container

            anchors.fill: parent
            anchors.topMargin: -contentHeight
            border.color: FluTheme.dividerColor
            clip: true
            color: {
                if (Window.active) {
                    return FluTheme.frameActiveColor;
                }
                return FluTheme.frameColor;
            }
            radius: control.radius

            states: [
                State {
                    name: "expand"
                    when: control.expand

                    PropertyChanges {
                        anchors.topMargin: 0
                        target: container
                    }
                },
                State {
                    name: "collapsed"
                    when: !control.expand

                    PropertyChanges {
                        anchors.topMargin: -contentHeight
                        target: container
                    }
                }
            ]
            transitions: [
                Transition {
                    to: "expand"

                    NumberAnimation {
                        duration: FluTheme.animationEnabled && d.flag ? 167 : 0
                        easing.type: Easing.OutCubic
                        properties: "anchors.topMargin"
                    }
                },
                Transition {
                    to: "collapsed"

                    NumberAnimation {
                        duration: FluTheme.animationEnabled && d.flag ? 167 : 0
                        easing.type: Easing.OutCubic
                        properties: "anchors.topMargin"
                    }
                }
            ]
        }
    }
}
