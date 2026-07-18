import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
import Toybox.ActivityRecording;

class QuickTimerView extends WatchUi.View {

    private var _timer as Timer.Timer?;
    private var _isRunning as Boolean = false;
    private var _endTime as Number = 0;
    private var _currentSet as Number = 0;
    private var _pausedRemainingMs as Number = 35000;
    private var _lastWakeMinute as Number = -1;
    private var _session as ActivityRecording.Session?;

    function initialize() {
        View.initialize();
        _pausedRemainingMs = gIntervalSec * 1000;
    }

    function onLayout(dc as Dc) as Void {}

    function onShow() as Void {
        if (gNeedsReset) {
            if (_session != null) {
                if (_session.isRecording()) {
                    _session.stop();
                }
                _session.discard();
                _session = null;
            }
            gNeedsReset = false;
            _currentSet = 0;
            _pausedRemainingMs = gIntervalSec * 1000;
            _lastWakeMinute = -1;
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
                    try {
                        var vibeData = [new Attention.VibeProfile(100, 660)] as Lang.Array<Attention.VibeProfile>;
                        Attention.vibrate(vibeData);
                    } catch (e) {
                        System.println("Vibrate failed: " + e.getErrorMessage());
                    }
                }
                if (Attention has :backlight) {
                    try {
                        Attention.backlight(true); // Wake up backlight
                    } catch (e) {
                        System.println("Backlight failed: " + e.getErrorMessage());
                    }
                }
                _currentSet++;
                _endTime = System.getTimer() + currentIntervalMs;
                remainingMs = currentIntervalMs;
                _lastWakeMinute = -1;
            } else {
                var totalSec = remainingMs / 1000;
                if (totalSec > 0 && totalSec % 60 == 0) {
                    if (_lastWakeMinute != totalSec) {
                        _lastWakeMinute = totalSec;
                        if (Attention has :vibrate) {
                            try {
                                var silentVibe = [new Attention.VibeProfile(0, 1)] as Lang.Array<Attention.VibeProfile>;
                                Attention.vibrate(silentVibe);
                            } catch (e) {
                                System.println("Periodic silent vibrate failed: " + e.getErrorMessage());
                            }
                        }
                        if (Attention has :backlight) {
                            try {
                                Attention.backlight(true);
                            } catch (e) {
                                System.println("Periodic backlight failed: " + e.getErrorMessage());
                            }
                        }
                    }
                }
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
            if (_session != null && _session.isRecording()) {
                _session.stop();
            }
        } else {
            _isRunning = true;
            _endTime = System.getTimer() + _pausedRemainingMs;
            _lastWakeMinute = -1;
            if (_timer == null) {
                _timer = new Timer.Timer();
            }
            if (_session == null) {
                if (Toybox has :ActivityRecording) {
                    _session = ActivityRecording.createSession({
                        :name=>"Intervals",
                        :sport=>ActivityRecording.SPORT_TRAINING,
                        :subSport=>ActivityRecording.SUB_SPORT_GENERIC
                    });
                }
            }
            if (_session != null && !_session.isRecording()) {
                _session.start();
            }
            _timer.start(method(:onTimerCallback), 100, true);
        }
        WatchUi.requestUpdate();
    }

    function onTimerCallback() as Void {
        WatchUi.requestUpdate();
    }
}
