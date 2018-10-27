# Image::RGBA::Text [![build status][TRAVISIMG]][TRAVIS]

Reads RGBA image data of depth 8 from text files


## Synopsis

```
use Image::RGBA::Text;
use Image::PNG::Inflated;

my $data := RGBAText.decode('examples/glider.txt'.IO);
spurt 'glider.png', to-png |$data.unbox;

spurt "{ .info }.png", to-png |.scale.unbox
    for RGBAText.decode('examples/FEEP.txt'.IO, :all);
```


## Bugs and Development

Development happens [at GitHub][SOURCE]. If you found a bug or have a feature
request, use the [issue tracker][ISSUES] over there.


## Copyright and License

Copyright (C) 2015 by <cygx@cpan.org>

Distributed under the [Boost Software License, Version 1.0][LICENSE]

[TRAVIS]:       https://travis-ci.org/cygx/p6-image-rgba-text
[TRAVISIMG]:    https://travis-ci.org/cygx/p6-image-rgba-text.svg?branch=master
[SOURCE]:       https://github.com/cygx/p6-image-rgba-text
[ISSUES]:       https://github.com/cygx/p6-image-rgba-text/issues
[LICENSE]:      http://www.boost.org/LICENSE_1_0.txt
