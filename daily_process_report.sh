#!/bin/bash

EMAIL="yehiaabdelazim58@gmail.com"
SUBJECT="Daily Processes Report - $(date +'%Y-%m-%d')"
TMP_FILE="/tmp/processes_report.txt"
LOG_FILE="/tmp/mail_log.txt"
STOPPED_FILE="/tmp/stopped_processes.txt"

#Print All Processes
ps -aux > "$TMP_FILE"

#Stopped or problematic processes 
ps -aux | awk '$8 ~ /T|Z/ || $3 > 80 { print }' > "$STOPPED_FILE"


if [ $? -eq 0 ]; then
   {
     echo -e "Subject: $SUBJECT\nTo: $EMAIL\n"
     echo -e "\n----------------------------------------------------------------"
     echo -e "Stopped or problematic processes (state T/Z or high CPU usage ):\n"
     cat "$STOPPED_FILE"
     echo -e "\n----------------------------------------------------------------"
     echo -e "Here is the full proccessed report:\n"
     cat "$TMP_FILE"
   } | msmtp --debug --logfile=$LOG_FILE "$EMAIL"
else
    echo -e "Subject: Process Report Failed - $(date +'%Y-%m-%d')\nTo: $EMAIL\n\nFailed to retrieve processes" | msmtp --debug --logfile="$LOG_FILE" "$EMAIL"
fi

#Remove Files 
rm -f "$TMP_FILE" "$STOPPED_FILE"
