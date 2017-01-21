#
# Make file for GTK::Scintilla
#
# Written by Ahmad M. Zawawi <ahmad.zawawi@gmail.com>
#
# This makefile is based on the bait example by Neil Hodgson 
# <neilh@scintilla.org> which was released to the public domain in 2000.
#

INCLUDEDIRS=-Iscintilla/include
CXXFLAGS= -DGTK -DSCI_LEXER -W -Wall
LEXEROBJS=$(wildcard scintilla/gtk/Lex*.o)
GTK_CFLAGS=`pkg-config --cflags gtk+-3.0`
GTK_LDFLAGS=`pkg-config --libs gtk+-3.0 gthread-2.0 gobject-2.0 gmodule-no-export-2.0` -lm -lstdc++
LIB_SO=libwidget.so
LIB_SCINTILLA=scintilla/bin/scintilla.a

all: clean $(LIB_SO)
	mkdir ../resources
	cp $(LIB_SO) ../resources/$(LIB_SO)

widget.o: widget.c
	gcc $(GTK_CFLAGS) $(INCLUDEDIRS) $(CXXFLAGS) -c $^ -fpic -o $@

$(LIB_SCINTILLA):
	(cd scintilla/gtk && GTK3=1 $(MAKE))

$(LIB_SO): widget.o $(LEXEROBJS) $(LIB_SCINTILLA)
	gcc --shared -DGTK $^ -o $@ $(GTK_LDFLAGS)

clean:
	rm -f *.o
	rm -rf ../resources
	(cd scintilla/gtk && GTK3=1 $(MAKE) clean)
