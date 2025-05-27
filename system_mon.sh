#!/bin/bash

# System Monitoring Script
# Check CPU, Memory, Disk, Load, and Network status and send alerts.

### Configuration
EMAIL="admin@example.com"
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=90
LOAD_THRESHOLD=5
NET_INTERFACE="eth0"

### Check CPU usage
cpu_usage=$(top -bn1 | grep '%Cpu(s)' | awk '{print 100 - $8}')
cpu_usage=${cpu_usage%.*}

if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
    echo "High CPU Usage: $cpu_usage%" | mail -s "CPU Alert" $EMAIL
fi

### Check Memory usage
mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
mem_usage=${mem_usage%.*}

if [ "$mem_usage" -gt "$MEMORY_THRESHOLD" ]; then
    echo "High Memory Usage: $mem_usage%" | mail -s "Memory Alert" $EMAIL
fi

### Check Disk usage
disk_usage=$(df -h / | grep '/' | awk '{print $5}' | sed 's/%//')

if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
    echo "High Disk Usage: $disk_usage%" | mail -s "Disk Alert" $EMAIL
fi

### Check Load Average
load_avg=$(cat /proc/loadavg | awk '{print $1}')
load_avg_int=${load_avg%.*}

if [ "$load_avg_int" -gt "$LOAD_THRESHOLD" ]; then
    echo "High Load Average: $load_avg" | mail -s "Load Alert" $EMAIL
fi

### Check Network activity
rx_bytes_before=$(cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes)
tx_bytes_before=$(cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes)
sleep 1
rx_bytes_after=$(cat /sys/class/net/$NET_INTERFACE/statistics/rx_bytes)
tx_bytes_after=$(cat /sys/class/net/$NET_INTERFACE/statistics/tx_bytes)

rx_speed=$(( ($rx_bytes_after - $rx_bytes_before) / 1024 ))
tx_speed=$(( ($tx_bytes_after - $tx_bytes_before) / 1024 ))

# Set a threshold for abnormal traffic if needed

# Optional: Log Monitoring
# tail -n 50 /var/log/syslog | grep -i error >> /tmp/recent_errors.log

# Optional: Process Monitoring (top 5 processes by memory)
top_processes=$(ps aux --sort=-%mem | head -n 6)

echo -e "System Monitoring Report:\n\
CPU Usage: $cpu_usage%\n\
Memory Usage: $mem_usage%\n\
Disk Usage: $disk_usage%\n\
Load Average: $load_avg\n\
Network RX Speed: ${rx_speed} KB/s\n\
Network TX Speed: ${tx_speed} KB/s\n\
\nTop Processes by Memory:\n$top_processes\n"
