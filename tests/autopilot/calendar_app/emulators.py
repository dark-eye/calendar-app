# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Calendar app autopilot emulators."""
from time import sleep

from autopilot.introspection import dbus

from ubuntuuitoolkit import emulators as toolkit_emulators


class MainView(toolkit_emulators.MainView):

    """
    An emulator class that makes it easy to interact with the calendar-app.
    """

    def get_event_view(self):
        return self.wait_select_single("EventView")

    def get_month_view(self):
        return self.wait_select_single("MonthView")

    def get_year_view(self):
        return self.wait_select_single("YearView")

    def get_day_view(self):
        return self.wait_select_single("DayView")

    def get_week_view(self):
        return self.wait_select_single("WeekView")

    def get_label_with_text(self, text, root=None):
        if root is None:
            root = self
        labels = root.select_many("Label", text=text)
        if (len(labels) > 0):
            return labels[0]
        else:
            return None

    def get_new_event(self):
        try:
            return self.wait_select_single("NewEvent")
        except dbus.StateNotFoundError:
            return None

    def get_new_event_name_input_box(self):
        new_event = self.get_new_event()
        return new_event.wait_select_single("NewEventEntryField",
                                            objectName="newEventName")

    def get_event_start_time_field(self):
        new_event = self.get_new_event()
        return new_event.wait_select_single("NewEventEntryField",
                                            objectName="startTimeInput")

    def get_event_end_time_field(self):
        new_event = self.get_new_event()
        return new_event.wait_select_single("NewEventEntryField",
                                            objectName="endTimeInput")

    def get_event_location_field(self):
        new_event = self.get_new_event()
        return new_event.wait_select_single("NewEventEntryField",
                                            objectName="eventLocationInput")

    def get_event_people_field(self):
        new_event = self.get_new_event()
        return new_event.wait_select_single("NewEventEntryField",
                                            objectName="eventPeopleInput")

    def get_time_picker(self):
        try:
            return self.wait_select_single("TimePicker")
        except dbus.StateNotFoundError:
            return None

    def swipe_view(self, sign, view, date):
        timeout = 0
        before = date
        while timeout < 10 and date == before:
            self._swipe(sign, view)
            #check for up to 3 seconds after swipe for view
            #to have changed before trying again
            for x in range(0, 3):
                if date != before:
                    break
                sleep(1)
            timeout += 1

    def _swipe(self, direction, view, x_pad=0.15):
        """Swipe the given view to left or right.

        Args:
            direction: if 1 it swipes from right to left, if -1 from
                left right.

        """

        start = (-direction * x_pad) % 1
        stop = (direction * x_pad) % 1

        y_line = view.globalRect[1] + view.globalRect[3] / 2
        x_start = view.globalRect[0] + view.globalRect[2] * start
        x_stop = view.globalRect[0] + view.globalRect[2] * stop

        self.pointing_device.drag(x_start, y_line, x_stop, y_line)

    def get_year(self, component):
        return int(component.wait_select_single(
            "Label", objectName="yearLabel").text)

    def get_month_name(self, component):
        return component.wait_select_single(
            "Label", objectName="monthLabel").text

    def get_num_events(self):
        return len(self.select_many("EventBubble"))

    def get_new_event_save_button(self):
        new_event = self.get_new_event()
        return new_event.wait_select_single("Button",
                                            objectName="accept")

    def get_new_event_cancel_button(self):
        new_event = self.get_new_event()
        return new_event.wait_select_single("Button",
                                            objectName="cancel")


class Page(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    """Autopilot helper for Pages."""

    def __init__(self, *args):
        super(Page, self).__init__(*args)
        # XXX we need a better way to keep reference to the main view.
        # --elopio - 2014-01-31
        self.main_view = self.get_root_instance().select_single(MainView)

    def drag_page_up(self):
        """Drag the given page up."""
        self._drag_page(direction='up')

    def drag_page_down(self):
        """Drag the given page down."""
        self._drag_page(direction='down')

    def _drag_page(self, direction):
        """Function to drag the page up/down."""
        self._wait_to_stop_moving()

        x, y, w, h = self.globalRect
        start_x = stop_x = x + (w / 2)
        start_y = y + (h / 2)

        if direction == "down":
            stop_y = start_y + h / 3
            self.pointing_device.drag(start_x, start_y, stop_x, stop_y)
        else:
            stop_y = start_y - h / 3
            self.pointing_device.drag(start_x, start_y, stop_x, stop_y)

        self._wait_to_stop_moving()

    def _wait_to_stop_moving(self):
        self.select_single(
            'QQuickFlickable',
            objectName='animationContainer').moving.wait_for(False)
