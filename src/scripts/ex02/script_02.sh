	#!/bin/bash
	#sudo apt -install net-tool
	#sudo apt install bc

HOSTNAME="HOSTNAME = $(echo $HOSTNAME)"
TIMEZONE="TIMEZONE = UTC $(date +"%z")"
USER="USER =  $(whoami)"
OS="OS = $(cat /etc/os-release | head -1 | cut -c14-140 | sed 's/\"//g')"
DATE="DATE = $(date | awk '{print $3 " " $2  " " $7  " "  $4}')"
tmp=$(printf "%.0f" $(cat /proc/uptime | awk '{print $1}'))
UPTIME="UPTIME = $(($tmp / 3600))[hour]  $(($tmp % 3600 / 60))[min] $(($tmp % 60))[sec]"
UPTIME_SEC="UPTIME_SEC = $tmp"
IP="IP = $(echo $(hostname -I) | awk '{print $2}')"
MASK="MASK = $(ifconfig | grep "mask" | head -1 | awk '{print $ 4}')"
GATEWAY="GATEWAY = $(ip route | grep "default" | awk '{print $3}')"
total=$(cat /proc/meminfo | head -1 | awk '{print $2}')
RAM_TOTAL="RAM TOTAL= $(bc <<< "scale=3; $total / 1000000") GB"
free=$(cat /proc/meminfo | sed -n '2p' | awk '{print $2}')
RAM_USED="RAM USED = $(bc <<< "scale=3; $(($total - $free)) / 1000000") GB" #?
RAM_FREE="RAM_FREE = $(bc <<< "scale=3; $free / 1000000") GB" #?
SPACE_ROOT="SPACE_ROOT = $(bc <<< "scale=2; $(df . | awk '{print $2}' | sed -n '2p') / 1000") MB"
SPACE_ROOT_USED="SPACE_ROOT_USED = $(bc <<< "scale=2; $(df . | awk '{print $3}' | sed -n '2p') / 1000") MB"
SPACE_ROOT_FREE="SPACE_ROOT_FREE = $(bc <<< "scale=2; $(df . | awk '{print $4}' | sed -n '2p') / 1000") MB"

output="$HOSTNAME\n$TIMEZONE\n$USER\n$OS\n$DATE\n$UPTIME\n\
$UPTIME_SEC\n$IP\n$MASK\n$GATEWAY\n$RAM_TOTAL\n$RAM_USED\n$RAM_FREE\n\
$SPACE_ROOT\n$SPACE_ROOT_USED\n$SPACE_ROOT_FREE"

echo -e $output

echo "Do you want to output it to file? Y/N"
read is_write
if [ $is_write = "Y" ]; then
tmp=$(date "+%d_%m_%y_%H_%M_%S")
touch $tmp; echo -e $output > $tmp
elif [ $is_write = "N" ]; then
exit
else
echo "Error: incorrect input"
fi


