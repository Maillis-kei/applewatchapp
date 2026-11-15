import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// 앱 시작점: 화면(DogView)과 입력 처리(DogDelegate)를 연결합니다.
class DogApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() {
        var view = new DogView();
        return [view, new DogDelegate(view)];
    }
}
