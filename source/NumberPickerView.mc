import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

class NumberPickerView extends WatchUi.View {
    private var _title as String;
    private var _value as Number;
    private var _step as Number;
    private var _min as Number;
    private var _max as Number;
    private var _onUpdateCallback as Method;

    function initialize(title as String, initialValue as Number, step as Number, min as Number, max as Number, callback as Method) {
        View.initialize();
        _title = title;
        _value = initialValue;
        _step = step;
        _min = min;
        _max = max;
        _onUpdateCallback = callback;
    }

    function onLayout(dc as Dc) as Void {}

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;

        var height = dc.getHeight();

        // Title
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.15, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Value
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Graphics.FONT_NUMBER_HOT, _value.toString(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Plus Button
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(cx - 20, height * 0.28 - 4, 40, 8);
        dc.fillRectangle(cx - 4, height * 0.28 - 20, 8, 40);

        // Minus Button
        dc.fillRectangle(cx - 20, height * 0.72 - 4, 40, 8);
    }

    function increment() as Void {
        _value += _step;
        if (_value > _max) { _value = _max; }
        _onUpdateCallback.invoke(_value);
        WatchUi.requestUpdate();
    }

    function decrement() as Void {
        _value -= _step;
        if (_value < _min) { _value = _min; }
        _onUpdateCallback.invoke(_value);
        WatchUi.requestUpdate();
    }
}

class NumberPickerDelegate extends WatchUi.BehaviorDelegate {
    private var _view as NumberPickerView;
    private var _holdTimer as Toybox.Timer.Timer?;
    private var _holdY as Number = 0;

    function initialize(view as NumberPickerView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var y = coords[1];
        var cy = System.getDeviceSettings().screenHeight / 2;
        
        if (y < cy - 20) {
            _view.increment();
            return true;
        } else if (y > cy + 20) {
            _view.decrement();
            return true;
        }
        return false;
    }

    function onHold(clickEvent) as Boolean {
        _holdY = clickEvent.getCoordinates()[1];
        if (_holdTimer == null) {
            _holdTimer = new Toybox.Timer.Timer();
        }
        // Auto-increment every 150ms while holding
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
        var cy = System.getDeviceSettings().screenHeight / 2;
        if (_holdY < cy - 20) {
            _view.increment();
        } else if (_holdY > cy + 20) {
            _view.decrement();
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
