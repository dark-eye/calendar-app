import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
import QtOrganizer 5.0

Page {
    id: root
    title: i18n.tr("Calendars")

    property bool isInEditMode: false
    property var model;

    Component.onCompleted: {
        pageStack.header.visible = true;
    }

    ToolbarItems {
        id: pickerModeToolbar
        //keeping toolbar always open
        opened: true
        locked: true
        visible: !isInEditMode

        back: ToolbarButton {
            action: Action {
                text: i18n.tr("Back");
                iconName: "back"
                onTriggered: {
                    pageStack.pop();
                }
            }
        }

        ToolbarButton {
            action: Action {
                text: i18n.tr("Edit");
                iconName: "edit"
                onTriggered: {
                    root.isInEditMode = true
                }
            }
        }

        ToolbarButton {
            action: Action {
                text: i18n.tr("Save");
                iconSource: Qt.resolvedUrl("save.svg");
                onTriggered: {
                    var collections = calendarsList.model;
                    for(var i=0; i < collections.length ; ++i) {
                        var collection = collections[i]
                        root.model.saveCollection(collection);
                    }
                    pageStack.pop();
                }
            }
        }
    }

    ToolbarItems {
        id: editModeToolbar
        //keeping toolbar always open
        opened: true
        locked: true
        visible: isInEditMode

        back: ToolbarButton {
            action: Action {
                text: i18n.tr("Back");
                iconName: "back"
                onTriggered: {
                    root.isInEditMode = false
                }
            }
        }
    }

    tools: isInEditMode ? editModeToolbar : pickerModeToolbar

    ListView {
        id: calendarsList

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            topMargin: units.gu(2)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        model : root.model.getCollections();
        delegate: delegateComp

        Component{
            id: delegateComp
            Empty{
                Row{
                    width: parent.width
                    height:checkBox.height + units.gu(2)
                    spacing: units.gu(1)

                    UbuntuShape{
                        width: parent.height
                        height: parent.height - units.gu(2)
                        color: modelData.color
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label{
                        text: modelData.name
                        fontSize: "medium"
                        width: parent.width - (parent.height*2)
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if(isInEditMode){
                                    //popup dialog
                                    var dialog = PopupUtils.open(Qt.resolvedUrl("ColorPickerDialog.qml"),root);
                                    dialog.accepted.connect(function(color) {
                                        var collection = root.model.collection(modelData.collectionId);
                                        collection.color = color;
                                        root.model.saveCollection(collection);
                                    })
                                } else {
                                    checkBox.checked = !checkBox.checked
                                    modelData.setExtendedMetaData("collection-selected",checkBox.checked)
                                    //var collection = root.model.collection(modelData.collectionId);
                                    //root.model.saveCollection(collection);
                                }
                            }
                        }
                    }
                    CheckBox {
                        id: checkBox
                        checked: modelData.extendedMetaData("collection-selected")
                        anchors.verticalCenter: parent.verticalCenter
                        visible:  !root.isInEditMode
                        onCheckedChanged: {
                            modelData.setExtendedMetaData("collection-selected",checkBox.checked)
                            //var collection = root.model.collection(modelData.collectionId);
                            //root.model.saveCollection(collection);
                        }
                    }
                }
            }
        }
    }
}
