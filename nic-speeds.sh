#!/bin/bash

ip2nic() {
    ip addr show | grep "inet $1" -m1 | awk '{print $NF}'
}
pp=${1:-`pgrep aria2 | head -1`}
cat /proc/$pp/cmdline | xargs -0 echo
socks=( `netstat -tnap 2>/dev/null | grep "ESTABLISHED\s*$pp" | tr -s ' ' | cut -d ' ' -f 4` )
for s in ${socks[@]}; do
    ip=${s%:*}
    port=${s##*:}
    nic=`ip2nic $ip`
    name="$nic:$port"
    sudo tcpdump -i $nic -Q in -w - tcp port $port 2>/dev/null | pv -N "`printf "%-15s" $name`" -c > /dev/null &
done

wait
