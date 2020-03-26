#!/bin/sh

CMD=$1
crontab -u "root" -l | grep -v "\"$CMD\"" > /tmp/crontab.tmp

if crontab -u "root" -l | grep -v "\"$CMD\""; then 
    printf '{"ENABLED":true}\n'
else
    printf '{"ENABLED":false}\n'
fi