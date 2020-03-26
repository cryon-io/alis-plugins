#!/bin/sh

CMD=$1
MINUTE=${2:-"*"}
HOUR=${3:-"*"}
DAY_OF_MONTH=${4:-"*"}
MONTH=${5:-"*"}
DAY_OF_WEEK=${6:-"*"}
USER=${7:-"root"}

crontab -u "root" -l | grep -v "\"$CMD\"" > /tmp/crontab.tmp

c=$(tail -c 1 /tmp/crontab.tmp)
EOL=""
if [ "$c" != "" ]; then 
    EOL="\n"; 
fi
printf "%s%s %s %s %s %s \"%s\"\n" \
"$EOL" "$MINUTE" "$HOUR" "$DAY_OF_MONTH" "$MONTH" "$DAY_OF_WEEK" "$CMD" > /tmp/crontab.tmp
crontab -u "$USER" "/tmp/crontab.tmp" 