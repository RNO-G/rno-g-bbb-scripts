echo "4819c000.i2c" > /sys/bus/platform/drivers/omap_i2c/unbind
sleep 1
echo "4819c000.i2c" > /sys/bus/platform/drivers/omap_i2c/bind
