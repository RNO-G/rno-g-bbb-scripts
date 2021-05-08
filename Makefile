
targets := install uninstall 
subdirs := lte uart gpio spi sbc


$(targets): $(subdirs) 
$(subdirs): 
	make -C $@ $(MAKECMDGOALS)

.PHONY: $(targets) $(subdirs) 


