# Pod::To::Markdown (Perl6)

Render Pod as Markdown.

## Installation

Using panda:
```
$ panda update
$ panda install Pod::To::Markdown
```

Using ufo:
```
$ ufo
$ make
$ make test
$ make install
```

## Usage:

From command line:

    $ perl6 --doc=Markdown lib/class.pm

From Perl6:

```
use Pod::To::Markdown;

=NAME
foobar.pl

=SYNOPSIS
    foobar.pl <options> files ...
	
say pod2markdown($=pod);
```
