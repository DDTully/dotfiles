#!/bin/bash
# reboot-info.sh - Collect logs explaining the current boot on Arch Linux

OUTPUT="reboot_logs_$(date +%Y%m%d_%H%M%S).txt"

echo "=== System Reboot Diagnostic Report ===" | tee -a "$OUTPUT"
echo "Generated on: $(date)" | tee -a "$OUTPUT"
echo "" | tee -a "$OUTPUT"

# 1. Last reboot times
echo "=== Last Reboots (last command) ===" | tee -a "$OUTPUT"
last reboot | head -n 10 | tee -a "$OUTPUT"
echo "" | tee -a "$OUTPUT"

# 2. Systemd-analyze for current boot
echo "=== systemd-analyze (Boot Time) ===" | tee -a "$OUTPUT"
systemd-analyze 2>/dev/null | tee -a "$OUTPUT"
systemd-analyze blame 2>/dev/null | head -n 20 | tee -a "$OUTPUT"
echo "" | tee -a "$OUTPUT"

# 3. Journal logs from current boot
echo "=== Journal Logs from Current Boot ===" | tee -a "$OUTPUT"
journalctl -b -p 3 --no-pager | tee -a "$OUTPUT"
echo "" | tee -a "$OUTPUT"

# 4. Kernel logs from current boot
echo "=== Kernel Messages from Current Boot ===" | tee -a "$OUTPUT"
journalctl -k -b --no-pager | tee -a "$OUTPUT"
echo "" | tee -a "$OUTPUT"

# 5. Hardware/system info
echo "=== Hardware & System Info ===" | tee -a "$OUTPUT"
uname -a | tee -a "$OUTPUT"
lsblk | tee -a "$OUTPUT"
free -h | tee -a "$OUTPUT"
echo "" | tee -a "$OUTPUT"

# 6. Shutdown logs before this boot (still useful context)
echo "=== Shutdown Logs Before Current Boot ===" | tee -a "$OUTPUT"
journalctl -u systemd-logind -b -1 --no-pager | tee -a "$OUTPUT"
journalctl -u systemd-shutdown -b -1 --no-pager | tee -a "$OUTPUT"
echo "" | tee -a "$OUTPUT"

echo "Report saved to: $OUTPUT"
