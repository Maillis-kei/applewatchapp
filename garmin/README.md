# 멍워치 — 가민 Forerunner 165 버전

센서 없이 화면 가득 강아지가 떠 있고, 터치와 버튼에 반응하는 앱입니다.

| 조작 | 반응 |
|---|---|
| 가만히 둘 때 | 눈 깜빡임, 가끔 입 다물기, 숨쉬기 |
| 화면 탭 | 하트 눈 / 눈웃음 / "멍!" + 하트 |
| 길게 누르기, START 버튼 | 간식 → 오물오물 → 하트 눈 |
| 좌우로 쓸기, UP/DOWN 버튼 | 견종 바꾸기 (6종, 마지막 선택 기억) |
| 45초 동안 조작 없음 | 잠들기, 탭하면 깨어남 |
| BACK 버튼 | 종료 |

## 구성

```
manifest.xml              앱 정보, 대상 기기(fr165, fr165m)
monkey.jungle             빌드 설정
source/DogApp.mc          시작점
source/DogView.mc         상태와 그리기
source/DogDelegate.mc     터치·버튼 입력
resources/drawables/      강아지 표정 36장(260px) + 말풍선 + 아이콘
```

## 빌드 준비 (Mac, 한 번만)

1. VS Code 확장에서 **Monkey C** (Garmin 제작) 설치
2. https://developer.garmin.com/connect-iq/sdk/ 에서 **Connect IQ SDK Manager** 를 받아 실행, 가민 계정으로 로그인
3. SDK Manager 에서 최신 SDK 와 **Forerunner 165** 기기를 내려받기
4. VS Code 에서 `Cmd+Shift+P` → **Monkey C: Generate a Developer Key** 로 키 생성
5. Java 가 없다는 오류가 나오면 JDK 17 설치

## 시뮬레이터에서 실행

1. VS Code 로 이 `garmin` 폴더를 엽니다.
2. `Cmd+Shift+P` → **Monkey C: Verify Installation**
3. `F5` (Run) → 기기 목록에서 **fr165** 선택

## 워치에 설치

1. `Cmd+Shift+P` → **Monkey C: Build for Device** → **fr165** (음악 모델은 fr165m) → 저장 위치 선택
2. 워치를 USB 로 Mac 에 연결합니다. Finder 에 안 보이면 OpenMTP 같은 MTP 전송 앱이 필요합니다.
3. 만들어진 `.prg` 파일을 워치의 `GARMIN/APPS` 폴더로 복사하고 연결을 해제합니다.
4. 워치의 앱 목록에서 **멍워치**를 실행합니다.
