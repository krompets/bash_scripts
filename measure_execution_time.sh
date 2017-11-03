#!/usr/bin/env bash 
LOG_FILE="./speed_test.log" 
rm -f $LOG_FILE
test_commands=(
	"lvectl sync-map"
	"lvectl list"
	"lvectl list-reseller"
	"lvectl paneluserslimits"
	"lvectl package-list"
	"lvectl all-package-list"
	"lvectl reseller-package-list"
	"cloudlinux-limits get --json"
	"cloudlinux-packages get --json" )
run() {
	echo "Run \"$@\"" #| tee -a $LOG_FILE
	echo "------"
	for i in {1..3}; do
		# time "$@" >> $LOG_FILE
		time "$@" > /dev/null
	done
	echo -e "\n"
}
drop_caches() {
	echo -e "Drop caches...\n"
	sync && echo 3 > /proc/sys/vm/drop_caches
}
echo '==== Starting tests ===='
echo "Packages: $(rpm -q lve-utils)"
echo "There are $(ls /var/cpanel/users/ | wc -l) users on the server" 
echo "There are $(ls /var/cpanel/packages/ | wc -l) packages on the server"
echo $(date) 
for i in "${test_commands[@]}"; do
	drop_caches
	run $i 
done 
echo $(date)
echo '==== Stop tests ===='
