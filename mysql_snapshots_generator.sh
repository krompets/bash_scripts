#!/bin/bash
#ВНИМАТЕЛЬНО СКРИПТ РАБОТАЕТ ТОЛЬКО в CPANEL

#имя пользователя (при созданее)
USER_NAME="teddse"

#Чичло запросов
COUNT_ITERATIONS=10

#Имя пользователя базы данных
DB_USER_NAME="${USER_NAME}_db"

#Имя базы данных пользователя
DB_NAME="${USER_NAME}_db"

#Пароль пользователя базы данных
USER_PASS="If[nthXtvgbjy1"

TABLE="mytable"
STRESS_COMMAND="stress --cpu 8 --io 2 --vm 2 --vm-bytes 128M -d 1 --timeout 10s"

function run_main {
        check_license
        install_needed_pkgs
        create_user_with_db
        create_data
        mapping_user        
        load_user
        echo "[DONE]"
        lve-read-snapshot -u ${USER_NAME} &
}

function create_data {
        local db_exist=$(mysql -u ${DB_USER_NAME} -p${USER_PASS} -e "show databases;"|grep ${DB_NAME})
        if [ ${db_exist} ]; then
            echo "DB exist it named ${db_exist}. Creating test data"
            local table_exist=$(mysql -u ${DB_USER_NAME} -p${USER_PASS} -e "use ${DB_NAME}; show tables;"|grep ${TABLE})
            if [ ! ${table_exist} ]; then
                mysql -u ${DB_USER_NAME} -p${USER_PASS} -e "use ${DB_NAME}; create table ${TABLE} (id integer, name varchar(255), profession varchar(255));"
            fi         
            mysql -u ${DB_USER_NAME} -p${USER_PASS} -e "use ${DB_NAME}; show tables; insert into ${TABLE} (id, name, profession) values(1234567890,'lkajhasdjfhgqa','djfâââ'), (123456789,'jujhkhbfâââsdfbnd','djfâfgâ'),(123456789,'jujhkhbfâââsdfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'),(123456789,'jujhksfbnd','djfâfgâ'); select * from mytable;"
        else 
            echo "DATABASE DOES NOT EXIST VERIFY DATAS OR CREATE DB"
        fi
}

function load_user {
    for n in $(seq ${COUNT_ITERATIONS}); do
        
        echo "loading DB"
        su - "${USER_NAME}" -c "${STRESS_COMMAND}" & mysql -u ${DB_USER_NAME} -p${USER_PASS} -e "use ${DB_NAME}; select SLEEP(1), name from ${TABLE} where name like '%â%';"
    done
}

function install_needed_pkgs {
    local result1=$(rpm -qa stress | grep -i "stress")
    local result2=$(rpm -q governor-mysql|grep -i "governor-mysql-")
    if [ ! ${result1} ]; then
        yum -y install stress
        echo "Stress is installed"
    fi 
    if [ ! ${result2} ]; then
        yum -y install governor-mysql
        printf 'y' | /usr/share/lve/dbgovernor/mysqlgovernor.py --install
        echo "Governor is installed"
    fi
    echo "All needed pack installed"
}

function run_stress {
        su - "${USER_NAME}" -c "${STRESS_COMMAND}"
}

function mapping_user {
    local user_id=$(id ${USER_NAME} | cut -d '(' -f1 | cut -d '=' -f2) 
    local is_in_map=$(cat /etc/container/dbuser-map|grep ${DB_USER_NAME})
    if [[ ! ${is_in_map} ]]; then 
        echo ${DB_USER_NAME} ${DB_USER_NAME} ${user_id} >>  /etc/container/dbuser-map
    fi
}

function create_user_with_db {
    cpmod=$(/bin/ls /var/cpanel/template_compiles/usr/local/cpanel/base/frontend/ | head -1)
    echo y | /scripts/wwwacct "${USER_NAME}.com" "${USER_NAME}" "${USER_PASS}" 0 ${cpmod} n n n 10 10 10 10 10 10 y root
    uapi --user=${USER_NAME} Mysql create_database name=${DB_NAME}
    uapi --user=${USER_NAME} Mysql create_user name=${DB_USER_NAME} password=${USER_PASS}
    uapi --user=${USER_NAME} Mysql set_privileges_on_database user=${DB_USER_NAME} database=${DB_NAME} privileges="ALL PRIVILEGES"
}

function check_license {
    local is_license=$(cldetect --check-license|grep OK)
    if [[ ! ${is_license} ]]; then
        echo "System is not activated. Activating system"
        rhnreg_ks --activationkey=36092-c1d8aeac1cbc318265d7364258df19db --force        
        echo "[DONE]"
    else
        echo "System is activated nothing to do"
    fi
}


run_main;
