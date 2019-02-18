
SHELL = /bin/sh

MAIN_MOD=lib/OO/Plugin.pm6
MOD_VER:=$(shell perl6 -Ilib -e 'use OO::Plugin; OO::Plugin.^ver.say')
MOD_NAME_PFX=OO-Plugin
MOD_DISTRO=$(MOD_NAME_PFX)-$(MOD_VER)
MOD_ARCH=$(MOD_DISTRO).tar.gz
META=META6.json
META_BUILDER=./build-tools/gen-META.p6

PROVE_CMD=prove6
PROVE_FLAGS=-l -I ./build-tools/lib
TEST_DIRS=t
PROVE=$(PROVE_CMD) $(PROVE_FLAGS) $(TEST_DIRS)

DIST_FILES:=$(shell git ls-files)

CLEAN_FILES=$(MOD_NAME_PFX)-v*.tar.gz \
			META6.json.out

PRECOMP_DIRS=$(shell find . -type d -name '.precomp')
BK_FILES=$(shell find . -name '*.bk')
CLEAN_DIRS=$(PRECOMP_DIRS) $(BK_FILES) .test-repo

# Doc variables
DOC_DIR=doc
DOCS_DIR=docs
MD_DIR=$(DOCS_DIR)/md
HTML_DIR=$(DOCS_DIR)/html
DOCS_SUBDIRS=$(shell find lib -type d -name '.*' -prune -o -type d -printf '%P\n')
MD_SUBDIRS:=$(addprefix $(MD_DIR)/,$(DOCS_SUBDIRS))
HTML_SUBDIRS:=$(addprefix $(HTML_DIR)/,$(DOCS_SUBDIRS))
PM_SRC=$(shell find lib -name '*.pm6' | xargs grep -l '^=begin')
POD_SRC=$(shell find doc -name '*.pod6' -and -not -name 'README.pod6')
DOC_SRC=$(POD_SRC) $(PM_SRC)
DOC_DEST=$(shell find lib doc \( -name '*.pm6' -o \( -name '*.pod6' -and -not -name 'README.pod6' \) \) | xargs grep -l '^=begin' | sed 's,^[^/]*/,,')

.SUFFXES: .md .pod6

vpath %.pm6 $(dir $(PM_SRC))
vpath %.pod6 $(dir $(POD_SRC))
#vpath %.md $(MD_SUBDIRS)
#vpath %.html $(HTML_SUBDIRS)

.PHONY: all html test author-test release-test is-repo-clean build depends depends-install release meta6_mod meta \
		archive upload clean install doc md html docs_dirs doc_ver_patch version

%.md $(addsuffix /%.md,$(MD_SUBDIRS)):: %.pm6
	@echo "===> Generating" $@ "of" $<
	@perl6 -I lib --doc=Markdown $< >$@

%.md $(addsuffix /%.md,$(MD_SUBDIRS)):: %.pod6
	@echo "===> Generating" $@ "of" $<
	@perl6 -I lib --doc=Markdown $< >$@

%.html $(addsuffix /%.html,$(HTML_SUBDIRS)):: %.pm6
	@echo "===> Generating" $@ "of" $<
	@perl6 -I lib --doc=HTML $< >$@

%.html $(addsuffix /%.html,$(HTML_SUBDIRS)):: %.pod6
	@echo "===> Generating" $@ "of" $<
	@perl6 -I lib --doc=HTML $< >$@

all: release

doc: docs_dirs doc_ver_patch md html

docs_dirs: | $(MD_SUBDIRS) $(HTML_SUBDIRS)

$(MD_SUBDIRS) $(HTML_SUBDIRS):
	@echo "===> mkdir" $@
	@mkdir -p $@

doc_ver_patch:
	@for src in $(DOC_SRC); do ./build-tools/patch-doc.p6 -r $$src; done

md: ./README.md $(addprefix $(MD_DIR)/,$(patsubst %.pod6,%.md,$(patsubst %.pm6,%.md,$(DOC_DEST))))

html: $(addprefix $(HTML_DIR)/,$(patsubst %.pod6,%.html,$(patsubst %.pm6,%.html,$(DOC_DEST))))

test:
	@echo "===> Testing"
	@$(PROVE)

author-test:
	@echo "===> Author testing"
	@AUTHOR_TESTING=1 $(PROVE)

release-test:
	@echo "===> Release testing"
	@RELEASE_TESTING=1 $(PROVE)

is-repo-clean:
	@git diff-index --quiet HEAD || (echo "*ERROR* Repository is not clean, commit your changes first!"; exit 1)

build: depends doc

depends: meta depends-install

depends-install:
	@echo "===> Installing dependencies"
	@zef --deps-only install .

version: doc meta clean
	@git add . && git commit -m 'Minor: version bump'

release: build is-repo-clean release-test archive
	@echo "===> Done releasing"

meta6_mod:
	@zef locate META6 2>&1 >/dev/null || (echo "===> Installing META6"; zef install META6)

meta: meta6_mod $(META)

archive: $(MOD_ARCH)

$(MOD_ARCH): $(DIST_FILES)
	@echo "===> Creating release archive" $(MOD_ARCH)
	@echo "Generating release archive will tag the HEAD with current module version."
	@echo "Consider carefully if this is really what you want!"
	@/bin/sh -c 'read -p "Do you really want to tag? (y/N) " answer; [ $$answer = "Y" -o $$answer = "y" ]'
	@git tag -f $(MOD_VER) HEAD
	@git push -f --tags
	@git archive --prefix="$(MOD_DISTRO)/" -o $(MOD_ARCH) $(MOD_VER)

$(META): $(META_BUILDER) $(MAIN_MOD)
	@echo "===> Generating $(META)"
	@$(META_BUILDER) >$(META).out && cp $(META).out $(META)
	@rm $(META).out

upload: release
	@echo "===> Uploading to CPAN"
	@/bin/sh -c 'read -p "Do you really want to upload to CPAN? (y/N) " answer; [ $$answer = "Y" -o $$answer = "y" ]'
	@cpan-upload -d Perl6 --md5 $(MOD_ARCH)
	@echo "===> Uploaded."

clean:
	@echo "===> Cleaning " $(CLEAN_FILES) $(CLEAN_DIRS)
	@rm -f $(CLEAN_FILES)
	@rm -rf $(CLEAN_DIRS)

install: build
	@echo "===> Installing"
	@zef install .
