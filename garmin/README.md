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

## 가장 쉬운 방법: build.command 더블클릭

Finder 에서 이 폴더의 **build.command** 를 더블클릭하면 터미널 창이 열리고 아래를 자동으로 합니다.

1. Java, Connect IQ SDK, Forerunner 165 기기 파일이 있는지 확인 (없으면 받을 페이지를 열어 줌)
2. 개발자 키 생성
3. 빌드 → 시뮬레이터 실행 → 워치용 파일 `bin/mungwatch.prg` 생성
4. 소스가 바뀔 때마다 자동으로 다시 빌드 (창을 닫으면 멈춤)

진행 상황과 오류는 `build_log.txt` 에 기록됩니다.
처음 실행할 때 "확인되지 않은 개발자" 경고가 뜨면 파일을 우클릭 → 열기 를 선택하세요.

직접 준비해야 하는 것은 **Connect IQ SDK Manager 설치와 가민 계정 로그인**(SDK 와 Forerunner 165 기기 내려받기), 그리고 Java 가 없을 경우 JDK 설치입니다.

## VS Code 로 하는 방법 (선택)

1. VS Code 확장에서 **Monkey C** (Garmin 제작) 설치
2. https://developer.garmin.com/connect-iq/sdk/ 에서 **Connect IQ SDK Manager** 를 받아 실행, 가민 계정으로 로그인
3. SDK Manager 에서 최신 SDK 와 **Forerunner 165** 기기를 내려받기
4. VS Code 에서 `Cmd+Shift+P` → **Monkey C: Generate a Developer Key** 로 키 생성
5. Java 가 없다는 오류가 나오면 JDK 17 설치

### 시뮬레이터에서 실행

1. VS Code 로 이 `garmin` 폴더를 엽니다.
2. `Cmd+Shift+P` → **Monkey C: Verify Installation**
3. `F5` (Run) → 기기 목록에서 **fr165** 선택

## 워치에 설치

1. `bin/mungwatch.prg` 를 준비합니다 (build.command 가 만들어 줍니다. 음악 모델이면 `build.command` 대신 터미널에서 `./build.command fr165m`).
2. 워치를 USB 로 Mac 에 연결합니다. Finder 에 안 보이면 OpenMTP 같은 MTP 전송 앱이 필요합니다.
3. 만들어진 `.prg` 파일을 워치의 `GARMIN/APPS` 폴더로 복사하고 연결을 해제합니다.
4. 워치의 앱 목록에서 **멍워치**를 실행합니다.
