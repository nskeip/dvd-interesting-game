PROJECT_NAME		  ?= dvd_interesting_game

RAYLIB_PATH           ?= ../raylib
RAYLIB_RELEASE_PATH   ?= $(RAYLIB_PATH)/src

# Locations of raylib.h and libraylib.a/libraylib.so
# NOTE: Those variables are only used for PLATFORM_OS: LINUX, BSD
RAYLIB_INCLUDE_PATH   ?= /usr/local/include
RAYLIB_LIB_PATH       ?= /usr/local/lib

# Library type compilation: STATIC (.a) or SHARED (.so/.dll)
RAYLIB_LIBTYPE        ?= SHARED

# Build mode for project: DEBUG or RELEASE
BUILD_MODE            ?= RELEASE

BUILD_WEB_HEAP_SIZE   ?= 134217728

CFLAGS = -std=c99 -Wall -Wno-missing-braces -Wunused-result -D_DEFAULT_SOURCE

ifeq ($(BUILD_MODE),DEBUG)
    CFLAGS += -g -D_DEBUG
else
    CFLAGS += -s -O2
endif

# No uname.exe on MinGW!, but OS=Windows_NT on Windows!
# ifeq ($(UNAME),Msys) -> Windows
ifeq ($(OS),Windows_NT)
    PLATFORM_OS = WINDOWS
else
    UNAMEOS = $(shell uname)
    ifeq ($(UNAMEOS),Linux)
        PLATFORM_OS = LINUX
    endif
    ifeq ($(UNAMEOS),FreeBSD)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),OpenBSD)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),NetBSD)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),DragonFly)
        PLATFORM_OS = BSD
    endif
    ifeq ($(UNAMEOS),Darwin)
        PLATFORM_OS = OSX
    endif
endif

# Additional flags for compiler (if desired)
#CFLAGS += -Wextra -Wmissing-prototypes -Wstrict-prototypes
ifeq ($(PLATFORM_OS),LINUX)
	ifeq ($(RAYLIB_LIBTYPE),STATIC)
       CFLAGS += -D_DEFAULT_SOURCE
	endif
	ifeq ($(RAYLIB_LIBTYPE),SHARED)
        # Explicitly enable runtime link to libraylib.so
        CFLAGS += -Wl,-rpath,$(RAYLIB_RELEASE_PATH)
	endif
endif

INCLUDE_PATHS = -I. -I$(RAYLIB_PATH)/src -I$(RAYLIB_PATH)/src/external -I$(RAYLIB_PATH)/src/extras -I$(RAYLIB_INCLUDE_PATH)

# Define library paths containing required libs: LDFLAGS
#------------------------------------------------------------------------------------------------
LDFLAGS = -L.

ifeq ($(PLATFORM_OS),WINDOWS)
    # NOTE: The resource .rc file contains windows executable icon and properties
    LDFLAGS += $(RAYLIB_PATH)/src/raylib.rc.data
    # -Wl,--subsystem,windows hides the console window
    ifeq ($(BUILD_MODE), RELEASE)
        LDFLAGS += -Wl,--subsystem,windows
    endif
endif
ifeq ($(PLATFORM_OS),LINUX)
    LDFLAGS += -L$(RAYLIB_LIB_PATH)
endif
ifeq ($(PLATFORM_OS),BSD)
    LDFLAGS += -Lsrc -L$(RAYLIB_LIB_PATH)
endif

# Define libraries required on linking: LDLIBS
# NOTE: To link libraries (lib<name>.so or lib<name>.a), use -l<name>
#------------------------------------------------------------------------------------------------
ifeq ($(PLATFORM_OS),WINDOWS)
    # Libraries for Windows desktop compilation
    # NOTE: WinMM library required to set high-res timer resolution
    LDLIBS = -lraylib -lopengl32 -lgdi32 -lwinmm
    # Required for physac examples
    LDLIBS += -static -lpthread
endif
ifeq ($(PLATFORM_OS),LINUX)
    # Libraries for Debian GNU/Linux desktop compiling
    # NOTE: Required packages: libegl1-mesa-dev
    LDLIBS = -lraylib -lGL -lm -lpthread -ldl -lrt

    # On X11 requires also below libraries
    LDLIBS += -lX11
    # NOTE: It seems additional libraries are not required any more, latest GLFW just dlopen them
    #LDLIBS += -lXrandr -lXinerama -lXi -lXxf86vm -lXcursor

    # On Wayland windowing system, additional libraries requires
    ifeq ($(USE_WAYLAND_DISPLAY),TRUE)
        LDLIBS += -lwayland-client -lwayland-cursor -lwayland-egl -lxkbcommon
    endif
    # Explicit link to libc
    ifeq ($(RAYLIB_LIBTYPE),SHARED)
        LDLIBS += -lc
    endif
endif
ifeq ($(PLATFORM_OS),OSX)
    # Libraries for OSX 10.9 desktop compiling
    # NOTE: Required packages: libopenal-dev libegl1-mesa-dev
    LDLIBS = -lraylib -framework OpenGL -framework Cocoa -framework IOKit -framework CoreAudio -framework CoreVideo
endif
ifeq ($(PLATFORM_OS),BSD)
    # Libraries for FreeBSD, OpenBSD, NetBSD, DragonFly desktop compiling
    # NOTE: Required packages: mesa-libs
    LDLIBS = -lraylib -lGL -lpthread -lm

    # On XWindow requires also below libraries
    LDLIBS += -lX11 -lXrandr -lXinerama -lXi -lXxf86vm -lXcursor
endif

# Define source code object files required
#------------------------------------------------------------------------------------------------
PROJECT_SOURCE_FILES ?= main.c

build/desktop:
	mkdir -p $@

build/desktop/dvd_interesting_game: build/desktop $(PROJECT_SOURCE_FILES)
	$(CC) -o $@ $(PROJECT_SOURCE_FILES) $(CFLAGS) $(INCLUDE_PATHS) $(LDFLAGS) $(LDLIBS) -DPLATFORM_DESKTOP

build/web:
	mkdir -p $@

build/web/dvd.html: build/web $(PROJECT_SOURCE_FILES)
	emcc -o $@ $(PROJECT_SOURCE_FILES) -Os -Wall $(RAYLIB_RELEASE_PATH)/libraylib.a $(INCLUDE_PATHS) \
		-L. -L$(RAYLIB_RELEASE_PATH) -L$(RAYLIB_PATH)/src \
		-s USE_GLFW=3 -s TOTAL_MEMORY=$(BUILD_WEB_HEAP_SIZE) \
		-s FORCE_FILESYSTEM=1 \
		--preload-file ./resources --shell-file shell.html \
		-DPLATFORM_WEB -DSCREEN_WIDTH=568 -DSCREEN_HEIGHT=320

all:
	make build/desktop/dvd_interesting_game
	make build/web/dvd.html

clean:
	rm -rf build/

rebuild:
	make clean && make all

.PHONY: all clean rebuild
