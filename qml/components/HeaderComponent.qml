import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: headerRoot

    width: parent.width
    height: parent.height / 7
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: "#24224f"
        }
        GradientStop {
            position: 1.0
            color: "#1a1a3a"
        }
    }

    property string headerText: ""
    property int fontSize: Theme.fontSizeExtraLarge * 2
    property bool showIcon: true
    property string selectedTab: "expenses"
    property var operationModel: null

    Row {
        id: balanceRow1
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: Theme.paddingMedium
        }
        spacing: Theme.paddingMedium

        Image {
            source: "../icons/WebBudget.svg"
            height: Theme.iconSizeLarge
            width: Theme.iconSizeLarge
            visible: headerRoot.showIcon
        }

        Label {
            text: qsTr(headerRoot.headerText)
            color: Theme.highlightColor
            font.pixelSize: headerRoot.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        id: balanceRow2
        anchors {
            top: balanceRow1.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: Theme.paddingLarge
        }
        spacing: Theme.paddingLarge * 8

        Label {
            text: qsTr("Расходы")
            color: headerRoot.selectedTab === "expenses" ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge * 1.45
            font.bold: headerRoot.selectedTab === "expenses"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    headerRoot.selectedTab = "expenses";
                    action = 0;
                }
            }
        }

        Label {
            text: qsTr("Доходы")
            color: headerRoot.selectedTab === "revenue" ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge * 1.45
            font.bold: headerRoot.selectedTab === "revenue"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    headerRoot.selectedTab = "revenue";
                    action = 1;
                }
            }
        }
    }
}
