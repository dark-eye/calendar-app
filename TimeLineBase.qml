import QtQuick 2.0
import Ubuntu.Components 0.1
import "dateExt.js" as DateExt

Item {
    id: bubbleOverLay

    property var delegate;
    property var day;
    property int hourHeight: units.gu(12)

    property var model;
            
    MouseArea {
        anchors.fill: parent
        objectName: "mouseArea"
        onPressAndHold: {
            var selectedDate = new Date(day);
            var hour = parseInt(mouseY / hourHeight);
            selectedDate.setHours(hour)
            pageStack.push(Qt.resolvedUrl("NewEvent.qml"), {"date":selectedDate, "model":eventModel});
        }
    }

    TimeSeparator {
        id: separator
        objectName: "separator"
        width:  bubbleOverLay.width
        visible: false
        z:1
    }

    QtObject {
        id: intern
        property var now : new Date();
    }

    function showEventDetails(event) {
        pageStack.push(Qt.resolvedUrl("EventDetails.qml"), {"event":event,"model":model});
    }

    function createEvents() {
        if(!bubbleOverLay || bubbleOverLay == undefined) {
            return;
        }
        destroyAllChildren();

        var startDate = new Date(day).midnight();
        var endDate = new Date(day).endOfDay();

        var items = model.getItems(startDate,endDate);
        for(var i = 0; i < items.length; ++i) {
            var event = items[i];
            if(event.allDay === false) {
                bubbleOverLay.createEvent(event, event.startDateTime.getHours());
            }
        }

        if( intern.now.isSameDay( bubbleOverLay.day ) ) {
            bubbleOverLay.showSeparator(intern.now.getHours());
        }
    }

    function destroyAllChildren() {
        for( var i = children.length - 1; i >= 0; --i ) {
 	    if( children[i].objectName === "mouseArea" ) {
                continue;
            }
            children[i].visible = false;
            if( children[i].objectName !== "separator") {
                children[i].destroy();
            }
        }
    }

    function createEvent(event, hour) {
        var eventBubble = delegate.createObject(bubbleOverLay);

        eventBubble.clicked.connect( bubbleOverLay.showEventDetails );

        var yPos = (( event.startDateTime.getMinutes() * hourHeight) / 60) + hour * hourHeight
        eventBubble.y = yPos;

        var durationMin = (event.endDateTime.getHours() - event.startDateTime.getHours()) * 60;
        durationMin += (event.endDateTime.getMinutes() - event.startDateTime.getMinutes());
        var height = (durationMin * hourHeight )/ 60;
        eventBubble.height = (height > eventBubble.minimumHeight) ? height:eventBubble.minimumHeight ;

        eventBubble.event = event
    }

    function showSeparator(hour) {
        var y = ((intern.now.getMinutes() * hourHeight) / 60) + hour * hourHeight;
        separator.y = y;
        separator.visible = true;
    }
}
