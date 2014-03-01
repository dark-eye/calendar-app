import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

PathViewBase {
    id: root
    objectName: "YearView"

    property int currentYear: DateExt.today().getFullYear();

    signal monthSelected(var date);

    anchors.fill: parent

    onNextItemHighlighted: {
        currentYear = currentYear + 1;
    }

    onPreviousItemHighlighted: {
        currentYear = currentYear - 1;
    }

    delegate: GridView{
        id: yearView
        clip: true

        property bool isCurrentItem: index == root.currentIndex
        property var year: getYear();
        //property int intYear: year.getFullYear();

        function getYear() {
            switch( root.indexType(index)) {
            case 0:
                return currentYear
            case -1:
                return currentYear - 1;
            case 1:
                return currentYear + 1;
            }
        }

        width: parent.width
        height: parent.height
        anchors.top: parent.top

        readonly property int minCellWidth: units.gu(30)
        cellWidth: Math.floor(Math.min.apply(Math, [3, 4].map(function(n)
            { return ((width / n >= minCellWidth) ? width / n : width / 2) })))

        cellHeight: cellWidth * 1.4

        model: 12 /* months in a year */
        delegate: Item {
            width: yearView.cellWidth
            height: yearView.cellHeight

            MonthComponent{
                id: monthComponent
                currentMonth: new Date(yearView.year,index,1,0,0,0,0)

                anchors.fill: parent
                anchors.margins: units.gu(0.5)

                dayLabelFontSize:"x-small"
                dateLabelFontSize: "medium"
                monthLabelFontSize: "medium"
                yearLabelFontSize: "small"

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        root.monthSelected(monthComponent.currentMonth);
                    }
                }
            }
        }
    }
}
