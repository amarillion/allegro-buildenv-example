
# Name of binary
NAME = example

#
# invoke "make BUILD=DEBUG" or "make BUILD=RELEASE"
# 
BUILD=DEBUG
#BUILD=RELEASE
#BUILD=STATIC

# invoke "make WINDOWS=1 to compile for windows"
PLATFORMSUF = 	
ifdef WINDOWS
	PLATFORMSUF = _win
endif

# set TOOLCHAIN to path / prefix where cross-compiler toolchain can be found
# For example: TOOLCHAIN=i686-w64-mingw32-
CC = $(TOOLCHAIN)gcc
WINDRES = $(TOOLCHAIN)windres

CFLAGS = -W -Wall -Wno-unused
LFLAGS = 
LIBS = 

ifeq ($(BUILD),RELEASE)
	CFLAGS += -O3
	LFLAGS += -s
	BUILDDIR = build/release$(PLATFORMSUF)
endif
ifeq ($(BUILD),DEBUG)
	CFLAGS += -g -DDEBUG
	BUILDDIR = build/debug$(PLATFORMSUF)
endif
ifeq ($(BUILD),STATIC)
	CFLAGS += -O3
	LFLAGS += -s
	BUILDDIR = build/static$(PLATFORMSUF)
endif

OBJDIR=$(BUILDDIR)/obj

ALLEGRO_MODULES=allegro allegro_image
ifeq ($(BUILD),RELEASE)
	ALLEGRO_LIBS = $(addsuffix -5, $(ALLEGRO_MODULES))
	LIBS += `pkg-config --libs $(ALLEGRO_LIBS)`
endif
ifeq ($(BUILD),DEBUG)
	ALLEGRO_LIBS = $(addsuffix -debug-5, $(ALLEGRO_MODULES))
	LIBS += `pkg-config --libs $(ALLEGRO_LIBS)`
endif
ifeq ($(BUILD),STATIC)
	ALLEGRO_LIBS = $(addsuffix -static-5, $(ALLEGRO_MODULES))
	LIBS += `pkg-config --libs --static $(ALLEGRO_LIBS)`
endif

ifdef WINDOWS
	CFLAGS += -D__GTHREAD_HIDE_WIN32API
	LFLAGS += -Wl,--subsystem,windows
	BINSUF = .exe
	ICONOBJ = $(OBJDIR)/icon.o	
else
	BINSUF =
endif

BIN = $(BUILDDIR)/$(NAME)$(BINSUF)

$(shell mkdir -p $(OBJDIR) >/dev/null)

SRC = $(wildcard *.c)
OBJ = $(patsubst %.c, $(OBJDIR)/%.o, $(SRC))

$(BIN) : $(OBJ) $(ICONOBJ)
	$(CC) -o $(BIN) $^ $(LIBS) $(LFLAGS)
	@echo
	@echo "Build complete. Run $(BIN)"

$(OBJDIR)/%.o : %.c
	$(CC) $(CFLAGS) -o $@ -c $<

$(ICONOBJ) : icon.rc icon.ico
	$(WINDRES) -I rc -O coff -i icon.rc -o $(ICONOBJ)

.PHONY: clean
clean:
	-$(RM) $(OBJDIR)/*.o

.PHONY:distclean
distclean: clean
	-$(RM) $(BIN)

.PHONY: all
all: $(BIN)
