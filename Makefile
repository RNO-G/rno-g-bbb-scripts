
targets := install uninstall 
subdirs := lte uart gpio spi sbc i2c


$(targets): $(subdirs) 
$(subdirs): 
	make -C $@ $(MAKECMDGOALS)

.PHONY: $(targets) $(subdirs) 


