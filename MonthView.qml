import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

Page {
    id: monthViewPage

    property var currentMonth: DateExt.today();

    signal dateSelected(var date);

    PathViewBase{
        id: monthViewPath

        property var startMonth: currentMonth;

        anchors.top:parent.top

        width:parent.width
        height: parent.height

        onNextItemHighlighted: {
            nextMonth();
        }

        onPreviousItemHighlighted: {
            previousMonth();
        }

        function nextMonth() {
            currentMonth = addMonth(currentMonth,1);
        }

        function previousMonth(){
            currentMonth = addMonth(currentMonth,-1);
        }

        function addMonth(date,month){
            var temp = new Date(date.getFullYear(),date.getMonth(),1,0,0,0);
            temp.setMonth(date.getMonth() + month);
            return temp;
        }

        delegate: MonthComponent{
            width: parent.width - units.gu(5)
            height: parent.height - units.gu(5)

            monthDate: getMonthDate();

            function getMonthDate() {
                switch( monthViewPath.indexType(index)) {
                case 0:
                    return monthViewPath.startMonth;
                case -1:
                    return monthViewPath.addMonth(monthViewPath.startMonth,-1);
                case 1:
                    return monthViewPath.addMonth(monthViewPath.startMonth,1);
                }
            }

            onDateSelected: {
                monthViewPage.dateSelected(date);
            }
        }
    }
}
