import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.WatchUi;

// 강아지 화면: 0.1초마다 상태를 갱신하고 다시 그립니다.
// 표정은 사진 6장을 갈아 끼우는 방식입니다.
//   번호 = 눈*2 + 입   (눈: 0 뜸, 1 감음, 2 하트 / 입: 0 벌림, 1 다묾)
class DogView extends WatchUi.View {

    private const DT = 0.1;              // 한 틱의 길이(초)
    private const SLEEP_AFTER = 45.0;    // 이 시간 동안 조작이 없으면 잠듦(초)

    private var mFrames;                 // [견종][표정] → 리소스 ID
    private var mCache;                  // 현재 견종의 표정 사진(처음 쓸 때 불러옴)
    private var mDog = 0;                // 현재 견종 번호
    private var mBubbleBark = null;
    private var mBubbleYum = null;
    private var mTimer = null;

    // 상태 (남은 시간은 모두 초 단위)
    private var mT = 0.0;                // 흐른 시간
    private var mIdle = 0.0;             // 마지막 조작 이후 시간
    private var mAsleep = false;
    private var mBlinkIn = 2.0;          // 다음 깜빡임까지
    private var mBlink = 0.0;            // 눈 감고 있는 남은 시간
    private var mShutIn = 7.0;           // 다음에 입을 다물 때까지
    private var mShut = 0.0;             // 입 다물고 있는 남은 시간
    private var mHeart = 0.0;            // 하트 눈
    private var mSquint = 0.0;           // 눈웃음(눈 감음)
    private var mBark = 0.0;             // 짖는 중
    private var mChew = 0.0;             // 씹는 중
    private var mTreat = 0.0;            // 간식이 떨어지는 중
    private var mBubble = 0;             // 0 없음, 1 멍!, 2 냠!
    private var mBubbleT = 0.0;
    private var mHearts = [];            // 떠오르는 하트: [x, y, 남은 수명]
    private var mSwitch = 0.0;           // 견종을 바꾼 직후의 '통' 튀는 효과

    function initialize() {
        View.initialize();
        mFrames = [
            [Rez.Drawables.shiba_oo,  Rez.Drawables.shiba_oc,  Rez.Drawables.shiba_co,  Rez.Drawables.shiba_cc,  Rez.Drawables.shiba_ho,  Rez.Drawables.shiba_hc],
            [Rez.Drawables.bichon_oo, Rez.Drawables.bichon_oc, Rez.Drawables.bichon_co, Rez.Drawables.bichon_cc, Rez.Drawables.bichon_ho, Rez.Drawables.bichon_hc],
            [Rez.Drawables.poodle_oo, Rez.Drawables.poodle_oc, Rez.Drawables.poodle_co, Rez.Drawables.poodle_cc, Rez.Drawables.poodle_ho, Rez.Drawables.poodle_hc],
            [Rez.Drawables.corgi_oo,  Rez.Drawables.corgi_oc,  Rez.Drawables.corgi_co,  Rez.Drawables.corgi_cc,  Rez.Drawables.corgi_ho,  Rez.Drawables.corgi_hc],
            [Rez.Drawables.husky_oo,  Rez.Drawables.husky_oc,  Rez.Drawables.husky_co,  Rez.Drawables.husky_cc,  Rez.Drawables.husky_ho,  Rez.Drawables.husky_hc],
            [Rez.Drawables.golden_oo, Rez.Drawables.golden_oc, Rez.Drawables.golden_co, Rez.Drawables.golden_cc, Rez.Drawables.golden_ho, Rez.Drawables.golden_hc]
        ];
        mCache = [null, null, null, null, null, null];

        // 마지막으로 고른 견종을 기억
        var saved = Application.Storage.getValue("dog");
        if (saved != null && saved instanceof Number && saved >= 0 && saved < mFrames.size()) {
            mDog = saved;
        }
    }

    function onShow() as Void {
        if (mTimer == null) {
            mTimer = new Timer.Timer();
        }
        mTimer.start(method(:onTick), 100, true);
    }

    function onHide() as Void {
        if (mTimer != null) {
            mTimer.stop();
        }
    }

    // ───────── 조작 ─────────

    function pet() as Void {
        if (wake()) { return; }
        if (Math.rand() % 4 == 0) {
            bark();
        } else if (Math.rand() % 2 == 0) {
            mSquint = 0.8;
        } else {
            mHeart = 1.3;
        }
        addHearts(3);
    }

    function treat() as Void {
        if (wake()) { return; }
        mTreat = 0.8;                    // 간식이 0.8초 동안 떨어진 뒤 먹음
    }

    function changeDog(step as Number) as Void {
        var n = mFrames.size();
        mDog = (mDog + step + n) % n;
        mCache = [null, null, null, null, null, null];   // 이전 견종 사진을 메모리에서 내려놓음
        Application.Storage.setValue("dog", mDog);
        mIdle = 0.0;
        mAsleep = false;
        mSwitch = 0.3;
        bark();
    }

    private function bark() as Void {
        mBark = 0.4;
        mBubble = 1;
        mBubbleT = 1.0;
    }

    // 자고 있었다면 깨우고 true 를 돌려줌
    private function wake() as Boolean {
        mIdle = 0.0;
        if (mAsleep) {
            mAsleep = false;
            bark();
            return true;
        }
        return false;
    }

    private function addHearts(count as Number) as Void {
        for (var i = 0; i < count; i += 1) {
            mHearts.add([(Math.rand() % 120) - 60, -70 - (Math.rand() % 30), 1.0]);
        }
    }

    // ───────── 상태 갱신 (0.1초마다) ─────────

    function onTick() as Void {
        mT += DT;
        mIdle += DT;
        if (!mAsleep && mIdle > SLEEP_AFTER) {
            mAsleep = true;
        }

        if (!mAsleep) {
            // 눈 깜빡임: 2.5~5.5초마다, 0.2초 동안
            if (mBlink > 0) {
                mBlink -= DT;
            } else {
                mBlinkIn -= DT;
                if (mBlinkIn <= 0) {
                    mBlink = 0.2;
                    mBlinkIn = 2.5 + (Math.rand() % 30) / 10.0;
                }
            }
            // 가끔 2~4초 입을 다물고 있음
            if (mShut > 0) {
                mShut -= DT;
            } else {
                mShutIn -= DT;
                if (mShutIn <= 0) {
                    mShut = 2.0 + (Math.rand() % 20) / 10.0;
                    mShutIn = 7.0 + (Math.rand() % 70) / 10.0;
                }
            }
        }

        if (mHeart > 0)   { mHeart -= DT; }
        if (mSquint > 0)  { mSquint -= DT; }
        if (mBark > 0)    { mBark -= DT; }
        if (mChew > 0)    { mChew -= DT; }
        if (mSwitch > 0)  { mSwitch -= DT; }
        if (mBubbleT > 0) { mBubbleT -= DT; }

        // 간식: 다 떨어지면 먹기 시작
        if (mTreat > 0) {
            mTreat -= DT;
            if (mTreat <= 0) {
                mChew = 1.2;
                mHeart = 1.8;
                mBubble = 2;
                mBubbleT = 1.0;
                addHearts(2);
            }
        }

        // 하트: 위로 떠오르며 사라짐
        var alive = [];
        for (var i = 0; i < mHearts.size(); i += 1) {
            var h = mHearts[i];
            h[1] -= 6;
            h[2] -= 0.09;
            if (h[2] > 0) {
                alive.add(h);
            }
        }
        mHearts = alive;

        WatchUi.requestUpdate();
    }

    // ───────── 그리기 ─────────

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // 눈: 잠 > 깜빡임·눈웃음 > 하트 > 기본
        var eyes = 0;
        if (mAsleep || mBlink > 0 || mSquint > 0) {
            eyes = 1;
        } else if (mHeart > 0) {
            eyes = 2;
        }
        // 입: 평소엔 벌림. 잘 때·가끔·짖기 직전에 다묾, 씹을 때는 번갈아
        var mouth = 0;
        if (mAsleep || mShut > 0) {
            mouth = 1;
        }
        if (mBark > 0) {
            mouth = (mBark > 0.28) ? 1 : 0;
        }
        if (mChew > 0) {
            mouth = ((mChew * 5).toNumber() % 2 == 0) ? 1 : 0;
        }

        var idx = eyes * 2 + mouth;
        if (mCache[idx] == null) {
            mCache[idx] = WatchUi.loadResource(mFrames[mDog][idx]);
        }
        var bmp = mCache[idx];

        // 크기: 화면의 88% + 숨쉬기(±2%) + 짖을 때·바꿀 때 살짝 커짐
        var scale = 0.88 + 0.02 * Math.sin(mT * (mAsleep ? 1.2 : 2.3));
        if (mBark > 0 && mBark <= 0.28) { scale += 0.04; }
        if (mSwitch > 0) { scale += 0.2 * mSwitch; }
        var size = (w * scale).toNumber();
        var dy = (mAsleep ? h * 0.03 : 0).toNumber();
        dc.drawScaledBitmap(cx - size / 2, cy - size / 2 + dy, size, size, bmp);

        // 잘 때: Z 표시
        if (mAsleep) {
            var p = ((mT * 10).toNumber() % 20) / 20.0;       // 0~1 을 2초마다 반복
            drawZ(dc, cx + w * 0.22 + p * 20, h * 0.26 - p * 26, 12 + (p * 8).toNumber());
        }

        // 간식(뼈다귀)이 위에서 입 쪽으로 떨어짐
        if (mTreat > 0) {
            var t = 1.0 - mTreat / 0.8;
            drawBone(dc, cx, (h * 0.1 + t * h * 0.55).toNumber());
        }

        // 하트
        for (var i = 0; i < mHearts.size(); i += 1) {
            var ht = mHearts[i];
            drawHeart(dc, cx + ht[0], cy + ht[1], 12);
        }

        // 말풍선 (글자 대신 그림 사용)
        if (mBubbleT > 0 && mBubble != 0) {
            var bub;
            if (mBubble == 1) {
                if (mBubbleBark == null) { mBubbleBark = WatchUi.loadResource(Rez.Drawables.bubble_bark); }
                bub = mBubbleBark;
            } else {
                if (mBubbleYum == null) { mBubbleYum = WatchUi.loadResource(Rez.Drawables.bubble_yum); }
                bub = mBubbleYum;
            }
            dc.drawBitmap(cx - 60, (h * 0.06).toNumber(), bub);
        }

        // 아래쪽 점: 지금 몇 번째 강아지인지
        var n = mFrames.size();
        for (var k = 0; k < n; k += 1) {
            dc.setColor(k == mDog ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx + (k * 2 - (n - 1)) * 7, h - 16, k == mDog ? 4 : 3);
        }
    }

    private function drawHeart(dc as Dc, x, y, s) as Void {
        x = x.toNumber();
        y = y.toNumber();
        dc.setColor(0xFF5D7A, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - s / 2, y, s / 2 + 1);
        dc.fillCircle(x + s / 2, y, s / 2 + 1);
        dc.fillPolygon([[x - s, y + 2], [x + s, y + 2], [x, y + s + 3]]);
    }

    private function drawBone(dc as Dc, x, y) as Void {
        dc.setColor(0xF1E3C6, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - 22, y - 6, 44, 12);
        dc.fillCircle(x - 24, y - 7, 9);
        dc.fillCircle(x - 24, y + 7, 9);
        dc.fillCircle(x + 24, y - 7, 9);
        dc.fillCircle(x + 24, y + 7, 9);
    }

    private function drawZ(dc as Dc, x, y, s) as Void {
        x = x.toNumber();
        y = y.toNumber();
        dc.setColor(0xCFD8FF, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawLine(x, y, x + s, y);
        dc.drawLine(x + s, y, x, y + s);
        dc.drawLine(x, y + s, x + s, y + s);
        dc.setPenWidth(1);
    }
}
