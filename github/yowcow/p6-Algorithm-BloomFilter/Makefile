.PHONY: build-docker test shell clean

CONTAINER = rakudo-star-algorithm-bloom-filter

all: build-docker

build-docker: Dockerfile
	docker pull rakudo-star
	docker build -t $(CONTAINER) .

test:
	docker run -it --rm $(CONTAINER) prove -e 'perl6 -Ilib' -r t

shell:
	docker run -it --rm $(CONTAINER) bash

clean:
	-docker rmi $(CONTAINER)
