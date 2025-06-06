import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: delegate

    width: parent.width
    contentHeight: Theme.itemSizeExtraLarge * 2

    property real monthlyPayment: calculateMonthlyPayment()
    property real progressRatio: targetAmount > 0 ? Math.min(currentAmount / targetAmount, 1) : 0
    property string daysLeft: calculateDaysLeft()

    Rectangle {
        anchors {
            fill: parent
            margins: Theme.paddingSmall
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
        radius: Theme.paddingMedium
        color: "#24224f"
        border.color: Theme.rgba(Theme.highlightColor, 0.3)
        border.width: 1

        Column {
            width: parent.width - 2 * Theme.paddingMedium
            anchors.centerIn: parent
            spacing: Theme.paddingMedium

            Row {
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    width: parent.width - dateLabel.width - parent.spacing
                    text: qsTr(title)
                    font {
                        pixelSize: Theme.fontSizeMedium
                        bold: true
                        strikeout: isCompleted === 1
                    }
                    color: isCompleted === 1 ? Theme.secondaryColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                    maximumLineCount: 1
                }

                Label {
                    id: dateLabel
                    text: Qt.formatDate(new Date(endDate), "dd.MM.yyyy")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }
            }

            Item {
                width: parent.width
                height: Theme.paddingMedium

                Rectangle {
                    width: parent.width
                    height: parent.height
                    radius: height / 2
                    color: Theme.rgba(Theme.highlightColor, 0.1)

                    Rectangle {
                        width: parent.width * progressRatio
                        height: parent.height
                        radius: height / 2
                        color: progressRatio >= 1 ? Theme.highlightColor : Theme.secondaryHighlightColor
                        Behavior on width {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Label {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    text: (progressRatio * 100).toFixed(0) + "%"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.primaryColor
                }
            }

            Grid {
                width: parent.width
                columns: 2
                columnSpacing: Theme.paddingSmall
                rowSpacing: Theme.paddingSmall

                Label {
                    text: qsTr("Цель:")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }

                Label {
                    text: targetAmount.toFixed(2) + " ₽"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignRight
                    width: parent.width / 2 - Theme.paddingSmall
                }

                Label {
                    text: qsTr("Накоплено:")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }

                Label {
                    text: currentAmount.toFixed(2) + " ₽"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignRight
                }

                Label {
                    text: qsTr("Осталось:")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }

                Label {
                    text: isCompleted === 0 ? (targetAmount - currentAmount).toFixed(2) + " ₽" : "-"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignRight
                }

                Label {
                    text: qsTr("Ежемесячно:")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }

                Label {
                    text: isCompleted === 0 ? monthlyPayment + " ₽" : "-"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: monthlyPayment > 0 ? Theme.primaryColor : (isCompleted === 1 ? Theme.primaryColor : Theme.errorColor)
                    horizontalAlignment: Text.AlignRight
                }

                Label {
                    text: qsTr("Дней:")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                }

                Label {
                    text: isCompleted === 0 ? daysLeft : "-"
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: daysLeft === qsTr("Срок истёк") ? Theme.errorColor : Theme.primaryColor
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../pages/EditGoalPage.qml"), {
            goal: model,
            goalModel: goalModel
        });
    }

    function calculateMonthlyPayment() {
        const remaining = targetAmount - currentAmount;
        const monthsLeft = Math.max(Math.ceil((new Date(endDate) - new Date()) / (1000 * 60 * 60 * 24 * 30)), 0);
        return monthsLeft > 0 ? (remaining / monthsLeft).toFixed(2) : 0;
    }

    function calculateDaysLeft() {
        const days = Math.ceil((new Date(endDate) - new Date()) / (1000 * 60 * 60 * 24));
        return days > 0 ? days + " " + (days === 1 ? qsTr("день") : days < 5 ? qsTr("дня") : qsTr("дней")) : qsTr("Срок истёк");
    }
}
