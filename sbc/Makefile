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
	install 91-bbr-congestion-control.conf /etc/sysctl.d 
	sysctl -p 91-bbr-congestion-control.conf 
	-test -f /INTERNAL && install fstab /etc/fstab
	install journald.conf /etc/systemd/ 
	if systemctl --quiet is-enabled systemd-networkd ; then install interfaces /etc/network/ ; fi
	cp ssh-config /home/rno-g/.ssh/config
	chown rno-g:rno-g /home/rno-g/.ssh/config
	chmod 600 /home/rno-g/.ssh/config
	mkdir -p /etc/systemd/resolved.conf.d
	install google-dns.conf /etc/systemd/resolved.conf.d/


uninstall: 
	rm -f /rno-g/bin/bbb-drop-caches
	rm -f /rno-g/bin/update-prog
	rm -f /rno-g/bin/enter-fast-mode
	rm -f /rno-g/bin/enter-power-saving-mode
