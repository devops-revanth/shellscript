#!/bin/bash

Packages=("nginx" "redis" "vsftpd" "git" )

for i in "${Packages[@]}" ; do
    if ! rpm -qa | grep -qw "$i" ; then
        echo "$i is not installed installing now ..."
        sudo yum install $i -y &> /dev/null
        if [ $? -eq 0 ]; then
            echo "$i installed successfully ..."
        else
            echo "Failed to install $i"
            continue
        fi
    else echo "$i package is already installed"
    fi

    services=$(rpm -ql $i 2> /dev/null | grep -E "/(usr/lib|etc)/systemd/system/${i}\.service$" | sort -u | xargs -r -n1 basename | sed 's/\.service//')
    if [ -z "$services" ]; then
        echo "No service found for $i - skipping service management"
        continue
    fi

    for svc in $services ; do 

        if ! systemctl is-active --quiet "$svc" ; then
            echo "$svc is not running , restarting now"
            systemctl restart "$svc"
            if [ $? -eq 0 ]; then
                echo "$svc restarted successfully"
            else
                echo "Failed to restart $svc"
            fi
        else
            echo "$svc is already running , no need to restart"
        fi
    done
done