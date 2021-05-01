
targets := install uninstall 
subdirs := lte uart gpio


$(targets): $(subdirs) 
$(subdirs): 
	make -C $@ $(MAKECMDGOALS)

.PHONY: $(targets) $(subdirs) 


