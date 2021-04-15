all: 
	@echo "make install or make uninstall" 

install: 
	install setup-lte /rno-g/bin
	install is-lte-up /rno-g/bin
	install rno-g-lted.py /rno-g/bin/rno-g-lted
	install rno-g-lte-trigger /rno-g/bin
	install lte-keep-alive /rno-g/bin
	install 90-lte.rules /etc/udev/rules.d 
	install lte-keep-alive.service /etc/systemd/system/ 
	install rno-g-lted.service /etc/systemd/system/ 
	systemctl daemon-reload
	systemctl disable lte-keep-alive.service # vestigial 
	systemctl enable rno-g-lted.service
	

uninstall: 
	rm -f /rno-g/bin/setup-lte
	rm -f /rno-g/bin/is-lte-up
	rm -f /rno-g/bin/lte-keep-alive
	rm -f /rno-g/bin/rno-g-lte-trigger
	rm -f /rno-g/bin/rno-g-lted 
	rm -f /etc/udev/rules.d/90-lte.rules 
	systemctl disable lte-keep-alive.service
	systemctl disable rno-g-lted.service
	rm -f /etc/systemd/system/lte-keep-alive.service
	rm -f /etc/systemd/system/rno-g-lted.service
	systemctl daemon-reload
