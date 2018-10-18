DOCKERIMAGE = rakudo-star-digest-murmurhash

all: docker-build

docker-build:
	docker build -t $(DOCKERIMAGE) .

build:
	docker run --rm \
		-v `pwd`:/work \
		$(DOCKERIMAGE) make -f dev.mk all build

test:
	docker run --rm \
		-v `pwd`:/work \
		$(DOCKERIMAGE) make -f dev.mk all test

exec:
	docker run --rm \
		-v `pwd`:/work \
		-it \
		$(DOCKERIMAGE) bash

clean:
	docker rmi $(DOCKERIMAGE)

.PHONY: all docker-build build test exec clean
