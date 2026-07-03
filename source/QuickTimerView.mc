import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;

class QuickTimerView extends WatchUi.View {

    private var _timer as Timer.Timer?;
    private var _isRunning as Boolean = false;
    private var _endTime as Number = 0;
    private var _currentSet as Number = 0;
    private var _pausedRemainingMs as Number = 35000;

    function initialize() {
        View.initialize();
        _pausedRemainingMs = gIntervalSec * 1000;
    }

    function onLayout(dc as Dc) as Void {}

    function onShow() as Void {
        if (gNeedsReset) {
            gNeedsReset = false;
            _currentSet = 0;
            _pausedRemainingMs = gIntervalSec * 1000;
            if (_isRunning) {
                _endTime = System.getTimer() + _pausedRemainingMs;
            }
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;
        var cy = dc.getHeight() / 2;
        var currentIntervalMs = gIntervalSec * 1000;

        var remainingMs = _pausedRemainingMs;
        if (_isRunning) {
            remainingMs = _endTime - System.getTimer();
            if (remainingMs <= 0) {
                // Vibrate when hitting 0
                if (Attention has :vibrate) {
                    var vibeData = [new Attention.VibeProfile(100, 660)];
                    Attention.vibrate(vibeData);
                }
                if (Attention has :backlight) {
                    Attention.backlight(0.2); // Wake up at 20% brightness
                }
                _currentSet++;
                _endTime = System.getTimer() + currentIntervalMs;
                remainingMs = currentIntervalMs;
            }
        }

        var height = dc.getHeight();

        // 1. Draw Current Time
        var clockTime = System.getClockTime();
        var timeStr = clockTime.hour.format("%02d") + ":" + clockTime.min.format("%02d");
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.18, Graphics.FONT_MEDIUM, timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 2. Draw Red Dot if paused (anchor to the left of the time)
        if (!_isRunning) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            var textWidth = dc.getTextWidthInPixels(timeStr, Graphics.FONT_MEDIUM);
            dc.fillCircle(cx - (textWidth / 2) - 15, height * 0.18, 6);
        }

        // 3. Draw Main Timer
        var totalSec = remainingMs / 1000;
        var m = totalSec / 60;
        var s = totalSec % 60;
        var timerStr = m.format("%02d") + ":" + s.format("%02d");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.48, Graphics.FONT_NUMBER_HOT, timerStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 4. Draw Deciseconds
        var ds = (remainingMs % 1000) / 100;
        var dsStr = ds.format("%d");
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.68, Graphics.FONT_LARGE, dsStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 5. Draw Sets (0/20)
        var setStr = _currentSet.toString() + "/" + gTotalSets.toString();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height * 0.85, Graphics.FONT_MEDIUM, setStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function onHide() as Void {
        if (_isRunning) {
            toggleTimer(); // pause it when hidden
        }
    }

    function toggleTimer() as Void {
        if (_isRunning) {
            _isRunning = false;
            _pausedRemainingMs = _endTime - System.getTimer();
            if (_pausedRemainingMs < 0) { _pausedRemainingMs = 0; }
            if (_timer != null) {
                _timer.stop();
                _timer = null;
            }
        } else {
            _isRunning = true;
            _endTime = System.getTimer() + _pausedRemainingMs;
            if (_timer == null) {
                _timer = new Timer.Timer();
            }
            _timer.start(method(:onTimerCallback), 100, true);
        }
        WatchUi.requestUpdate();
    }

    function onTimerCallback() as Void {
        WatchUi.requestUpdate();
    }
}
