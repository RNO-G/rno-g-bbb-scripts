#! /bin/sh 

if [ ! -d /sys/class/gpio/gpio66 ]; then echo 66 > /sys/class/gpio/export; fi
DURATION=${1:-0.005s} 


echo high > /sys/class/gpio/gpio66/direction
sleep ${DURATION}
echo low > /sys/class/gpio/gpio66/direction
  

