PKG     := "lib/$(shell grep '"name"'    ./META6.json | col | cut -f2 | sed 's/[", ]//g' | sed 's/::/\//g').pm6"
VERSION := $(shell grep '"version"' ./META6.json | col | cut -f2 | sed 's/[", ]//g' | sed 's/::/-/g')
NAME    := $(shell grep '"name"'    ./META6.json | col | cut -f2 | sed 's/[", ]//g' | sed 's/::/-/g')
FILE     = $(NAME)-$(VERSION).tar.gz

dist: doc clean
	@echo Building $(FILE)
	@touch $(FILE)
	@tar --warning=no-file-changed              \
			 -czf $(FILE) 													\
			 --transform s/^\./$(NAME)-$(VERSION)/  \
			 --exclude-vcs 										   	  \
			 --exclude=.[^/]* 										 	\
			 --exclude=*.tar.gz                     \
			 .

release: dist
	@read -p "Upload $(FILE) to CPAN? [y/n] " yn; 	\
	case $$yn in 																		\
		y) cpan-upload -d Perl6 $(FILE);; 	          \
		*) echo Cancelled;;  										      \
	esac

doc:
	perl6 --doc=Markdown $(PKG) > README.md

test:
	@zef test -v .

clean:
	rm -f ./$(FILE)
