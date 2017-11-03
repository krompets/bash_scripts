#!/bin/bash
user=$1
sed -i "s/${user}\:\/usr\/local\/cpanel\/bin\/noshell/${user}\:\/bin\/bash/g" /etc/passwd
