REVISION := $(shell cat REVISION)
REPO     := http://repo.or.cz/tinycc.git

update: META6.json

META6.json: REVISION
	make -C build/win32
	mkdir -p resources/bin
	cp build/win32/libtcc.dll resources/bin
	cp -r build/win32/lib build/win32/include resources
	perl6 gen.p6

REVISION: pull

pull: build
	git -C build pull
	git -C build describe
	if [ "$(REVISION)" != `git -C build describe` ]; \
		then git -C build describe > REVISION; fi

build:
	git clone -b mob --single-branch $(REPO) build

clean:
	rm -rf resources REVISION

realclean: clean
	rm -rf build
