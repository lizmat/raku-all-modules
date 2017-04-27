FROM rakudo-star
MAINTAINER yowcow@cpan.org

RUN set -x && \
    apt-get update && \
    apt-get -yq install gcc g++ libc6-dev make && \
    rm -rf /var/lib/apt/lists/*

RUN zef install \
    LibraryMake \
    NativeCall \
    Test \
    Test::META

WORKDIR /tmp/work

COPY . /tmp/work

RUN cd /tmp/work && perl6 Configure.pl6 && make -C src

CMD perl6 -v
