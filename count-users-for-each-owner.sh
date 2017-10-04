#!/bin/bash
cp /etc/trueuserowners /root/list
awk '{print $2}' /root/list|sort -u /root/owners
index=0
while read line; do
    array[$index]="$line"
    index=$(($index+1))
done < /root/owners

for ((a=0; a < ${#array[*]}; a++))
do
    echo "    Reseller ${array[$a]} has: "  $(awk -F":" "/${array[$a]}/{print $1}" /root/list|wc -l) "users"
    echo "|------------------------------------------|"
done
