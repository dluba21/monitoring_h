#!/bin/bash/



setColor() #1- color_num #back?front
{
    local color;
 if [ $2 = "FOREGROUND" ]; then
    case $1 in
        "1" )     color='\033[39m';;
        "2" )     color='\033[31m';;
        "3" )     color='\033[32m';;
        "4" )     color='\033[34m';;
        "5" )     color='\033[35m';;
        "6" )     color='\033[30m';;
    *) color='${defColor}';;
    esac
else
    case $1 in
        "1" )     color='\033[49m';;
        "2" )     color='\033[41m';;
        "3" )     color='\033[42m';;
        "4" )     color='\033[44m';;
        "5" )     color='\033[45m';;
        "6" )     color='\033[40m';;
    *) color='${defColor}';;
    esac
fi
echo $color
}


#main
if [ $# -ne 4 ]; then
echo "Incorrect number of args, need 4."
exit;
fi


if [ $1 -eq $2 ] || [ $3 -eq $4 ]; then
echo "Error: background and front colors are similar. Try again."
exit;
fi
#setting color
keyColor="$(setColor $1 FOREGROUND)$(setColor $2 BACKGROUND)"
valColor="$(setColor $3 FOREGROUND)$(setColor $4 BACKGROUND)"
defColor="\033[0m"

HOSTNAME="${keyColor}HOSTNAME=${valColor}$(echo $HOSTNAME)${defColor}"
TIMEZONE="${keyColor}TIMEZONE=${valColor}UTC $(date +"%z")${defColor}"
USER="${keyColor}USER=${valColor}$(whoami)${defColor}"
OS="${keyColor}OS=${valColor}$(cat /etc/os-release | head -1 | cut -c14-140 | sed 's/\"//g')${defColor}"
DATE="${keyColor}DATE=${valColor}$(date | awk '{print $3 " " $2  " " $7  " "  $4}')${defColor}"
tmp=$(printf "%.0f" $(cat /proc/uptime | awk '{print $1}'))
UPTIME="${keyColor}UPTIME=${valColor}$(($tmp / 3600))[hour]  $(($tmp % 3600 / 60))[min] $(($tmp % 60))[sec]${defColor}"
UPTIME_SEC="${keyColor}UPTIME_SEC=${valColor} $tmp${defColor}"
IP="${keyColor}IP=${valColor}$(echo $(hostname -I) | awk '{print $2}')${defColor}"
MASK="${keyColor}MASK=${valColor}$(ifconfig | grep "mask" | head -1 | awk '{print $4}')${defColor}"
GATEWAY="${keyColor}GATEWAY=${valColor}$(ip route | grep "default" | awk '{print $3}')${defColor}"
total=$(cat /proc/meminfo | head -1 | awk '{print $2}')
RAM_TOTAL="${keyColor}RAM TOTAL=${valColor}$(bc <<< "scale=3; $total / 1000000") GB${defColor}" 
free=$(cat /proc/meminfo | sed -n '2p' | awk '{print $2}')
RAM_USED="${keyColor}RAM USED=${valColor}$(bc <<< "scale=3; $(($total - $free)) / 1000000") GB${defColor}" #?
RAM_FREE="${keyColor}RAM_FREE=${valColor}$(bc <<< "scale=3; $free / 1000000") GB${defColor}" #?
SPACE_ROOT="${keyColor}SPACE_ROOT=${valColor}$(bc <<< "scale=2; $(df . | awk '{print $2}' | sed -n '2p') / 1000") MB${defColor}"
SPACE_ROOT_USED="${keyColor}SPACE_ROOT_USED=${valColor}$(bc <<< "scale=2; $(df . | awk '{print $3}' | sed -n '2p') / 1000") MB${defColor}"
SPACE_ROOT_FREE="${keyColor}SPACE_ROOT_FREE=${valColor}$(bc <<< "scale=2; $(df . | awk '{print $4}' | sed -n '2p') / 1000") MB${defColor}"

output=\
"$HOSTNAME\n\
$TIMEZONE\n\
$USER\n\
$OS\n\
$DATE\n\
$UPTIME\n\
$UPTIME_SEC\n\
$IP\n\
$MASK\n\
$GATEWAY\n\
$RAM_TOTAL\n\
$RAM_USED\n\
$RAM_FREE\n\
$SPACE_ROOT\n\
$SPACE_ROOT_USED\n\
$SPACE_ROOT_FREE"

echo -e $output