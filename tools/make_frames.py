#!/usr/bin/env python3
"""표정 프레임 만들기.
입력: 원본(눈 뜸·입 벌림) A, 눈 뜸·입 다묾 B, 눈 감음·입 다묾 C  (모두 같은 구도의 정사각형, 검정 배경)
출력: assets/<dog>_oc.jpg (눈 뜸·입 다묾), <dog>_co.jpg (눈 감음·입 벌림), <dog>_cc.jpg (눈 감음·입 다묾)
눈 감은 프레임은 C 전체를 쓰지 않고, C 의 '눈 주변만' A/B 위에 부드럽게 합성합니다.
→ 깜빡일 때 눈만 바뀌고 귀·볼·털은 그대로라 화면이 튀지 않습니다.

사용: python3 tools/make_frames.py shiba A.png B.png C.png 0.368,0.438 0.660,0.458
      (마지막 두 값은 index.html 의 DOGS[dog].eyes 에 있는 두 눈의 중심 좌표)
"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageChops

dog, pa, pb, pc = sys.argv[1:5]
eyes = [tuple(float(v) for v in s.split(',')) for s in sys.argv[5:7]]
A, B, C = (Image.open(p).convert('RGB') for p in (pa, pb, pc))
S = A.size[0]
B, C = B.resize(A.size), C.resize(A.size)
pts = [(int(x * S), int(y * S)) for x, y in eyes]
rx, ry = int(S * .089), int(S * .069)

# C 를 A 에 맞춰 정렬: 눈을 뺀 주변(이마·볼)이 가장 잘 겹치는 이동량을 찾음
a = np.asarray(A.convert('L'), float); c = np.asarray(C.convert('L'), float)
yy, xx = np.ogrid[:S, :S]
ring = np.ones((S, S), bool)
for cx, cy in pts: ring &= ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2 > 1
y0, y1 = min(p[1] for p in pts) - 2 * ry, max(p[1] for p in pts) + 2 * ry
x0, x1 = min(p[0] for p in pts) - 2 * rx, max(p[0] for p in pts) + 2 * rx
best = None
for dy in range(-20, 21):
    for dx in range(-20, 21):
        s = np.roll(np.roll(c, dy, 0), dx, 1)
        e = (((a - s) ** 2)[y0:y1, x0:x1][ring[y0:y1, x0:x1]]).mean()
        if best is None or e < best[0]: best = (e, dx, dy)
print('정렬 이동량(px):', best[1:], '오차:', round(best[0], 1))
Cs = ImageChops.offset(C, best[1], best[2])

m = Image.new('L', A.size, 0); d = ImageDraw.Draw(m)
for cx, cy in pts: d.ellipse([cx - rx, cy - ry, cx + rx, cy + ry - 4], fill=255)
m = m.filter(ImageFilter.GaussianBlur(S * .013))
frames = {'oc': B, 'co': Image.composite(Cs, A, m), 'cc': Image.composite(Cs, B, m)}
for k, im in frames.items():
    im.resize((320, 320), Image.LANCZOS).save(f'assets/{dog}_{k}.jpg', quality=86, optimize=True)
print('저장 완료:', ', '.join(f'assets/{dog}_{k}.jpg' for k in frames))
