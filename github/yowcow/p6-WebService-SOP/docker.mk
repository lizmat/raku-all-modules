DOCKERIMAGE := rakudo-star-webservice-sop

all: build-image

build-image:
	docker build -t $(DOCKERIMAGE) .

build:
	docker run --rm \
		-v `pwd`:/work \
		$(DOCKERIMAGE) make all build

test:
	docker run --rm \
		-v `pwd`:/work \
		$(DOCKERIMAGE) make all test

exec:
	docker run --rm \
		-v `pwd`:/work \
		-it \
		$(DOCKERIMAGE) bash

clean:
	docker rmi $(DOCKERIMAGE)

.PHONY: all build-image build test exec clean
