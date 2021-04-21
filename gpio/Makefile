help: 
	@echo "make install or make uninstall" 

install: 
	install rno-g-export-gpios /rno-g/bin
	install rno-g-export-gpios.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable rno-g-export-gpios.service 
	
uninstall: 
	rm -f /rno-g/bin/rno-g-export-gpios
	systemctl disable rno-g-export-gpios.service
	rm -f /etc/systemd/system/rno-g-export-gpios.service
	systemctl daemon-reload 
