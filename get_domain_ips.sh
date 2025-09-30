#!/usr/bin/env bash

# Provider          Primary         Secondary
# Google 	        8.8.8.8 	    8.8.4.4
# Control D 	    76.76.2.0 	    76.76.10.0
# Quad9 	        9.9.9.9 	    149.112.112.112
# OpenDNS Home 	    208.67.222.222 	208.67.220.220
# Cloudflare 	    1.1.1.1 	    1.0.0.1
# AdGuard DNS 	    94.140.14.14 	94.140.15.15
# CleanBrowsing 	185.228.168.9 	185.228.169.9

dns=(8.8.8.8 76.76.2.0 9.9.9.9 208.67.222.222 1.1.1.1 94.140.14.14 185.228.168.9 8.8.4.4 76.76.10.0 149.112.112.112 208.67.220.220 1.0.0.1 94.140.15.15 185.228.169.9)
len=${#dns[*]}
((len-=1))
try=100

read -p "Enter domain: " domain
read -p "Enter try count [$try]: " res
[ -n "$res" ] && try=$res

for i in $(seq 1 $try); do
    let persent=(${i}*100/${try}*100)/100
    echo -ne "Progress: $persent%\r"
    rnd_dns=$(shuf -i 0-$len -n 1)
    [ $i -eq 1 ] && dig @${dns[$rnd_dns]} +short $domain > ips.list
    [ $i -gt 1 ] && dig @${dns[$rnd_dns]} +short $domain >> ips.list
    sleep 0.2
done
echo -ne '                                                           \r\n'

sort -u ips.list > tmp.list
mv -f tmp.list ips.list

# list=""

# for ip in $(cat ips.list); do
#     list+=$(echo -e "$ip/32\n")
#     # [ ! -z "$list" ] && list+=", $ip/32"
#     # [ -z "$list" ] && list="$ip/32"
# done

# echo $list
cat ips.list

rm -f ips.list

exit $?
