#!/bin/bash

COUNT_USERS=5
USERS_LIST=""
STRESS_COMMAND="stress --cpu 1 --io 1 --vm 1 --vm-bytes 128M --timeout 10s -d 1"
MYSQLSLAP_COMMAND="mysqlslap  time mysqluser2_db --host=localhost --concurrency=20 --iterations=20 --auto-generate-sql --number-char-cols=50 --number-int-cols=100"
USER_PASSWORD="If[nthXtvgbjy1"

function install_needed_pkgs {
    local result1=$(rpm -qa stress | grep -i "stress")
    local result2=$(rpm -q governor-mysql|grep -i  "governor-mysql-")
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


function create_users {
    local user="user"
    for n in $(seq ${COUNT_USERS}); do
        local username="${user}${n}"
        username=$(echo ${username} )
		
        #  add user
        cpmod=$(/bin/ls /var/cpanel/template_compiles/usr/local/cpanel/base/frontend/ | head -1)
        echo y | /scripts/wwwacct "${username}.com" "${username}" "${USER_PASSWORD}" 0 ${cpmod} n n n 0 0 0 0 0 0 y root
        USERS_LIST=("${USERS_LIST[@]}" "${username}")
    done
}

function run_stress {
    for n in $(seq ${COUNT_USERS}); do
        echo "Run stress test under user ${USERS_LIST[$n]}"
        su - "${USERS_LIST[$n]}" -c "${STRESS_COMMAND}"
        echo "Run mysqlslap test under user ${USERS_LIST[$n]}"
        mysql -u root  -e "grant all on mysqlslap.* to "${USERS_LIST[$n]}"@"localhost";"
        ${MYSQLSLAP_COMMAND}  -p${USER_PASSWORD} --user=${USERS_LIST[$n]}
    done
}



function remove_users {
    for n in $(seq ${COUNT_USERS}); do
        /scripts/removeacct "${USERS_LIST[$n]}" --force
        rm -rf /home/${USERS_LIST[$n]} /var/spool/mail/${USERS_LIST[$n]}
    done
}


install_needed_pkgs;
# > /dev/null;
create_users > /dev/null;
#run_stress > $(pwd)/stress.log;
run_stress;
#remove_users > /dev/null;
