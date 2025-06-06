import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models

Item {

    width: parent.width
    height: Theme.itemSizeMedium

    property var categoryData: null
    property var categoryModel
    property int action

    Models.CategoryModel {
        id: categoryModel
    }

    Rectangle {
        width: parent.width - 2 * Theme.horizontalPageMargin
        height: parent.height
        radius: Theme.paddingSmall
        color: Theme.rgba(Theme.highlightColor, 0.1)
        anchors.centerIn: parent

        Row {
            anchors.fill: parent
            anchors.leftMargin: Theme.paddingMedium
            spacing: Theme.paddingMedium

            Image {
                source: categoryData ? categoryData.pathToIcon : ""
                width: Theme.iconSizeMedium
                height: width
                anchors.verticalCenter: parent.verticalCenter
                sourceSize: Qt.size(width, height)
            }

            Label {
                text: qsTr(categoryData ? categoryData.nameCategory : "Нажми, чтобы выбрать категорию")
                color: Theme.primaryColor
                width: parent.width - Theme.iconSizeMedium - Theme.paddingMedium * 2
                anchors.verticalCenter: parent.verticalCenter
                truncationMode: TruncationMode.Fade
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: pageStack.push(Qt.resolvedUrl("../pages/CategoryPage.qml"), {
                categoryModel: categoryModel,
                action: root.selectedAction
            })
        }
    }
}
