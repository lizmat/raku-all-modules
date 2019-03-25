module := Grammar-PrettyErrors
version := $(shell jq -r .version META6.json)

test:
	TEST_AUTHOR=1 prove -e 'perl6 -Ilib' t/*

dist: FORCE
	echo "Making $(version)"
	git archive --prefix=$(module)-$(version)/ -o dist/$(module)-$(version).tar.gz $(version)

clean:
	rm -f dist/*.tar.gz

FORCE:
