#!/bin/bash

COUNT_DAYS=$1
TIMESTAMP=$(date +%s)
DB_TYPE=$(sed -n '/^db_type.*=/s///p' /etc/sysconfig/lvestats2)
SERVER_ID=$(sed -n '/^server_id.*=/s///p'  /etc/sysconfig/lvestats2)
sqlite3 /var/lve/lvestats2.db "select DISTINCT id from lve_stats2_history" >> /tmp/list
array=()
echo $DB_TYPE
echo $SERVER_ID

function read_array(){
i=0
while read line; do
    array[$i]="$line"
    i=$(($i+1))
done <  /tmp/list
}

function generate_stats (){
for ((a=0; a < ${#array[*]}; a++))
do
    for n in  {1..100}; do
        sqlite3 /var/lve/lvestats2.db "INSERT INTO 'lve_stats2_history' VALUES (${array[$a]},1954,10000,0,0,20,489,1048576,0,15435,0,0,0,$(($TIMESTAMP - $(($(shuf -i 10000-86400 -n 1) *$d)))),'$SERVER_ID',262144,10151,0,100,4,0,1024,9,0);"
    done
done
}

function clean_stats(){
rm -f /tmp/list
}

function main (){
    read_array
    clean_stats
    
    for d in $(seq ${COUNT_DAYS}); do
        generate_stats
    done
}

function print_help() {
    echo "СПРАВКА:"
    echo "    Выполните скрипт передав период в днях"
    echo "    ./scriptname.sh 30 - (создастся статистика за 30 дней)"
}



if [ $# = 0 ]; then
    print_help
else
    if [[ $1 =~ ^-?[0-9]+$ ]]; then
        main >> /dev/zero
    else
        echo "ERROR: The parameters should be integers."
        print_help
        exit 1
    fi
fi

