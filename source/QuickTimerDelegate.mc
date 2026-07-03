import Toybox.WatchUi;
import Toybox.Lang;

class QuickTimerDelegate extends WatchUi.BehaviorDelegate {

    private var _view as QuickTimerView;

    function initialize(view as QuickTimerView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() as Boolean {
        _view.toggleTimer();
        return true;
    }

    function onBack() as Boolean {
        // Return false to allow the OS to exit the app natively
        return false; 
    }

    function onSwipe(swipeEvent) as Boolean {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_UP) {
            var menu = new SettingsMenu();
            var delegate = new SettingsMenuDelegate();
            WatchUi.pushView(menu, delegate, WatchUi.SLIDE_UP);
            return true;
        }
        return false;
    }
}
