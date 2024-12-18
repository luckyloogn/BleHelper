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
    property real headerSpacing: 16
    property real subtitleSpacing: control.title !== "" ? headerSpacing / 2 : headerSpacing
    property color textHighlightColor: FluTheme.dark ? FluColors.Grey10 : FluColors.Black
    property color textHoverColor: FluTheme.dark ? FluColors.Grey90 : FluColors.Grey140
    property color textNormalColor: FluTheme.dark ? FluColors.Grey120 : FluColors.Grey120

    function nextPage() {
        if (swipe.currentIndex + 1 < d.pages.length) {
            swipe.currentIndex++;
        }
    }
    function previousPage() {
        if (swipe.currentIndex - 1 >= 0) {
            swipe.currentIndex--;
        }
    }
    function setCurrentIndex(index) {
        if (index >= 0 && index < d.pages.length) {
            swipe.currentIndex = index;
        }
    }

    padding: 5

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
            currentIndex: swipe.currentIndex
            implicitHeight: headerItem.implicitHeight
            interactive: true
            model: d.pages
            orientation: ListView.Horizontal
            spacing: control.subtitleSpacing

            delegate: Row {
                anchors.baseline: nav_list.headerItem.baseline
                spacing: nav_list.spacing

                FluText {
                    id: subtitle_text

                    anchors.baseline: parent.baseline
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
                    visible: index <= nav_list.currentIndex

                    MouseArea {
                        id: item_mouse

                        anchors.fill: parent
                        focusPolicy: Qt.TabFocus
                        hoverEnabled: true

                        onClicked: {
                            swipe.currentIndex = index;
                        }
                    }
                    FluFocusRectangle {
                        radius: 4
                        visible: item_mouse.activeFocus
                    }
                }
                FluIcon {
                    anchors.baseline: parent.baseline
                    color: {
                        if (swipe.currentIndex === index) {
                            return textHighlightColor;
                        }
                        return textNormalColor;
                    }
                    iconSize: 12
                    iconSource: FluentIcons.ChevronRightMed
                    visible: index <= swipe.currentIndex - 1
                }
            }
            header: FluText {
                font: FluTextStyle.Title
                // 仅用于基线参考, 故设置 text: "", visible: false, width: 0
                text: ""
                visible: true
                width: 0
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

        property var pages: d.children.filter(function (item) {
            return item instanceof Page;
        })
    }
    SwipeView {
        id: swipe

        anchors.fill: parent
        clip: true
        interactive: false
        orientation: Qt.Horizontal

        Component.onCompleted: {
            // reference: https://programmersought.com/article/53604958500/
            contentItem.highlightMoveDuration = FluTheme.animationEnabled ? 167 : 0;
            for (var i = 0; i < d.pages.length; i++) {
                var item = d.pages[i];
                item.header = null;
                swipe.addItem(item);
            }
        }
    }
}
