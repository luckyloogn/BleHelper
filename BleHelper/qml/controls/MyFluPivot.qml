import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Templates as T

import FluentUI

FluPage {
    id: control

    property Item commandBar: null
    default property alias content: d.children
    readonly property alias currentIndex: swipe.currentIndex
    property real headerHeight: 50
    property real headerLeftPadding: 16
    property real headerRightPadding: 16
    property real headerSpacing: control.title !== "" ? 16 : 24
    property real subtitleSpacing: headerSpacing
    property color textHighlightColor: FluTheme.dark ? FluColors.Grey10 : FluColors.Black
    property color textHoverColor: FluTheme.dark ? FluColors.Grey90 : FluColors.Grey140
    property color textNormalColor: FluTheme.dark ? FluColors.Grey120 : FluColors.Grey120

    padding: 5

    background: Item {
    }
    header: Item {
        implicitHeight: control.headerHeight

        FluLoader {
            id: title_text_loader

            active: control.title !== ""

            sourceComponent: Component {
                FluText {
                    font: FluTextStyle.Title
                    text: control.title
                }
            }

            anchors {
                left: parent.left
                leftMargin: control.headerLeftPadding
                verticalCenter: parent.verticalCenter
            }
        }
        ListView {
            id: nav_list

            boundsBehavior: Flickable.StopAtBounds
            clip: true
            highlightMoveDuration: FluTheme.animationEnabled ? 167 : 0
            highlightResizeDuration: FluTheme.animationEnabled ? 167 : 0
            implicitHeight: headerItem.implicitHeight
            interactive: true
            model: d.pivotItems
            orientation: ListView.Horizontal
            spacing: control.subtitleSpacing

            delegate: FluText {
                anchors.baseline: nav_list.headerItem.baseline
                color: {
                    if (nav_list.currentIndex === index) {
                        return textHighlightColor;
                    }
                    if (item_mouse.containsMouse) {
                        return textHoverColor;
                    }
                    return textNormalColor;
                }
                font: control.title !== "" ? FluTextStyle.Subtitle : FluTextStyle.Title
                text: modelData.title

                MouseArea {
                    id: item_mouse

                    anchors.fill: parent
                    focusPolicy: Qt.TabFocus
                    hoverEnabled: true

                    onClicked: {
                        nav_list.currentIndex = index;
                    }
                }
                FluFocusRectangle {
                    radius: 4
                    visible: item_mouse.activeFocus
                }
            }
            header: FluText {
                font: FluTextStyle.Title
                // 仅用于基线参考, 故设置 text: "", visible: false, width: 0
                text: ""
                visible: true
                width: 0
            }
            highlight: Item {
                anchors.baseline: nav_list.headerItem.baseline
                clip: true

                Rectangle {
                    color: FluTheme.primaryColor
                    height: 3
                    radius: 1.5
                    width: parent.width

                    anchors {
                        baseline: parent.baseline
                        baselineOffset: 4
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            anchors {
                left: title_text_loader.right
                leftMargin: control.title !== "" ? control.headerSpacing : 0
                right: command_bar_loader.left
                rightMargin: control.commandBar ? control.headerSpacing : 0
                verticalCenter: parent.verticalCenter
            }
        }
        FluLoader {
            id: command_bar_loader

            active: control.commandBar !== null

            sourceComponent: Component {
                Item {
                    data: control.commandBar
                    implicitWidth: control.commandBar ? control.commandBar.implicitWidth : 0
                }
            }

            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: control.headerRightPadding
                top: parent.top
            }
        }
    }

    FluObject {
        id: d

        property var pivotItems: d.children.filter(function (item) {
            return item instanceof FluPivotItem;
        })
    }
    T.SwipeView {
        id: swipe

        anchors.fill: parent
        clip: true
        currentIndex: nav_list.currentIndex
        implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)
        implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
        interactive: false
        orientation: Qt.Horizontal

        contentItem: ListView {
            boundsBehavior: Flickable.StopAtBounds
            currentIndex: swipe.currentIndex
            focus: swipe.focus
            highlightMoveDuration: FluTheme.animationEnabled ? 167 : 0
            highlightRangeMode: ListView.StrictlyEnforceRange
            interactive: swipe.interactive
            maximumFlickVelocity: 4 * (swipe.orientation === Qt.Horizontal ? width : height)
            model: swipe.contentModel
            orientation: swipe.orientation
            preferredHighlightBegin: 0
            preferredHighlightEnd: 0
            snapMode: ListView.SnapOneItem
            spacing: swipe.spacing
        }

        Repeater {
            model: d.pivotItems

            FluLoader {
                property var argument: modelData.argument

                active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                sourceComponent: modelData.contentItem
            }
        }
    }
}
