install-deps:
	zef --depsonly install .

test: install-deps
	zef test .

install:
	zef install .

all: test

push: test
	git push
