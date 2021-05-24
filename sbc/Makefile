help: 
	@echo "make install or uninstall"

install: 
	install enter-fast-mode /rno-g/bin
	install enter-power-saving-mode /rno-g/bin
	test -f /INTERNAL && install fstab /etc/fstab

	
uninstall: 
	rm -f /rno-g/bin/enter-fast-mode
	rm -f /rno-g/bin/enter-power-saving-mode
