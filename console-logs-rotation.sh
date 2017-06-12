#!/bin/bash

filesize=$(stat -c "%s" /var/log/imunify360/console.log)
constant=10485760
iteration=$(($(($constant-$filesize))/100))
string="INFO [2017-06-09 03:35:57,318] peewee_migrate: Done 008_fill_countries test test test..........test"
echo before
ls -l /var/log/imunify360|grep console.log
for n in $(seq ${iteration}); do
   echo $string  >> /var/log/imunify360/console.log
done
service imunify360-sensor restart
echo after
ls -l /var/log/imunify360|grep console.log

