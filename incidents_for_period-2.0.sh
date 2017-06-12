#!/bin/bash
COUNT_DAYS=$2
COUNT_INCIDENTS=$1
IP_SET=(7.88.2.3 28.99.164.215 94.4.0.155 192.168.107.161 9.4.0.66 22.32.12.2 8.8.8.8 194.44.0.145 192.206.151.131 88.199.18.79 37.9.66.80 195.222.64.0)
COUNTRY_ID_SET=(630336 2017370 798544 6251999 690791 6252001  6252001 6252001 2635167 6252001 6252001 6251999)
TIMESTAMP=$(date +%s)
ME=`basename $0`

function create_idncidents_main {
    for d in $(seq ${COUNT_DAYS}); do
        for n in $(seq ${COUNT_INCIDENTS}); do
            sqlite3  /var/imunify360/imunify360.db  " INSERT INTO 'incident' VALUES($(( ( RANDOM % 30000 )  + 30000 )),'ossec','5503',$(($TIMESTAMP - $(($(shuf -i 10000-86400 -n 1) *$d)))),1,5,'User login failed','authentication failure;','${IP_SET[$RANDOM % ${#IP_SET[@]} ]}','${COUNTRY_ID_SET[$RANDOM % ${#COUNTRY_ID_SET[@]} ]}');"     
        done        
    done
    echo Number incidents per day - $COUNT_INCIDENTS;
    echo Number days - $COUNT_DAYS;
    echo SUCCESS! Totaly were created $(($COUNT_DAYS*$COUNT_INCIDENTS)) incidents.
}

function print_help() {
    echo "СПРАВКА:"
    echo "    Для генерации инцидентов выполните скрипт передав через пробел два аргумента:"
    echo "    Аргумент 1 - количество инцидентов, аргумент 2 количество дней."
    echo ПРИМЕР: 
    echo "    ./scriptname.sh 30 2 - (после выполнения получим 60 инцидентов, за два дня по 30 за каждый)"    
}

if [ $# = 0 ]; then
    print_help
else
    if [[ $1 =~ ^-?[0-9]+$ ]] &&  [[ $2 =~ ^-?[0-9]+$ ]]; then
        create_idncidents_main
    else
        echo "ERROR: The parameters should be integers."
        print_help
        exit 1
    fi
fi
