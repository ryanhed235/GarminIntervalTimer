import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

class TimePickerView extends WatchUi.View {
    private var _onUpdateCallback as Method;

    function initialize(callback as Method) {
        View.initialize();
        _onUpdateCallback = callback;
    }

    function onLayout(dc as Dc) as Void {}

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;

        var m = gIntervalSec / 60;
        var s = gIntervalSec % 60;
        var timeStr = m.format("%02d") + ":" + s.format("%02d");

        // Value
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Graphics.FONT_NUMBER_HOT, timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Plus Minutes
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(cx - 80 - 20, cy - 120 - 4, 40, 8);
        dc.fillRectangle(cx - 80 - 4, cy - 120 - 20, 8, 40);

        // Minus Minutes
        dc.fillRectangle(cx - 80 - 20, cy + 120 - 4, 40, 8);

        // Plus Seconds
        dc.fillRectangle(cx + 80 - 20, cy - 120 - 4, 40, 8);
        dc.fillRectangle(cx + 80 - 4, cy - 120 - 20, 8, 40);

        // Minus Seconds
        dc.fillRectangle(cx + 80 - 20, cy + 120 - 4, 40, 8);
    }

    function incrementMinutes() as Void {
        gIntervalSec += 60;
        if (gIntervalSec > 3600) { gIntervalSec = 3600; }
        _onUpdateCallback.invoke();
        WatchUi.requestUpdate();
    }

    function decrementMinutes() as Void {
        if (gIntervalSec >= 60) {
            gIntervalSec -= 60;
        }
        _onUpdateCallback.invoke();
        WatchUi.requestUpdate();
    }

    function incrementSeconds() as Void {
        gIntervalSec += 5;
        if (gIntervalSec > 3600) { gIntervalSec = 3600; }
        _onUpdateCallback.invoke();
        WatchUi.requestUpdate();
    }

    function decrementSeconds() as Void {
        gIntervalSec -= 5;
        if (gIntervalSec < 5) { gIntervalSec = 5; }
        _onUpdateCallback.invoke();
        WatchUi.requestUpdate();
    }
}

class TimePickerDelegate extends WatchUi.BehaviorDelegate {
    private var _view as TimePickerView;
    private var _holdTimer as Toybox.Timer.Timer?;
    private var _holdX as Number = 0;
    private var _holdY as Number = 0;

    function initialize(view as TimePickerView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        var cx = System.getDeviceSettings().screenWidth / 2;
        var cy = System.getDeviceSettings().screenHeight / 2;
        
        if (x < cx) {
            // Minutes
            if (y < cy - 20) { _view.incrementMinutes(); }
            else if (y > cy + 20) { _view.decrementMinutes(); }
        } else {
            // Seconds
            if (y < cy - 20) { _view.incrementSeconds(); }
            else if (y > cy + 20) { _view.decrementSeconds(); }
        }
        return true;
    }

    function onHold(clickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        _holdX = coords[0];
        _holdY = coords[1];
        if (_holdTimer == null) {
            _holdTimer = new Toybox.Timer.Timer();
        }
        _holdTimer.start(method(:onHoldTimerTick), 150, true);
        return true;
    }

    function onRelease(clickEvent) as Boolean {
        if (_holdTimer != null) {
            _holdTimer.stop();
            _holdTimer = null;
        }
        return true;
    }

    function onHoldTimerTick() as Void {
        var cx = System.getDeviceSettings().screenWidth / 2;
        var cy = System.getDeviceSettings().screenHeight / 2;
        if (_holdX < cx) {
            if (_holdY < cy - 20) { _view.incrementMinutes(); }
            else if (_holdY > cy + 20) { _view.decrementMinutes(); }
        } else {
            if (_holdY < cy - 20) { _view.incrementSeconds(); }
            else if (_holdY > cy + 20) { _view.decrementSeconds(); }
        }
    }

    function onSwipe(swipeEvent) as Boolean {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_DOWN) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }
        return false;
    }
}
