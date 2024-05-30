help: 
	@echo "make install or uninstall"

install: bbb-drop-caches
	install bbb-drop-caches /rno-g/bin 
	install update-prog /rno-g/bin 
	chown nobody /rno-g/bin/bbb-drop-caches
	chmod +s /rno-g/bin/bbb-drop-caches
	install enter-fast-mode /rno-g/bin
	install enter-power-saving-mode /rno-g/bin
	install 90-increase-freemem.conf /etc/sysctl.d 
	sysctl -p 90-increase-freemem.conf 
	-test -f /INTERNAL && install fstab /etc/fstab
	install journald.conf /etc/systemd/ 
	if [ `cat /REV` = F ] ; then install interfaces /etc/network/ ; fi 

	
uninstall: 
	rm -f /rno-g/bin/bbb-drop-caches
	rm -f /rno-g/bin/update-prog
	rm -f /rno-g/bin/enter-fast-mode
	rm -f /rno-g/bin/enter-power-saving-mode
