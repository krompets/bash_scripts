#!/bin/bash
USER=$1
RESELLER=$2
ID=$(id -u ${USER})
function set_limit() {
    local result=$(cloudlinux-limits set --username ${USER} --json|grep "success")
    if [[ ! ${result} ]]; then
        if [ -z $RESELLER ]; then
            echo "Не указан реселлер"
        else
            cloudlinux-limits set --pmem=1G --speed=19 --io=1024 --iops=10 --maxEntryProcs 10 --nproc 20 --json --username ${USER} --for-reseller ${RESELLER}
        fi
    else
        cloudlinux-limits set --pmem=1G --speed=19 --io=1024 --iops=10 --maxEntryProcs 10 --nproc 20  --json --username ${USER}
    fi
}

function load_user() {
    su -c "stress --cpu 1 --timeout 10s" - ${USER}
    for i in {0..10}; do lve_suwrapper ${ID} /bin/sh -c "sleep 25 &" ; done
    su -c "timeout 40 dd if=/dev/zero of=/dev/zero bs=1024M"  - ${USER}
    su -c "stress -d 4 --timeout 25s" - ${USER}
    su -c "timeout 300 dd if=/dev/zero of=~/testfile bs=512 count=10000 oflag=direct" - ${USER}    
}
set_limit
load_user
