#!/bin/bash
#==============================================================#
#   Description: bench test script                             #
#   Author: Teddysun <i@teddysun.com>                          #
#   Modified by bobo <admin@boboweb.net>                       #
#==============================================================#


get_opsy() {
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
}

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

speed_test() {
    nodeName=$2
    ipaddress=$(ping -c1 -n `awk -F'/' '{print $3}' <<< $1` | awk -F'[()]' '{print $2;exit}') 
    if   [ "${#nodeName}" -lt "8" ]; then
        echo -e -n "\e[33m$2\e[0m\t\t\t\t\e[32m$ipaddress\e[0m\t\t"
    elif [ "${#nodeName}" -lt "13" ]; then
        echo -e -n "\e[33m$2\e[0m\t\t\t\e[32m$ipaddress\e[0m\t\t"
    elif [ "${#nodeName}" -lt "24" ]; then
        echo -e -n "\e[33m$2\e[0m\t\t\e[32m$ipaddress\e[0m\t\t"
    elif [ "${#nodeName}" -ge "24" ]; then
        echo -e -n "\e[33m$2\e[0m\t\e[32m$ipaddress\e[0m\t\t"
    fi
    speedtest=$(wget -4O /dev/null -T300 $1 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}')
    echo -e "\e[31m$speedtest\e[0m"
}

speed_test_v6() {
    ipaddress=$(ping6 -c1 -n `awk -F'/' '{print $3}' <<< $1` | awk -F'[()]' '{print $2;exit}')
    nodeName=$2
    if   [ "${#nodeName}" -lt "8" -a "${#ipaddress}" -eq "13" ]; then
        echo -e -n "\e[33m$2\e[0m\t\t\t\t\e[32m$ipaddress\e[0m\t\t"
    elif [ "${#nodeName}" -lt "13" -a "${#ipaddress}" -eq "13" ]; then
        echo -e -n "\e[33m$2\e[0m\t\t\t\e[32m$ipaddress\e[0m\t\t"
    elif [ "${#nodeName}" -lt "24" -a "${#ipaddress}" -eq "13" ]; then
        echo -e -n "\e[33m$2\e[0m\t\t\e[32m$ipaddress\e[0m\t\t"
    elif [ "${#nodeName}" -lt "24" -a "${#ipaddress}" -gt "13" ]; then
        echo -e -n "\e[33m$2\e[0m\t\t\e[32m$ipaddress\e[0m\t"
    elif [ "${#nodeName}" -ge "24" ]; then
        echo -e -n "\e[33m$2\e[0m\t\e[32m$ipaddress\e[0m\t\e[31m$speedtest\e[0m"
    fi
    speedtest=$(wget -6O /dev/null -T300 $1 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}')
    echo -e "\e[31m$speedtest\e[0m"

}

speed_test_local() {
    wget -q http://sh.bobiji.com/localtest.py
    serverip=$(wget -qO- ifconfig.co)
    (dd if=/dev/zero of=botest bs=10k count=1024 ) 2>&1
    echo "Please download file from http://$serverip:8000/botest."
    python localtest.py &> /dev/null
    localspeed=$(awk '{print 10240/$1}' .localtest)
    echo -e "Your local-to-server speed is \e[32m$localspeed\e[0m KB/S."
}
speed() {
    speed_test 'http://storage.googleapis.com/appengine-sdks/featured/appengine-java-sdk-1.9.32.zip' 'Google'
    speed_test 'http://mirrors.sohu.com/centos/7/os/x86_64/isolinux/initrd.img' 'Sohu'
    speed_test 'http://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/os/GoFlexRescue.zip' 'Tsinghua(Education network)'
}

speed_v6() {
    speed_test_v6 'http://storage.googleapis.com/appengine-sdks/featured/appengine-java-sdk-1.9.32.zip' 'Google'
    speed_test_v6 'http://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/os/GoFlexRescue.zip' 'Tsinghua(Education network)'
}

io_test() {
    (LANG=en_US dd if=/dev/zero of=iotest bs=32k count=3k ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
tram=$( free -m | awk '/Mem/ {print $2}' )
swap=$( free -m | awk '/Swap/ {print $2}' )
up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60;d=$1%60} {printf("%ddays, %d:%d:%d\n",a,b,c,d)}' /proc/uptime )
opsy=$( get_opsy )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
host=$( hostname )
kern=$( uname -r )
ipv6=$( wget -qO- -t1 -T2 ipv6.icanhazip.com )

clear
next
echo "CPU model            : $cname"
echo "Number of cores      : $cores"
echo "CPU frequency        : $freq MHz"
echo "Total amount of ram  : $tram MB"
echo "Total amount of swap : $swap MB"
echo "System uptime        : $up"
echo "OS                   : $opsy"
echo "Arch                 : $arch ($lbit Bit)"
echo "Kernel               : $kern"
next

if  [ -e '/usr/bin/wget' ]; then
    echo -e "Node Name\t\t\tIPv4 address\t\tDownload Speed"
    speed && next
    if [[ "$ipv6" != "" ]]; then
        echo -e "Node Name\t\t\tIPv6 address\t\tDownload Speed"
        speed_v6 && next
    fi
else
    echo "Error: wget command not found. You must be install wget command at first."
    exit 1
fi

io1=$( io_test )
echo "I/O speed : $io1"
next
if [[ $localTest == "Y" ]];then
speed_test_local && next
fi
echo ""

rm -f iotest botest localtest.py .localtest
