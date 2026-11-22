# 멍워치 — 가민 Forerunner 165 / 265 버전

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
manifest.xml              앱 정보, 대상 기기(fr165, fr165m, fr265, fr265s)
monkey.jungle             빌드 설정
source/DogApp.mc          시작점
source/DogView.mc         상태와 그리기
source/DogDelegate.mc     터치·버튼 입력
resources/drawables/      강아지 표정 36장(fr165 용 340px) + 말풍선 + 아이콘
resources-fr265/          fr265 용 강아지 사진(362px)
resources-fr265s/         fr265s 용 강아지 사진(314px)
```

## 가장 쉬운 방법: build.command 더블클릭

Finder 에서 이 폴더의 **build.command** 를 더블클릭하면 터미널 창이 열리고 아래를 자동으로 합니다.

1. Java, Connect IQ SDK, Forerunner 165 기기 파일이 있는지 확인 (없으면 받을 페이지를 열어 줌)
2. 개발자 키 생성
3. 빌드 → 시뮬레이터 실행 → 기기별 워치용 파일 `bin/mungwatch_<기기>.prg` 생성
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

워치용 파일은 기기별로 만들어집니다. **자기 워치에 맞는 파일 하나만** 넣으세요.

| 워치 | 파일 | 화면 |
|---|---|---|
| Forerunner 165 | `bin/mungwatch_fr165.prg` | 390×390 |
| Forerunner 165 Music | `bin/mungwatch_fr165m.prg` | 390×390 |
| Forerunner 265 | `bin/mungwatch_fr265.prg` | 416×416 |
| Forerunner 265S | `bin/mungwatch_fr265s.prg` | 360×360 |

SDK Manager 의 Devices 탭에서 내려받은 기기만 빌드됩니다. 265 용 파일이 안 생기면 Devices 탭에서 Forerunner 265 / 265S 를 내려받으세요.

### 플랜 A — Windows PC (가장 간단)

1. 자기 워치용 `mungwatch_<기기>.prg` 를 Windows PC 로 옮깁니다.
2. Garmin Express 가 켜져 있으면 끄고, 워치를 USB 로 연결합니다.
3. 탐색기 → 내 PC → Forerunner 165 → `GARMIN` → `APPS` 에 파일을 붙여넣습니다.
4. 안전하게 제거한 뒤 워치의 앱 목록에서 **멍워치**를 실행합니다.

### 플랜 B — Mac (워치가 Finder 에 안 보일 때)

Mac 은 MTP 방식 기기를 Finder 에 띄우지 못하므로 전송 앱이 필요합니다.

1. **OpenMTP 설치** (무료, 오픈소스): https://openmtp.ganeshrvel.com 에서 내려받아 응용 프로그램 폴더로 옮깁니다.
2. **USB 를 쓰는 다른 앱 종료**: Garmin Express, Android File Transfer, 미리보기, Google Drive, OneDrive, Dropbox 등. MTP 는 한 번에 한 앱만 연결할 수 있습니다.
3. 워치를 USB 케이블로 Mac 에 연결합니다. 워치 화면에 연결 방식을 묻는 창이 뜨면 MTP(파일 전송)를 고릅니다.
4. OpenMTP 를 엽니다. 왼쪽이 Mac, 오른쪽이 워치입니다. 오른쪽에 아무것도 안 뜨면 새로고침을 누르거나 케이블을 다시 꽂습니다.
5. 왼쪽에서 `Documents/applewatch/garmin/bin` 으로, 오른쪽에서 `GARMIN/APPS` 로 이동합니다.
6. 자기 워치용 `mungwatch_<기기>.prg` 를 왼쪽에서 오른쪽으로 끌어다 놓습니다. 끌어놓기가 안 되면 파일을 선택하고 복사(Cmd+C) 후 오른쪽 창에서 붙여넣기(Cmd+V)를 씁니다.
7. OpenMTP 를 종료하고 케이블을 뽑습니다. 워치의 앱 목록에서 **멍워치**를 실행합니다.

### 플랜 C — Mac 에서 OpenMTP 도 안 될 때

- 케이블을 바꿔 봅니다. 충전 전용 케이블은 데이터가 안 넘어갑니다. 워치에 딸려 온 케이블을 쓰고, 허브 대신 Mac 에 직접 꽂습니다.
- 그래도 안 되면 Windows PC 로 플랜 A 를 쓰는 것이 가장 확실합니다.

### 설치 후 참고

- 다시 연결해서 `APPS` 폴더를 보면 파일이 안 보일 수 있습니다. 최신 기기는 앱 파일을 숨기므로 설치가 안 된 것이 아닙니다.
- 새 버전으로 바꿀 때는 같은 이름의 파일을 다시 복사하면 덮어씁니다.
- 지울 때는 워치의 Connect IQ 스토어 앱에서 삭제하거나, PC/Mac 의 Garmin Express 를 씁니다.
