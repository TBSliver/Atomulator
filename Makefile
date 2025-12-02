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

SRCDIR = src
OBJDIR = obj

ifeq ($(OS),windows)
	VPATH = $(SRCDIR) $(SRCDIR)/resid-fp $(SRCDIR)/AtoMMC
	CPP  = g++.exe
    CC   = gcc.exe
    WINDRES = windres.exe
    CFLAGS = -O3 -ffast-math -fomit-frame-pointer -falign-loops -falign-jumps -falign-functions
    # -ggdb -march=i686
    OBJ = 6502.o 6522via.o 8255.o 8271.o 1770.o atom.o config.o csw.o ddnoise.o debugger.o disc.o fdi.o fdi2raw.o soundopenal.o ssd.o uef.o video.o avi.o win.o win-keydefine.o resid.o atom.res atommc.o
    SIDOBJ = convolve-sse.o convolve.o envelope.o extfilt.o filter.o pot.o sid.o voice.o wave6581__ST.o wave6581_P_T.o wave6581_PS_.o wave6581_PST.o wave8580__ST.o wave8580_P_T.o wave8580_PS_.o wave8580_PST.o wave.o
    MMCOBJ = atmmc2core.o atmmc2wfn.o ff_emu.o ff_emudir.o wildcard.o

    DEFS = 	-DINCLUDE_SDDOS
    LIBS =  -mwindows -lalleg -lz -lalut -lopenal32 -lwinmm -lstdc++ -static -static-libgcc -static-libstdc++

    TARGET_BIN = Atomulator.exe
else ifeq ($(OS),linux)
	VPATH = $(SRCDIR) $(SRCDIR)/resid-fp $(SRCDIR)/atommc
	CPP  = g++
    CC   = gcc
    WINDRES =
    CFLAGS = -O3 -ffast-math -fomit-frame-pointer -falign-loops -falign-jumps -falign-functions -DINCLUDE_SDDOS
    # -march=i686 -ggdb
    OBJ = 6502.o 6522via.o 8255.o 8271.o atom.o config.o csw.o ddnoise.o debugger.o disc.o fdi.o fdi2raw.o soundopenal.o ssd.o uef.o video.o avi.o linux.o linux-keydefine.o linux-gui.o resid.o 1770.o atommc.o
    SIDOBJ = convolve-sse.o convolve.o envelope.o extfilt.o filter.o pot.o sid.o voice.o wave6581__ST.o wave6581_P_T.o wave6581_PS_.o wave6581_PST.o wave8580__ST.o wave8580_P_T.o wave8580_PS_.o wave8580_PST.o wave.o
    MMCOBJ = atmmc2core.o atmmc2wfn.o ff_emu.o ff_emudir.o wildcard.o

    DEFS =
    LIBS =  -lalleg -lz -lalut -lopenal -lstdc++ -L/usr/local/lib -lm

    TARGET_BIN = Atomulator
else
	$(error Should not happen)
endif

FULLOBJ = $(foreach objname, $(OBJ), $(OBJDIR)/$(objname))
FULLSIDOBJ = $(foreach objname, $(SIDOBJ), $(OBJDIR)/resid-fp/$(objname))
FULLMMCOBJ = $(foreach objname, $(MMCOBJ), $(OBJDIR)/atommc/$(objname))

help:
	@echo Available targets: all, clean
	@echo See $(MAKEFILE_TARGET) in src for more targets

$(TARGET_BIN) : $(FULLOBJ) $(FULLSIDOBJ) $(FULLMMCOBJ)
	$(CC) $^ -o $(TARGET_BIN) $(LIBS)

all : $(OBJDIR) $(TARGET_BIN)

clean :
	$(RM) $(OBJDIR)/*.o
	$(RM) $(OBJDIR)/atommc/*.o
	$(RM) $(OBJDIR)/resid-fp/*.o

$(OBJDIR)/%.o : $(SRCDIR)/%.c
	$(CC) $(CFLAGS) $(DEFS) -c $< -o $@

$(OBJDIR)/%.o : $(SRCDIR)/%.cc
	$(CC) $(CFLAGS) $(DEFS) -c $< -o $@

$(OBJDIR)/atommc/%.o : $(SRCDIR)/atommc/%.c
	$(CC) $(CFLAGS) $(DEFS) -c $< -o $@

$(OBJDIR)/atommc/%.o : $(SRCDIR)/atommc/%.cc
	$(CC) $(CFLAGS) $(DEFS) -c $< -o $@

$(OBJDIR)/resid-fp/%.o : $(SRCDIR)/resid-fp/%.c
	$(CC) $(CFLAGS) $(DEFS) -c $< -o $@

$(OBJDIR)/resid-fp/%.o : $(SRCDIR)/resid-fp/%.cc
	$(CC) $(CFLAGS) $(DEFS) -c $< -o $@

atom.res: src/atom.rc
	$(WINDRES) -i atom.rc --input-format=rc -o atom.res -O coff

$(OBJDIR) :
	mkdir -p $(OBJDIR)
	mkdir -p $(OBJDIR)/resid-fp
	mkdir -p $(OBJDIR)/atommc
