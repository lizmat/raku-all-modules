# Image::PNG::Inflated [![build status][TRAVISIMG]][TRAVIS]

Creates PNG images from raw RGBA data of depth 8, chunking the data into
uncompressed 64k blocks.


## Synopsis

```
use Image::PNG::Inflated;

my $row    = blob8.new(^256 .flatmap: { $_ xx 3, 255 });
my $pixels = [~] $row xx 64;
my $img    = to-png $pixels, 256, 64;
                   # width --^    ^-- height

spurt 'grayscale.png', $img;
```


## Bugs and Development

Development happens [at GitHub][SOURCE]. If you found a bug or have a feature
request, use the [issue tracker][ISSUES] over there.


## Copyright and License

Copyright (C) 2015, 2017 by <cygx@cpan.org>

Distributed under the [Boost Software License, Version 1.0][LICENSE]


[TRAVIS]:       https://travis-ci.org/cygx/p6-image-png-inflated
[TRAVISIMG]:    https://travis-ci.org/cygx/p6-image-png-inflated.svg?branch=master
[SOURCE]:       https://github.com/cygx/p6-image-png-inflated
[ISSUES]:       https://github.com/cygx/p6-image-png-inflated/issues
[LICENSE]:      http://www.boost.org/LICENSE_1_0.txt
