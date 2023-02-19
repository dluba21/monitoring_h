#!/bin/bash

#config

filePath="config_file"

WHITE="1"
RED="2"
GREEN="3"
BLUE="4"
PURPLE="5"
BLACK="6"
BROWN="7"
CYAN="8"
defColor="\033[0m"
colorStringArray=("white" "red" "green" "blue" "purple" "black")
isDefaultFlag=(0 0 0 0)

defaultColorArray=("$BLUE" "$WHITE" "$BLACK" "$WHITE")



checkFile()
{
    if [ ! -r $filePath ]; then
    	echo "error: file $filePath doesn't exist or not readable."
    	exit;
    fi
  
    if [[ $(cat $filePath | wc -l) -lt 3 ]]; then
        echo  $(cat $filePath | wc -l)
        echo "error: file contains less than 4 lines"
        exit
    fi
}

chooseColor() #num of line (1-4), default_color
{
    local line;
    local color;

    line=$(cat $filePath | sed -n "${1}p");
    if [[ ! "$line" =~ ([0-9, a-z, A-Z, _]+)=[1-6]{1} ]]; then
        color=${defaultColorArray[$1 - 1]};
    else
        color=$(cat  "config_file" | sed -n "${1}p" | sed 's/=/ /' | awk '{print $2}');
    fi
    echo $color;
}

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
        "7" )     color='\033[33m';;
        "8" )     color='\033[36m';;
    *) color='${defColor}';;
    esac
else
    case $1 in
        "1" )     color='\033[47m';;
        "2" )     color='\033[41m';;
        "3" )     color='\033[42m';;
        "4" )     color='\033[44m';;
        "5" )     color='\033[45m';;
        "6" )     color='\033[40m';;
        "7" )     color='\033[43m';;
        "8" )     color='\033[46m';;
    *) color='${defColor}';;
    esac
fi
echo $color
}

isPrintDefault()
{
    if [[ $1 -eq "1" ]]; then
        echo "default "
    else
        echo ""
    fi
}

#main part
checkFile;

#parsing file
foreKeyColor=$(chooseColor 1);
backKeyColor=$(chooseColor 2);
foreValColor=$(chooseColor 3);
backValColor=$(chooseColor 4);

defColor="\033[0m"


# if [ $foreKeyColor -eq $backKeyColor ] || [ $foreValColor -eq $backValColor ]; then
# echo "Error: background and front colors are similar. Try again."
# exit;
# fi


#setting color
keyColor="$(setColor $foreKeyColor FOREGROUND)$(setColor $backKeyColor BACKGROUND)"
valColor="$(setColor $foreValColor FOREGROUND)$(setColor $backValColor BACKGROUND)"

#show OS params
HOSTNAME="${keyColor}HOSTNAME=${valColor}$(echo $HOSTNAME)${defColor}"
TIMEZONE="${keyColor}TIMEZONE=${valColor}UTC $(date +"%z")${defColor}"
USER="${keyColor}USER=${valColor}$(whoami)${defColor}"
OS="${keyColor}OS=${valColor}$(cat /etc/os-release | head -1 | cut -c14-140 | sed 's/\"//g')${defColor}"
DATE="${keyColor}DATE=${valColor}$(date | awk '{print $3 " " $2  " " $7  " "  $4}')${defColor}"
tmp=$(printf "%.0f" $(cat /proc/uptime | awk '{print $1}'))
UPTIME="${keyColor}UPTIME=${valColor}$(($tmp / 3600))[hour]  $(($tmp % 3600 / 60))[min] $(($tmp % 60))[sec]${defColor}"
UPTIME_SEC="${keyColor}UPTIME_SEC=${valColor} $tmp${defColor}"
IP="${keyColor}IP=${valColor}$(echo $(hostname -I) | awk '{print $2}')${defColor}"
MASK="${keyColor}MASK=${valColor}$(ifconfig | grep "mask" | head -1 | awk '{print $ 4}')${defColor}"
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



#show config of color
for (( i=0; i < 4; ++i ))
do
    line=$(cat $filePath | sed -n "$(( $i + 1 ))p");
    if [[ ! "$line" =~ ([0-9, a-z, A-Z, _]+)=[1-6]{1} ]]; then
        isDefaultFlag[$i]=1;
    fi
done


echo "Column 1 background = $(isPrintDefault ${isDefaultFlag[0]})(${colorStringArray[$backKeyColor - 1]})"
echo "Column 1 font color = $(isPrintDefault ${isDefaultFlag[1]})(${colorStringArray[$foreKeyColor - 1]})"
echo "Column 2 background = $(isPrintDefault ${isDefaultFlag[2]})(${colorStringArray[$backValColor - 1]})"
echo "Column 2 font color = $(isPrintDefault ${isDefaultFlag[3]})(${colorStringArray[$foreValColor - 1]})"
