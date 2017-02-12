#!/usr/bin/make -f

SOURCEDIR = data/source
JSONDIR = data/expected

SOURCEEXT = f90
JSONEXT = json

SOURCEFILES = $(shell find $(SOURCEDIR) -type f -iname '*.$(SOURCEEXT)')

JSONFILES = $(addprefix $(JSONDIR)/,$(notdir $(SOURCEFILES:.$(SOURCEEXT)=.$(JSONEXT))))

PARSER = ./parse-fortran.pl6

.PHONY: expectedfiles
expectedfiles: $(JSONFILES)

$(JSONDIR)/%.$(JSONEXT): $(SOURCEDIR)/%.$(SOURCEEXT)
	perl6 -I../lib $(PARSER) --json --rule=$$(basename $< | perl -pe 's/([^_]+)(?:_.*?)?\.\w+$$/$$1/') < $< > $@
	vim -O $< $@

.PHONY: clean
clean:
	rm -rf $(JSONFILES)
	
