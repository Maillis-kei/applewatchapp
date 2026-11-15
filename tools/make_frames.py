#!/usr/bin/env python3
"""표정 프레임 만들기.
입력: 원본(눈 뜸·입 벌림) A, 눈 뜸·입 다묾 B, 눈 감음·입 다묾 C  (모두 같은 구도의 정사각형, 검정 배경)
출력: assets/<dog>_oc.jpg (눈 뜸·입 다묾), <dog>_co.jpg (눈 감음·입 벌림), <dog>_cc.jpg (눈 감음·입 다묾)
눈 감은 프레임은 C 전체를 쓰지 않고, C 의 '눈 주변만' A/B 위에 부드럽게 합성합니다.
→ 깜빡일 때 눈만 바뀌고 귀·볼·털은 그대로라 화면이 튀지 않습니다.

사용: python3 tools/make_frames.py <dog> A.png B.png C.png  cx,cy,rx,ry  cx,cy,rx,ry
      (마지막 두 값은 합성할 눈 주변 타원 2개: 중심과 반지름, 이미지 안 0~1 좌표)
"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageChops

dog, pa, pb, pc = sys.argv[1:5]
eyes = [tuple(float(v) for v in s.split(',')) for s in sys.argv[5:7]]
A, B, C = (Image.open(p).convert('RGB') for p in (pa, pb, pc))
S = A.size[0]
B, C = B.resize(A.size), C.resize(A.size)
yy, xx = np.ogrid[:S, :S]
inside = np.zeros((S, S), bool)
for cx, cy, rx, ry in eyes: inside |= ((xx - cx * S) / (rx * S)) ** 2 + ((yy - cy * S) / (ry * S)) ** 2 <= 1
a = np.asarray(A.convert('L'), float)

def align(im, region, name):
    """region(참/거짓 배열) 안에서 A 와 가장 잘 겹치는 이동량을 찾아 그만큼 옮긴 이미지를 돌려줌"""
    c = np.asarray(im.convert('L'), float)
    ys, xs = np.where(region); y0, y1, x0, x1 = ys.min(), ys.max(), xs.min(), xs.max()
    r = region[y0:y1, x0:x1]; best = None
    for dy in range(-20, 21):
        for dx in range(-20, 21):
            s = np.roll(np.roll(c, dy, 0), dx, 1)
            e = (((a - s) ** 2)[y0:y1, x0:x1][r]).mean()
            if best is None or e < best[0]: best = (e, dx, dy)
    print(f'{dog} {name}: 이동 {best[1:]}px, 오차 {best[0]:.0f}')
    return ImageChops.offset(im, best[1], best[2])

# 눈 위쪽(이마·귀)은 표정이 바뀌어도 그대로이므로 그 영역으로 B, C 를 A 에 맞춤
top = np.zeros((S, S), bool)
top[int(S * .08):int(min(e[1] - e[3] for e in eyes) * S), int(S * .15):int(S * .85)] = True
B = align(B, top, 'B'); Cs = align(C, top, 'C')

m = Image.fromarray((inside * 255).astype('uint8')).filter(ImageFilter.GaussianBlur(S * .013))
frames = {'oc': B, 'co': Image.composite(Cs, A, m), 'cc': Image.composite(Cs, B, m)}
for k, im in frames.items():
    im.resize((320, 320), Image.LANCZOS).save(f'assets/{dog}_{k}.jpg', quality=86, optimize=True)
