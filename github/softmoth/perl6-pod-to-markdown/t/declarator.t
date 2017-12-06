use v6;

use Test;
use Pod::To::Markdown;
plan 2;

#| asdf1
module Asdf1 {
    #| Sub asdf1
    sub asdf(Str $asdf1, Str :$asdf2? = 'asdf') returns Str {
        return '';
    }
}

#| Asdf2
class Asdf2 does Positional  {
    #| a is public
    has Str $.a = 'public';
    #| b is private
    has Str $!b = 'private';

    #| Method asdf2
    method asdf(Str :$asdf? = 'asdf') returns Str {

    }
}

is pod2markdown($=pod), q:to/EOF/, 'Converts declarators to Markdown correctly';
module Asdf1
------------

asdf1

### sub asdf

```perl6
sub asdf(
    Str $asdf1,
    Str :$asdf2 = "asdf"
) returns Str
```

Sub asdf1

class Asdf2
-----------

Asdf2

### has Str $.a

a is public

### has Str $!b

b is private

### method asdf

```perl6
method asdf(
    Str :$asdf = "asdf"
) returns Str
```

Method asdf2
EOF


is pod2markdown($=pod, :no-fenced-codeblocks), q:to/EOF/, 'Converts declarators to Markdown correctly without fenced codeblocks';
module Asdf1
------------

asdf1

### sub asdf

    sub asdf(
        Str $asdf1,
        Str :$asdf2 = "asdf"
    ) returns Str

Sub asdf1

class Asdf2
-----------

Asdf2

### has Str $.a

a is public

### has Str $!b

b is private

### method asdf

    method asdf(
        Str :$asdf = "asdf"
    ) returns Str

Method asdf2
EOF

# vim:set ft=perl6:
