FROM rakudo-star
MAINTAINER yowcow@cpan.org

RUN zef install Test Test::META

WORKDIR /tmp/work

COPY . /tmp/work

CMD perl6 -v
