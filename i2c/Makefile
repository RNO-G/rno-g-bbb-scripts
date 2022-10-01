help: 
	@echo "make install or make uninstall or make wind-adc-helper or make setup or make clean" 

.PHONY: install setup uninstall 

wind-adc-helper: wind-adc-helper.c
	cc -Og -o $@  $< -lm

install: wind-adc-helper setup
	install raw-wind.sh /rno-g/bin
	install wind-adc-helper /rno-g/bin
	install raw-wind-no-helper.sh /rno-g/bin

setup: 
	mkdir -p /data/windmon/raw
	chown rno-g:rno-g  /data/windmon/raw 
	
uninstall: 
	rm -f /rno-g/bin/raw-wind.sh 
	rm -f /rno-g/bin/raw-wind-no-helper.sh 
	rm -f /rno-g/bin/wind-adc-helper

clean: 
	rm -f wind-adc-helper

