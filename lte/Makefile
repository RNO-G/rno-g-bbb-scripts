
install: 
	install setup-lte /rno-g/bin
	install is-lte-up /rno-g/bin
	install lte-keep-alive /rno-g/bin
	install 90-lte.rules /etc/udev/rules.d 
	install lte-keep-alive.service /etc/systemd/system/ 
	systemctl daemon-reload
	systemctl enable lte-keep-alive.service
	

uninstall: 
	rm -f /rno-g/bin/setup-lte
	rm -f /rno-g/bin/is-lte-up
	rm -f /rno-g/bin/lte-keep-alive
	rm -f /etc/udev/rules.d/90-lte.rules 
	systemctl disable lte-keep-alive.service
	rm -f /etc/systemd/system/lte-keep-alive.service
