#!/usr/bin/env python3
"""눈 표정(하트·놀람·어지러움 등) 프레임 만들기.
입력: 원본 A(눈 뜸·입 벌림), B(눈 뜸·입 다묾), X(원본에서 '눈만' 바꾼 그림)
출력: assets/<dog>_<key>o.jpg (입 벌림), assets/<dog>_<key>c.jpg (입 다묾)
X 와 A 를 비교해 '달라진 부분(눈·눈썹)'만 자동으로 찾아 A, B 위에 합성합니다.

사용: python3 tools/make_eyes.py <dog> <key> A.png B.png X.png <눈 세로 위치 0~1> <입 세로 위치 0~1>
      key 는 한 글자: h=하트, s=놀람, d=어지러움
"""
import sys
import numpy as np
from PIL import Image, ImageFilter, ImageChops

dog, key, pa, pb, px = sys.argv[1:6]
eye_y, mouth_y = float(sys.argv[6]), float(sys.argv[7])
A, B, X = (Image.open(p).convert('RGB') for p in (pa, pb, px))
S = A.size[0]; B, X = B.resize(A.size), X.resize(A.size)
a = np.asarray(A.convert('L'), float)

def align(im):
    """이마·귀 영역에서 A 와 가장 잘 겹치는 이동량만큼 옮김"""
    c = np.asarray(im.convert('L'), float)
    y0, y1, x0, x1 = int(S * .08), int((eye_y - .12) * S), int(S * .15), int(S * .85)
    best = None
    for dy in range(-12, 13):
        for dx in range(-12, 13):
            e = ((a[y0:y1, x0:x1] - np.roll(np.roll(c, dy, 0), dx, 1)[y0:y1, x0:x1]) ** 2).mean()
            if best is None or e < best[0]: best = (e, dx, dy)
    return ImageChops.offset(im, best[1], best[2]), best

B, bb = align(B); X, bx = align(X)
# 달라진 부분 찾기: 색 차이가 큰 픽셀 → 잡티 제거 → 넓히고 부드럽게
diff = np.abs(np.asarray(X, float) - np.asarray(A, float)).max(axis=2)
band = np.zeros((S, S), bool); band[int((eye_y - .22) * S):int(min(mouth_y - .04, eye_y + .16) * S), int(S * .12):int(S * .88)] = True
m = Image.fromarray(((diff > 38) & band).astype('uint8') * 255)
m = m.filter(ImageFilter.MedianFilter(9)).filter(ImageFilter.MaxFilter(31)).filter(ImageFilter.GaussianBlur(S * .008))
cover = (np.asarray(m) > 128).mean() * 100
print(f'{dog}_{key}: B 이동 {bb[1:]}, X 이동 {bx[1:]}, 바뀐 영역 {cover:.1f}%')
for mk, base in (('o', A), ('c', B)):
    Image.composite(X, base, m).resize((320, 320), Image.LANCZOS).save(f'assets/{dog}_{key}{mk}.jpg', quality=86, optimize=True)
