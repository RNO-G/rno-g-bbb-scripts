#! /bin/sh

if [ ! -d /sys/class/gpio/gpio67 ]; then echo 67 > /sys/class/gpio/export; fi

rev=`cat /REV` 
if [ $rev = "F" ] 
then 
echo low > /sys/class/gpio/gpio67/direction
else
echo in > /sys/class/gpio/gpio67/direction
fi

