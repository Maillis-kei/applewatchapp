#!/bin/bash
# Forerunner 265 시뮬레이터로 멍워치 띄우기 (Mac 에서 더블클릭)
# 다른 기기로 보려면 터미널에서:  ./sim_fr265.command fr265s
cd "$(dirname "$0")" || exit 1
DEV="${1:-fr265}"
LOG="sim_log.txt"
CIQ="$HOME/Library/Application Support/Garmin/ConnectIQ"
KEY="$HOME/.mungwatch_garmin_key.der"
SDK=""; [ -f "$CIQ/current-sdk.cfg" ] && SDK="$(cat "$CIQ/current-sdk.cfg")"; SDK="${SDK%/}"
[ -e "$SDK/bin/monkeyc" ] || { SDK="$(ls -d "$CIQ"/Sdks/*/ 2>/dev/null | sort | tail -1)"; SDK="${SDK%/}"; }
: > "$LOG"
echo "=== $DEV 시뮬레이터  $(date '+%F %T') ===" | tee -a "$LOG"
mkdir -p bin
pgrep -f "ConnectIQ.app" >/dev/null || { "$SDK/bin/connectiq" >/dev/null 2>&1 & sleep 4; }
if "$SDK/bin/monkeyc" -o "bin/mungwatch_sim_$DEV.prg" -f monkey.jungle -y "$KEY" -d "${DEV}_sim" -w >> "$LOG" 2>&1; then
  echo "STATUS: SIM_BUILD_OK" | tee -a "$LOG"
  "$SDK/bin/monkeydo" "bin/mungwatch_sim_$DEV.prg" "$DEV" >> "$LOG" 2>&1 &
  sleep 8
  echo "STATUS: SIM_STARTED" | tee -a "$LOG"
else
  echo "STATUS: SIM_BUILD_FAILED" | tee -a "$LOG"
fi
echo "(이 창은 닫아도 됩니다.)"
