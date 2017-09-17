#!/bin/bash
rm -f /root/users_list
touch /root/users_list
l=$(grep "^UID_MIN" /etc/login.defs)
awk -F':' -v "limit=${l##UID_MIN}" '{ if ( $3 >= limit ) print $1}' /etc/passwd >> /root/users_list
while [ 1 ]
do
while read LOGIN; do su $LOGIN -s /bin/bash -c "sleep 100 &" ; done < /root/users_list
done
