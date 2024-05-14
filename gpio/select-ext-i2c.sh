#! /bin/sh

if [ ! -d /sys/class/gpio/gpio67 ]; then echo 67 > /sys/class/gpio/export; fi

rev=`cat /REV` 
if [ $rev = "F" ] 
then 
echo high > /sys/class/gpio/gpio67/direction
else  
echo low > /sys/class/gpio/gpio67/direction
fi

