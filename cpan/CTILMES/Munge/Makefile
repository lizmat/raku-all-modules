NAME := $(shell jq -r .name META6.json)
VERSION := $(shell jq -r .version META6.json)
ARCHIVENAME := $(subst ::,-,$(NAME))

PM := $(shell find lib -name '*.pm6')

HTML := $(addsuffix .html, $(subst lib,html,$(PM)))

check: html test
	git diff-index --check HEAD

test:
	prove6

html/%.html: lib/%
	mkdir -p $(dir $@)
	perl6 --doc=HTML $< > $@

html: $(HTML)

tag:
	git tag $(VERSION)
	git push origin --tags

dist:
	git archive --prefix=$(ARCHIVENAME)-$(VERSION)/ \
		-o ../$(ARCHIVENAME)-$(VERSION).tar.gz $(VERSION)
