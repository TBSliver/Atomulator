# Target OS detection
ifeq ($(OS),Windows_NT) # OS is a preexisting environment variable on Windows
	OS = windows
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Linux)
		OS = linux
	else
    	$(error OS not supported by this Makefile)
	endif
endif

MAKEFILE_TARGET = Makefile
SRC_DIR = src

ifeq ($(OS),linux)
	MAKEFILE_TARGET = Makefile.linux
endif

# Above taken and manipulated from https://github.com/KRMisha/Makefile (MIT)

help:
	@echo Available targets: all, clean
	@echo See $(MAKEFILE_TARGET) in src for more targets

% :
	make -C $(SRC_DIR) -f $(MAKEFILE_TARGET) $@
