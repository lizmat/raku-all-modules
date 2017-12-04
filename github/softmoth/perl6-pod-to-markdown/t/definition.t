use v6;
use lib 'lib';

use Test;
use Pod::To::Markdown;
plan 2;

my $markdown = q{module Asdf1
------------

asdf1

### sub asdf

```
sub asdf(
    Str $asdf1,
    Str :$asdf2 = "asdf"
) returns Str
```

Sub asdf1

class Asdf2
-----------

Asdf2

### has Str $.t

t

### method asdf

```
method asdf(
    Str :$asdf = "asdf"
) returns Str
```

Method asdf2};

my $markdown-no-fenced = q{module Asdf1
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

### has Str $.t

t

### method asdf

    method asdf(
        Str :$asdf = "asdf"
    ) returns Str

Method asdf2};

is pod2markdown($=pod).trim, $markdown.trim,
    'Converts definitions to Markdown correctly';

is pod2markdown($=pod, :no-fenced-codeblocks).trim, $markdown-no-fenced.trim,
    'Converts definitions to Markdown correctly without fenced codeblocks';

#| asdf1
module Asdf1 {
    #| Sub asdf1
    sub asdf(Str $asdf1, Str :$asdf2? = 'asdf') returns Str {
        return '';
    }
}

#| Asdf2
class Asdf2 does Positional  {
    #| t
    has Str $.t = 'asdf';

    #| Method asdf2
    method asdf(Str :$asdf? = 'asdf') returns Str {

    }
}
