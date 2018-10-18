all:
	zef install --/test App::Mi6
	zef install --deps-only --/test .

build:
	mi6 build

test:
	mi6 test

.PHONY: all build test
