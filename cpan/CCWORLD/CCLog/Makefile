#
#  Makefile
#
#  Created by CC on 2018/10/12.
#  Copyright 2018 - now youhua deng (deng you hua | CC) <ccworld1000@gmail.com>
#  https://github.com/ccworld1000/CCLog
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#
    

TARGET  := CCLog
CC      := gcc
CFLAG   := -Wall
CFLAG   += -ICCLog/include
INCLUDES:= -I. -ICCLog/include

libName   := libCCLog.so
ShareFlag := -fPIC -shared

dylibName := libCCLog.dylib
dylibFlag := -dynamiclib -current_version 1.0


SRCS    := CCLog/src/ccnormal.c\
CCLog/src/ccwarning.c\
CCLog/src/ccerror.c\
CCLog/src/cctimer.c\
CCLog/src/ccloop.c\
CCLog/src/ccthread.c\
CCLog/src/ccprint.c\
CCLog/src/ccsay.c\
CCLog/src/ccdie.c\
CCLog/src/ccnetwork.c\
CCLog/src/CCLog.c

OBJS    := $(SRCS:.c=.o)

all     : $(OBJS) shell lib dylib resources

.PHONY  :all
	$(CC) $(LDFLAG) -o $(TARGET) $^

%.o:%.c
	$(CC) -c  $(CFLAG) $(CPPFLAG) $< -o $@

clean:
	rm -rf $(SRCS:.c=.o)
	rm -rf CCLog/bin/cc*
	rm -rf CCLog/lib/*.so
	rm -rf CCLog/lib/*.dylib
	rm -rf CCLog/resources/*.so
	rm -rf CCLog/resources/*.dylib

shell: ccnormal\
ccwarning\
ccerror\
cctimer\
ccloop\
ccthread\
ccprint\
ccsay\
ccdie\
ccnetwork

ccnormal: 
	$(CC) -o CCLog/bin/ccnormal CCLog/src/CCLog.o CCLog/src/ccnormal.o

ccwarning: 
	$(CC) -o CCLog/bin/ccwarning CCLog/src/CCLog.o CCLog/src/ccwarning.o

ccerror: 
	$(CC) -o CCLog/bin/ccerror CCLog/src/CCLog.o CCLog/src/ccerror.o

cctimer: 
	$(CC) -o CCLog/bin/cctimer CCLog/src/CCLog.o CCLog/src/cctimer.o

ccloop: 
	$(CC) -o CCLog/bin/ccloop CCLog/src/CCLog.o CCLog/src/ccloop.o

ccthread: 
	$(CC) -o CCLog/bin/ccthread CCLog/src/CCLog.o CCLog/src/ccthread.o

ccprint: 
	$(CC) -o CCLog/bin/ccprint CCLog/src/CCLog.o CCLog/src/ccprint.o

ccsay: 
	$(CC) -o CCLog/bin/ccsay CCLog/src/CCLog.o CCLog/src/ccsay.o

ccdie: 
	$(CC) -o CCLog/bin/ccdie CCLog/src/CCLog.o CCLog/src/ccdie.o

ccnetwork: 
	$(CC) -o CCLog/bin/ccnetwork CCLog/src/CCLog.o CCLog/src/ccnetwork.o

lib:
	$(CC) $(ShareFlag) $(CFLAG) $(CPPFLAG) CCLog/src/CCLog.c -o CCLog/lib/$(libName)
	cp CCLog/lib/*.so CCLog/resources

dylib:
	$(CC) $(dylibFlag) $(CFLAG) $(CPPFLAG) CCLog/src/CCLog.o -o CCLog/lib/$(dylibName)
	cp CCLog/lib/*.dylib CCLog/resources

resources:
	cp CCLog/lib/*.dylib CCLog/resources
	cp CCLog/lib/*.so CCLog/resources

