#! /bin/sh

if [ ! -d /sys/class/gpio/gpio47 ]; then echo 47 > /sys/class/gpio/export; fi

echo low > /sys/class/gpio/gpio47/direction

