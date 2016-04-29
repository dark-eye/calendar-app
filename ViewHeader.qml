/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.4
import Ubuntu.Components 1.3
import "./3rd-party/lunar.js" as Lunar

Item{
    id: header
    width: parent.width
    height: leftLabel.height

    property int month;
    property int year;
    property int daysInMonth;

    property string leftLabelFontSize: "large"
    property string rightLabelFontSize: "large"

    property string leftLabelDateStr: "MMMM"
    property string rightLabelDateStr: "yyyy"

    Label{
        id: leftLabel
        objectName: "leftLabel"
        fontSize: leftLabelFontSize
        anchors.leftMargin: units.gu(1)
        anchors.left: parent.left
        color:"black"
        anchors.verticalCenter: parent.verticalCenter
    }

    Label{
        id: rightLabel
        objectName: "rightLabel"
        fontSize: rightLabelFontSize
        anchors.right: parent.right
        anchors.rightMargin: units.gu(1)
        color:"black"
        anchors.verticalCenter: parent.verticalCenter
    }

    Component.onCompleted:  {
        var dateShortFormat = Qt.locale().dateFormat(Locale.ShortFormat)
        var yearIndexFormat = dateShortFormat.indexOf("y")
        var monthIndexFormat = dateShortFormat.indexOf("M")

        if (yearIndexFormat >= 0 && monthIndexFormat >= 0 && yearIndexFormat < monthIndexFormat) {
            leftLabelDateStr = "yyyy";
            rightLabelDateStr = "MMMM";
        }

        leftLabel.text = Qt.binding(function(){
            var labelDate = new Date(year, month)

            if (mainView.displayLunarCalendar) {
                var lunarDate = Lunar.calendar.solar2lunar(year, month + 1, daysInMonth)
                return lunarDate.IMonthCn
            } else {
                return labelDate.toLocaleString(Qt.locale(), leftLabelDateStr)
            }
        })

        rightLabel.text = Qt.binding(function(){
            var labelDate = new Date(year, month)

            if (mainView.displayLunarCalendar) {
                var lunarDate = Lunar.calendar.solar2lunar(year, month + 1, daysInMonth)
                return lunarDate.gzYear
            } else {
                return labelDate.toLocaleString(Qt.locale(), rightLabelDateStr)
            }
        })
    }
}
