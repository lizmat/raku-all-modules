PROG = ../bin/create-md.p6
MFIL = ../lib/Text/More.pm6
TDIR = ../docs
BDIR = ../bin

#DEBUG =
DEBUG = -D

create: subs2
#create: subs
#create: progs
#create: subs progs

subs:
	$(PROG) -m $(MFIL) -d $(TDIR) $(DEBUG)

subs2:
	$(PROG) -m $(MFIL) -d $(TDIR) $(DEBUG) > t.log

progs:
	$(PROG) -b $(BDIR) -d $(TDIR) $(DEBUG)
