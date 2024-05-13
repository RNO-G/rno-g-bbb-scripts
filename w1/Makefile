help:
	@echo "make install or make uninstall"

install:
	install setup-w1 /rno-g/bin
	install setup-w1.service /etc/systemd/system
	systemctl daemon-reload
	systemctl enable setup-w1.service

uninstall:
	rm -f /rno-g/bin/setup-w1
	systemctl disable setup-w1.service
	rm -f /etc/systemd/system/setup-w1.service
	systemctl daemon-reload
