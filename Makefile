
targets := install uninstall 
subdirs := lte


$(targets): $(subdirs) 
$(subdirs): 
	make -C $@ $(MAKECMDGOALS)

.PHONY: $(targets) $(subdirs) 


