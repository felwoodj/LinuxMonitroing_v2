#!/bin/bash

if [[ -f log.txt ]]; then
rm -f log.txt
fi

chmod +x *.sh

. ./create_files.sh
. ./validator.sh

sudo bash -c "touch /home/ws/01/log.txt"
validator $1 $2 $3 $4 $5 $6
create

if [ $(-dpkg-query -W -f='${Status}' nano 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        sudo bash -c "apt install tree -y"
else
        tree $1 --du --si --dirsirst 2>/dev/null
fi