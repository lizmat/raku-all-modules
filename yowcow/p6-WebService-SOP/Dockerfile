FROM rakudo-star
MAINTAINER yowcow@cpan.org

RUN zef install \
    Test \
    Test::META \
    Digest::HMAC \
    HTTP::UserAgent \
    JSON::Fast \
    URI

WORKDIR /tmp/work

COPY . /tmp/work

CMD perl6 -v
