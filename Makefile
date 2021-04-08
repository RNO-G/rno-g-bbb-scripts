
targets := install uninstall 
subdirs := lte uart


$(targets): $(subdirs) 
$(subdirs): 
	make -C $@ $(MAKECMDGOALS)

.PHONY: $(targets) $(subdirs) 


