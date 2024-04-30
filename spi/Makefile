help: 
	@echo "make install or make uninstall" 

install: 
	install -m 644 spidev.conf /etc/modprobe.d/
	update-initramfs -u $(UPDATE_INITRAMFS_ARGS)
	@echo To make this take effect immediately, rmmod spidev and modprobe spidev; 
