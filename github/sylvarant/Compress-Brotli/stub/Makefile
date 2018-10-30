#########################################
#     Custom MakeFile                   #
# By Adriaan Larmuseau                  #
#########################################


#============================================
# Platform specific settings
#============================================
all:

uname_S = $(shell sh -c 'uname -s 2>/dev/null || echo not')

ifeq ($(uname_S),Darwin)
 	DEF_TARGET = darwin	
	NAME_LIB = -install_name
	LD = clang
	CC = clang
else #
ifeq ($(uname_S),Linux)
	LD = g++	
	CC = g++
endif
	DEF_TARGET = linux # also works for FreeBSD
	NAME_LIB = -soname
endif

#============================================
# Linkable Targets
#============================================

DESTINATION = ../lib/
LIBN = libperl6brotli
LIBDY = $(DESTINATION)$(LIBN).dylib
LIBSO = $(DESTINATION)$(LIBN).so
LIBA = $(LIBSO).1
LIBB = $(LIBSO).1.0.1 

#============================================
# Flags
#============================================

CFLAGS = -Wall -std=gnu++11 -lstdc++ 
DEPENDS = -L./libbrotli/lib/  -lbrotlienc -lbrotlidec 

#============================================
# Compilation sources
#============================================

# compile all c files in buildsrc
SOURCE=$(wildcard *.cpp)
OBJECTS= $(SOURCE:.cpp=.o) 

#============================================
# Compiling Objects
#============================================

%.o: %.cpp
	$(CC) $(CFLAGS) -I./libbrotli/include/ -c -o $@ $<	#TODO parameterize includes

#============================================
# Linking
#============================================

darwin: $(OBJECTS)
	$(CC) $(DEPENDS) -dynamiclib -undefined suppress -flat_namespace $^ -o $(LIBDY)
	#ln -sf ./libperl6brotli.dylib $(DESTINATION)$(LIBN)

linux: CFLAGS += -fPIC
linux: $(OBJECTS)
	$(CC) -lstdc++ -shared -Wl,$(NAME_LIB),$(LIBA) -o $(LIBB) $^  ./libbrotli/lib/libbrotlienc.a ./libbrotli/lib/libbrotlidec.a
	ln -sf  $(LIBB) $(LIBSO)
	ln -sf  $(LIBB) $(LIBA)

#============================================
# Fetch the required dependencies
#============================================
setup:
	./fetch

#============================================
# Results
#============================================

all: setup $(DEF_TARGET)

install:
	

#============================================
# Helpers
#============================================

clean:
	$(RM) $(OBJECTS) $(OBJECTS) $(LIBDY) $(LIBB) $(LIBSO) $(LIBA)
	$(RM) -rf libbrotli



