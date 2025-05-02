help:
	@echo "make install or uninstall"

rev:
	if [ -f /REV ] ; then \
		ln -f REV_`cat /REV`.91-uart.rules 91-uart.rules; \
	else \
		ln -f REV_F.91-uart.rules 91-uart.rules ; \
	fi

install: rev
	install 91-uart.rules /etc/udev/rules.d
	install controller-console /rno-g/bin
uninstall:
	rm -f /etc/udev/rules.d/91-uart.rules
	rm -f /rno-g/bin/controller-console
