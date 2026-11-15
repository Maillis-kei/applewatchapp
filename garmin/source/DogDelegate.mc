import Toybox.Lang;
import Toybox.WatchUi;

// 입력 처리
//   화면 탭            → 쓰다듬기(하트) / 가끔 "멍!"
//   화면 길게 누르기   → 간식
//   좌우로 쓸기        → 견종 바꾸기
//   위/아래 버튼       → 견종 바꾸기
//   시작(START) 버튼   → 간식
//   뒤로(BACK) 버튼    → 앱 종료 (기본 동작)
class DogDelegate extends WatchUi.BehaviorDelegate {

    private var mView;

    function initialize(view) {
        BehaviorDelegate.initialize();
        mView = view;
    }

    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        mView.pet();
        return true;
    }

    function onHold(evt as WatchUi.ClickEvent) as Boolean {
        mView.treat();
        return true;
    }

    function onSwipe(evt as WatchUi.SwipeEvent) as Boolean {
        var dir = evt.getDirection();
        if (dir == WatchUi.SWIPE_LEFT) {
            mView.changeDog(1);
            return true;
        }
        if (dir == WatchUi.SWIPE_RIGHT) {
            // 오른쪽 쓸기는 원래 '뒤로 가기'지만, 여기서는 이전 강아지로 씁니다.
            mView.changeDog(-1);
            return true;
        }
        return false;
    }

    function onNextPage() as Boolean {
        mView.changeDog(1);
        return true;
    }

    function onPreviousPage() as Boolean {
        mView.changeDog(-1);
        return true;
    }

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        if (evt.getKey() == WatchUi.KEY_ENTER) {
            mView.treat();
            return true;
        }
        return false;
    }
}
