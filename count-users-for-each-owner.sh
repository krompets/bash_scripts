#!/bin/bash
rm -r -f /tmp/list-res
awk '{print $2}' /etc/trueuserowners|sort -u >> /tmp/list-res
index=0
while read line; do
    array[$index]="$line"
    index=$(($index+1))
done < /tmp/list-res

for ((a=0; a < ${#array[*]}; a++))
do
    echo "    Reseller ${array[$a]} has: "  $(awk -F":" "/${array[$a]}/{print $1}" /root/list|wc -l) "users"
    echo "|------------------------------------------|"
done
