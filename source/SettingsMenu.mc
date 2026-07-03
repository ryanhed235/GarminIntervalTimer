import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

class SettingsMenu extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {}

    function onShow() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;

        var height = dc.getHeight();

        // Title
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.10, Graphics.FONT_MEDIUM, "Settings", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Divider
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(40, cy, dc.getWidth() - 40, cy);

        // Top Half: Interval Time
        var m = gIntervalSec / 60;
        var s = gIntervalSec % 60;
        var timeStr = m.format("%02d") + ":" + s.format("%02d");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.25, Graphics.FONT_MEDIUM, "Interval Time", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.40, Graphics.FONT_MEDIUM, timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Bottom Half: Total Sets
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.60, Graphics.FONT_MEDIUM, "Total Sets", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.75, Graphics.FONT_MEDIUM, gTotalSets.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Start Over Button
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.88, Graphics.FONT_MEDIUM, "Start Over", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class SettingsMenuDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onTap(clickEvent) as Boolean {
        var y = clickEvent.getCoordinates()[1];
        var height = System.getDeviceSettings().screenHeight;

        if (y > height * 0.82) {
            // Start Over
            gNeedsReset = true;
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        } else if (y < height * 0.5) {
            // Tap Interval Time
            var view = new TimePickerView(method(:onIntervalTimeChanged));
            var delegate = new TimePickerDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_UP);
            return true;
        } else {
            // Tap Total Sets
            var view = new NumberPickerView("Total Sets", gTotalSets, 1, 1, 100, method(:onTotalSetsChanged));
            var delegate = new NumberPickerDelegate(view);
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_UP);
            return true;
        }
    }

    function onSwipe(swipeEvent) as Boolean {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_DOWN) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }
        return false;
    }

    function onIntervalTimeChanged() as Void {
        gNeedsReset = true;
    }

    function onTotalSetsChanged(newValue as Number) as Void {
        gTotalSets = newValue;
        gNeedsReset = true;
    }
}
