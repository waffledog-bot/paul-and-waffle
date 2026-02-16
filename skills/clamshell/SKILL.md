---
name: clamshell
description: Toggle clamshell mode on Mac — keep the laptop awake with the lid closed (no external monitor needed). Use when asked to enable/disable clamshell mode, prevent sleep on lid close, or keep the Mac running with lid shut.
---

# Clamshell Mode

Keep a MacBook awake with the lid closed, even without an external monitor or keyboard.

## Usage

```bash
bash scripts/clamshell.sh on      # prevent sleep on lid close
bash scripts/clamshell.sh off     # restore normal sleep
bash scripts/clamshell.sh status  # check current state
```

**Requires sudo** — will prompt for password. Use `elevated: true` on exec if available.

## Important

- **Turn it off when done!** The Mac won't sleep at all with the lid closed, which drains battery fast.
- This uses `pmset -a disablesleep` which is the official Apple power management tool.
- Works on macOS Tahoe (26.x) and earlier.
- No external display or keyboard required.
