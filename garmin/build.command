#!/bin/bash
# ─────────────────────────────────────────────────────────────
# 멍워치 가민 빌드 도우미 (Mac 에서 더블클릭해서 실행)
#  1) Java · Connect IQ SDK · Forerunner 165 기기 파일이 있는지 확인
#  2) 개발자 키가 없으면 만들기
#  3) 빌드 → 시뮬레이터 실행 → 기기별 워치용 파일 만들기
#       bin/mungwatch_fr165.prg, bin/mungwatch_fr265.prg, bin/mungwatch_fr265s.prg ...
#     시뮬레이터 기기를 바꾸려면 터미널에서:  ./build.command fr265
#  4) 소스가 바뀌면 자동으로 다시 빌드 (창을 닫으면 멈춤)
# 진행 상황은 이 폴더의 build_log.txt 에 기록됩니다.
# ─────────────────────────────────────────────────────────────
cd "$(dirname "$0")" || exit 1
LOG="build_log.txt"
CIQ="$HOME/Library/Application Support/Garmin/ConnectIQ"
DEVICES="fr165 fr165m fr265 fr265s"   # 워치용 파일을 만들 기기들
SIMDEV="${1:-fr165}"                  # 시뮬레이터로 띄울 기기
KEY="$HOME/.mungwatch_garmin_key.der"
say(){ echo "$@" | tee -a "$LOG"; }

: > "$LOG"
say "=== 멍워치 가민 빌드 도우미  $(date '+%F %T') ==="
MISSING=""

# 1) Java
if /usr/libexec/java_home >/dev/null 2>&1; then
  say "[확인] Java: $(java -version 2>&1 | head -1)"
else
  say "[필요] Java(JDK)가 없습니다. 방금 열린 페이지에서 macOS 용 JDK 17 (.pkg) 을 받아 설치해 주세요."
  open "https://adoptium.net/temurin/releases/?version=17&os=mac"
  MISSING=1
fi

# 2) Connect IQ SDK
SDK=""
if [ -f "$CIQ/current-sdk.cfg" ]; then SDK="$(cat "$CIQ/current-sdk.cfg")"; SDK="${SDK%/}"; fi
if [ -z "$SDK" ] || [ ! -e "$SDK/bin/monkeyc" ]; then
  SDK="$(ls -d "$CIQ"/Sdks/*/ 2>/dev/null | sort | tail -1)"; SDK="${SDK%/}"
fi
if [ -n "$SDK" ] && [ -e "$SDK/bin/monkeyc" ]; then
  say "[확인] SDK: $(basename "$SDK")"
else
  say "[필요] Connect IQ SDK 가 없습니다. 방금 열린 페이지에서 'SDK Manager' 를 받아 실행하고,"
  say "       가민 계정으로 로그인한 뒤 최신 SDK 를 내려받아 주세요."
  open "https://developer.garmin.com/connect-iq/sdk/"
  MISSING=1
fi

# 3) 기기 파일 (SDK Manager 의 Devices 탭에서 내려받은 것만 빌드)
READY=""
for D in $DEVICES; do
  if [ -d "$CIQ/Devices/$D" ]; then READY="$READY $D"; else say "[건너뜀] $D — SDK Manager 의 Devices 탭에서 내려받으면 함께 빌드됩니다."; fi
done
if [ -z "$READY" ]; then
  say "[필요] SDK Manager 의 Devices 탭에서 Forerunner 165 / 265 등 기기를 내려받아 주세요."
  MISSING=1
else
  say "[확인] 빌드할 기기:$READY"
fi
case " $READY " in *" $SIMDEV "*) ;; *) SIMDEV="$(echo $READY | cut -d' ' -f1)";; esac

if [ -n "$MISSING" ]; then
  say ""
  say "위 항목을 마친 뒤 이 파일(build.command)을 다시 더블클릭해 주세요."
  say "STATUS: SETUP_NEEDED"
  read -n 1 -s -r -p "아무 키나 누르면 창이 닫힙니다."
  exit 0
fi

# 4) 개발자 키 (앱 서명용. 저장소 밖 홈 폴더에 보관)
if [ ! -f "$KEY" ]; then
  openssl genrsa -out /tmp/mungwatch_key.pem 4096 2>/dev/null \
    && openssl pkcs8 -topk8 -inform PEM -outform DER -in /tmp/mungwatch_key.pem -out "$KEY" -nocrypt \
    && rm -f /tmp/mungwatch_key.pem
  say "[생성] 개발자 키"
fi

mkdir -p bin
sig(){ find source resources manifest.xml monkey.jungle -type f -exec stat -f '%m %N' {} + 2>/dev/null | md5; }

say "[실행] 시뮬레이터를 엽니다."
"$SDK/bin/connectiq" >/dev/null 2>&1 &
sleep 4

LAST=""; DOPID=""
while true; do
  S="$(sig)"
  if [ "$S" != "$LAST" ]; then
    LAST="$S"
    : > "$LOG"
    say "=== 빌드  $(date '+%F %T')  (SDK $(basename "$SDK"), 시뮬레이터 $SIMDEV) ==="
    if "$SDK/bin/monkeyc" -o bin/mungwatch_sim.prg -f monkey.jungle -y "$KEY" -d "${SIMDEV}_sim" -w >> "$LOG" 2>&1; then
      say "STATUS: BUILD_OK"
      [ -n "$DOPID" ] && kill "$DOPID" 2>/dev/null
      "$SDK/bin/monkeydo" bin/mungwatch_sim.prg "$SIMDEV" >> "$LOG" 2>&1 &
      DOPID=$!
      # 기기별 워치용 파일
      for D in $READY; do
        if "$SDK/bin/monkeyc" -o "bin/mungwatch_$D.prg" -f monkey.jungle -y "$KEY" -d "$D" -r -w >> "$LOG" 2>&1; then
          say "워치용 파일 ($D): $(pwd)/bin/mungwatch_$D.prg  ($(du -h "bin/mungwatch_$D.prg" | cut -f1))"
        else
          say "STATUS: DEVICE_BUILD_FAILED ($D)"
        fi
      done
      say "STATUS: DEVICE_BUILD_DONE"
    else
      say "STATUS: BUILD_FAILED"
    fi
    say "(소스가 바뀌면 자동으로 다시 빌드합니다. 멈추려면 이 창을 닫으세요.)"
  fi
  sleep 2
done
