use v6;
BEGIN { @*INC.unshift: 'lib' }

use Test;
use Pod::To::Markdown;
plan 1;

my $markdown = q{module Asdf1
------------

asdf1

### sub asdf

```
sub asdf(
    Str $asdf1, 
    Str :asdf2($asdf2) = { ... }
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
    Str :asdf($asdf) = { ... }
) returns Str
```

Method asdf2};

is pod2markdown($=pod).trim, $markdown.trim,
    'Converts definitions to Markdown correctly';

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


