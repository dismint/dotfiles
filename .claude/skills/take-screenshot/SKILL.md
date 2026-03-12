---
name: take-screenshot
description: Take a screenshot of the main monitor, with the ability to narrow down to a specific region.
---

COMMAND:
grim -o DP-1 /tmp/screenshot.png

REGION:
grim -g "1440,750 2560x1440" /tmp/screenshot.png

- Always take screenshots of output DP-1, -o and -g are exclusive, 1440,750 is the offset of DP-1 but feel free to change the region size. 2560x1440 is the resolution of the monitor.
- Remember your region selection for future screenshots in case it might be useful.
- If needed, you can take multiple screenshots under /tmp/screenshot1, /tmp/screenshot2, etc.
