#!/usr/bin/env bash
# Toggle clamshell mode (keep Mac awake with lid closed).
# Usage: clamshell.sh [on|off|status]
#   on  = prevent sleep on lid close
#   off = restore normal sleep on lid close
#   status = show current state
set -euo pipefail

ACTION="${1:-status}"

case "$ACTION" in
  on)
    sudo pmset -a disablesleep 1
    echo "✅ Clamshell mode ON — Mac will stay awake with lid closed"
    echo "⚠️  Remember to turn this off when you're done (battery drain!)"
    ;;
  off)
    sudo pmset -a disablesleep 0
    echo "✅ Clamshell mode OFF — Mac will sleep normally when lid closes"
    ;;
  status)
    VAL=$(pmset -g | grep -i disablesleep 2>/dev/null || echo "not set")
    if echo "$VAL" | grep -q "1"; then
      echo "🟢 Clamshell mode is ON (sleep disabled)"
    else
      echo "🔴 Clamshell mode is OFF (normal sleep behavior)"
    fi
    ;;
  *)
    echo "Usage: clamshell.sh [on|off|status]"
    exit 1
    ;;
esac
