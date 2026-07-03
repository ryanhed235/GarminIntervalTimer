import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

var gIntervalSec as Number = 35;
var gTotalSets as Number = 20;
var gNeedsReset as Boolean = false;

class QuickTimerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() {
        var view = new QuickTimerView();
        var delegate = new QuickTimerDelegate(view);
        return [view, delegate];
    }
}

function getApp() as QuickTimerApp {
    return Application.getApp() as QuickTimerApp;
}
