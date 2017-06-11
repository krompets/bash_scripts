#!/bin/bash

COUNT_USERS=5
USERS_LIST=""
USER_PASSWORD="IfinthXtvgbjy1"
IP_ADRESS=$(ifconfig | grep inet | grep -v inet6 | grep -v 127.0.0.1 | cut -d: -f2 | awk '{printf $1"\n"}')
STRESS_COMMAND="stress --cpu 1 --io 1 --vm 1 --vm-bytes 128M --timeout 30s -d 1"
MYSQLSLAP_COMMAND="mysqlslap  time mysqluser2_db --host=localhost --concurrency=20 --iterations=100 --auto-generate-sql --number-char-cols=50  --number-int-cols=100"

function install_packs_plesk {
    local panel=$(cldetect --detect-cp | grep -i "plesk")
    local stress=$(rpm -qa stress | grep -i "stress")
    if [ ${panel} ]; then
        local governor=$(rpm -q governor-mysql|grep -i  "governor-mysql-")
        if [ ! ${governor} ]; then
            local password=$(cat /etc/psa/.psa.shadow)
            yum -y install governor-mysql
            printf 'y' | /usr/share/lve/dbgovernor/mysqlgovernor.py --install
            echo "Governor is installed"
            sed -i 's/^<connector.*.\/>/<connector prefix_separator="_" login="admin" password="'$password'" \/>/g'  /etc/container/mysql-governor.xml
            service db_governor restart
        fi
    fi
    if [ ! ${stress} ]; then
        yum -y install stress
        echo "Stress is installed"
    fi
}

function create_users {
    local user="user"
    for n in $(seq ${COUNT_USERS}); do
        local username="${user}${n}"
        username=$(echo ${username})
        echo ${username}
        #  add user
        /usr/local/psa/bin/customer --create ${username} -name "${username}" -passwd ${USER_PASSWORD}
        /usr/local/psa/bin/domain -c ${username}.com -owner ${username} -service-plan "Default Domain" -ip ${IP_ADRESS} -login ${username} -passwd "${USER_PASSWORD}"
        USERS_LIST=("${USERS_LIST[@]}" "${username}")
    done

}

function load_user {
    sed -i 's/com:\/bin\/false/com:\/bin\/bash/g' /etc/passwd
    for n in $(seq ${COUNT_USERS}); do
        echo "Run stress test under user ${USERS_LIST[$n]}"
        su - "${USERS_LIST[$n]}" -c "${STRESS_COMMAND}"
        echo "Run mysqlslap test under user ${USERS_LIST[$n]}"
        MYSQL_PWD=`cat /etc/psa/.psa.shadow` mysql -u admin  -e "grant all on mysqlslap.* to "${USERS_LIST[$n]}"@"localhost";"
        ${MYSQLSLAP_COMMAND}  --user=${USERS_LIST[$n]} &  su - "${USERS_LIST[$n]}" -c "${STRESS_COMMAND}"
    done
}

function remove_users {
    for n in $(seq ${COUNT_USERS}); do
        echo ${USERS_LIST[$n]}
        /usr/local/psa/bin/customer --remove ${USERS_LIST[$n]}
        /usr/local/psa/bin/subscription --remove ${USERS_LIST[$n]}
        rm -rf /home/${USERS_LIST[$n]} /var/spool/mail/${USERS_LIST[$n]}
    done
}

install_packs_plesk;
create_users;
load_user;
#remove_users;
