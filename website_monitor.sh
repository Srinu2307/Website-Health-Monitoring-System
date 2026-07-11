#!/bin/bash

#################################################
# Website Health Monitoring System
#################################################

TARGET="www.google.com"

REPORT="reports/report.txt"
LOG="logs/website.log"

mkdir -p reports
mkdir -p logs

echo "==========================================" > "$REPORT"
echo " Website Health Monitoring Report" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "Generated : $(date)" >> "$REPORT"
echo "" >> "$REPORT"

#################################################
# STEP 1 : INPUT VALIDATION
#################################################

if [ -z "$TARGET" ]
then
    echo "No target provided."
    echo "Usage: bash website_monitor.sh google.com"
    exit 1
fi

#################################################
# STEP 2 : DNS CHECK
#################################################

if host "$TARGET" >/dev/null 2>&1
then
    DNS="Resolved"
else
    DNS="Failed"

    echo "Target : $TARGET" >> "$REPORT"
    echo "DNS : Failed" >> "$REPORT"
    echo "Classification : Invalid Target" >> "$REPORT"

    exit 1
fi

#################################################
# STEP 3 : REACHABILITY
#################################################

if ping -c 3 -W 2 "$TARGET" >/dev/null 2>&1
then

    REACHABLE="YES"

else

    REACHABLE="NO"

    echo "Target : $TARGET" >> "$REPORT"
    echo "Reachable : NO" >> "$REPORT"
    echo "Classification : Inactive Target" >> "$REPORT"

    exit 1

fi

#################################################
# STEP 4 : PORT CHECK
#################################################

timeout 3 bash -c "</dev/tcp/$TARGET/80" >/dev/null 2>&1

if [ $? -eq 0 ]
then
    PORT80="OPEN"
else
    PORT80="CLOSED"
fi

timeout 3 bash -c "</dev/tcp/$TARGET/443" >/dev/null 2>&1

if [ $? -eq 0 ]
then
    PORT443="OPEN"
else
    PORT443="CLOSED"
fi

#################################################
# STEP 5 : HTTP STATUS
#################################################

STATUS=$(curl -L -s -o /dev/null \
-w "%{http_code}" \
"http://$TARGET")

TIME=$(curl -L -o /dev/null \
-s \
-w "%{time_total}" \
"http://$TARGET")

if [ "$STATUS" = "000" ]
then

    echo "Target : $TARGET" >> "$REPORT"
    echo "Reachable : YES" >> "$REPORT"
    echo "HTTP Service : Not Available" >> "$REPORT"

    exit 1

fi

#################################################
# STEP 6 : HTTP CLASSIFICATION
#################################################

if [ "$STATUS" -eq 200 ]
then

    HTTP_RESULT="Healthy Web Service"

elif [ "$STATUS" -eq 301 ] || [ "$STATUS" -eq 302 ]
then

    HTTP_RESULT="Redirecting Web Service"

elif [ "$STATUS" -eq 403 ]
then

    HTTP_RESULT="Forbidden"

elif [ "$STATUS" -eq 404 ]
then

    HTTP_RESULT="Page Not Found"

elif [ "$STATUS" -ge 500 ]
then

    HTTP_RESULT="Server Error"

else

    HTTP_RESULT="Unexpected Response"

fi

#################################################
# STEP 7 : CONTENT INSPECTION
#################################################

COUNT=$(curl -L -s "http://$TARGET" \
| grep -oiE "password|passwd|secret|confidential|login|admin|apikey|token" \
| wc -l)

#################################################
# STEP 8 : RISK CLASSIFICATION
#################################################

if [ "$COUNT" -eq 0 ]
then

    RISK="Public Content"

elif [ "$COUNT" -lt 10 ]
then

    RISK="Moderate Exposure"

else

    RISK="High Exposure"

fi

#################################################
# STEP 9 : REPORT
#################################################

echo "Target              : $TARGET" >> "$REPORT"
echo "DNS                 : $DNS" >> "$REPORT"
echo "Reachable           : $REACHABLE" >> "$REPORT"
echo "Port 80             : $PORT80" >> "$REPORT"
echo "Port 443            : $PORT443" >> "$REPORT"
echo "HTTP Status         : $STATUS" >> "$REPORT"
echo "HTTP Classification : $HTTP_RESULT" >> "$REPORT"
echo "Response Time       : ${TIME}s" >> "$REPORT"
echo "Keyword Matches     : $COUNT" >> "$REPORT"
echo "Risk Level          : $RISK" >> "$REPORT"

#################################################
# STEP 10 : LOG
#################################################

echo "$(date) | $TARGET | $STATUS | ${TIME}s | $RISK" >> "$LOG"

#################################################

cat "$REPORT"

echo ""

echo "Monitoring Completed."

echo "Report : reports/report.txt"

echo "Log    : logs/website.log"