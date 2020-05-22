
install: 
	install setup-lte /rno-g/bin
	install is-lte-up /rno-g/bin
	install setup-lte.service /usr/lib/systemd/system/ 
	systemctl daemon-reload
	install 90-lte.rules /etc/udev/rules.d 
	

uninstall: 
	rm -f /rno-g/bin/setup-lte
	rm -f /rno-g/bin/is-lte-up
	rm -f /usr/lib/systemd/system/setup-lte.service
	rm -f /etc/udev/rules.d/90-lte.rules 
	systemctl daemon-reload 
