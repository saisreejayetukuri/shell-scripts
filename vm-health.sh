#!/bin/bash
TO="your_email@example.com"
HOST=$(hostname)
DATE=$(date)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4}')
RAM=$(free -h)
DISK=$(df -h)

echo "VM Health Report
Hostname:$HOST
Date:$DATE

CPU Usage report
$CPU %

RAM Usage
$RAM

Disk Usage
$DISK" | mail -s "VM Health Report - $HOST" $TO
