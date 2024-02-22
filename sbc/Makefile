help: 
	@echo "make install or uninstall"

install: 
	install enter-fast-mode /rno-g/bin
	install enter-power-saving-mode /rno-g/bin
	install 90-increase-freemem.conf /etc/sysctl.d 
	sysctl -p 90-increase-freemem.conf 
	-test -f /INTERNAL && install fstab /etc/fstab
	install journald.conf /etc/systemd/ 
	if [ `cat /REV` = F ] ; then install interfaces /etc/network/ ; fi 

	
uninstall: 
	rm -f /rno-g/bin/enter-fast-mode
	rm -f /rno-g/bin/enter-power-saving-mode
