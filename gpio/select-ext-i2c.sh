#! /bin/sh

if [ ! -d /sys/class/gpio/gpio67 ]; then echo 67 > /sys/class/gpio/export; fi

echo low > /sys/class/gpio/gpio67/direction

