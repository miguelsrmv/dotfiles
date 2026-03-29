#!/bin/sh
# ── Usage ────────────────────────────────────────────────
# Monitor only:        ./syswatch.sh
# Stress + monitor:   ./syswatch.sh --stress
# Custom duration:    ./syswatch.sh --stress --duration 600
# Custom interval:    ./syswatch.sh --interval 2

# ── Defaults ─────────────────────────────────────────────
STRESS=0
DURATION=300      # seconds (used only with --stress)
INTERVAL=1        # seconds between samples
WORKERS=$(nproc)  # CPU threads (used only with --stress)

# ── Argument parsing ─────────────────────────────────────
while [ $# -gt 0 ]; do
    case "$1" in
        --stress)             STRESS=1 ;;
        --duration) shift;    DURATION="$1" ;;
        --interval) shift;    INTERVAL="$1" ;;
        --workers)  shift;    WORKERS="$1" ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--stress] [--duration SECS] [--interval SECS] [--workers N]"
            exit 1
            ;;
    esac
    shift
done

# ── Dependency checks ─────────────────────────────────────
if ! command -v sensors >/dev/null 2>&1; then
    echo "Missing: sensors — install with: sudo apt install lm-sensors && sudo sensors-detect"
    exit 1
fi

if [ "$STRESS" -eq 1 ] && ! command -v stress-ng >/dev/null 2>&1; then
    echo "Missing: stress-ng — install with: sudo apt install stress-ng"
    exit 1
fi

# ── Setup ─────────────────────────────────────────────────
LOG=~/syswatch_log_$(date +%Y%m%d_%H%M%S).txt
STRESS_PID=""

# ── Cleanup on exit ───────────────────────────────────────
cleanup() {
    [ -n "$STRESS_PID" ] && kill "$STRESS_PID" 2>/dev/null
    echo ""
    echo "Stopped. Log saved to $LOG"
    exit 0
}
trap cleanup INT TERM

# ── Launch stressor (optional) ────────────────────────────
if [ "$STRESS" -eq 1 ]; then
    echo "Stress mode: ${WORKERS} CPU workers, ${DURATION}s duration, 80% RAM"
    stress-ng --cpu "$WORKERS" --vm 2 --vm-bytes 80% \
              --timeout "${DURATION}" --metrics-brief &
    STRESS_PID=$!
    END=$(( $(date +%s) + DURATION ))
else
    echo "Monitor mode: running until Ctrl+C"
fi

echo "Logging to $LOG"
echo ""

# ── Monitor loop ──────────────────────────────────────────
while true; do
    # Stop automatically when stress duration expires
    if [ "$STRESS" -eq 1 ] && [ "$(date +%s)" -ge "$END" ]; then
        break
    fi

    TS=$(date +%T)

    # CPU frequency (avg across all cores, MHz)
    CPU_MHZ=$(awk '/cpu MHz/{sum+=$4;n++} END{printf "%.0f",sum/n}' /proc/cpuinfo)

    # Memory usage (used / total, MB)
    MEM=$(free -m | awk '/^Mem/{printf "%d/%dMB", $3, $2}')

    # Battery capacity (gracefully absent on desktops)
    BAT=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    BAT="${BAT:-N/A}%"

    # Thermal zones
    TEMPS=$(for z in /sys/class/thermal/thermal_zone*/; do
        printf "%s=%.1fC " "$(cat "$z/type")" "$(awk '{print $1/1000}' "$z/temp")"
    done)

    # Fan speed (first fan reported by lm-sensors)
    FAN=$(sensors 2>/dev/null | awk '/fan/{print $2" RPM"; exit}')
    FAN="${FAN:-N/A}"

    echo "$TS cpu=${CPU_MHZ}MHz mem=$MEM bat=$BAT fan=$FAN $TEMPS" | tee -a "$LOG"

    sleep "$INTERVAL"
done

wait "$STRESS_PID" 2>/dev/null
echo ""
echo "Done. Results saved to $LOG"
