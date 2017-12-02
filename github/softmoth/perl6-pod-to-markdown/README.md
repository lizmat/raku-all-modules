# Pod::To::Markdown (Perl6)

[![Build Status](https://travis-ci.org/softmoth/perl6-pod-to-markdown.svg?branch=master)](https://travis-ci.org/softmoth/perl6-pod-to-markdo
wn)

## Installation

Using zef
```
$ zef update
$ zef install Pod::To::Markdown
```

NAME
====

Pod::To::Markdown - Render Pod as Markdown

SYNOPSIS
========

From command line:

    $ perl6 --doc=Markdown lib/to/class.pm

From Perl6:

```perl6
use Pod::To::Markdown;

=NAME
foobar.pl

=SYNOPSIS
    foobar.pl <options> files ...

say pod2markdown($=pod);
```

To render without fenced codeblocks ```` ``` ````, as some markdown engines don't support this, use the :no-fenced-codeblocks option. If you want to have code show up as ```` ```perl6```` to enable syntax highlighting on certain markdown renderers, use: `=begin code :lang<perl6>`

EXPORTS
=======

    class Pod::To::Markdown;
    sub pod2markdown; # See below

DESCRIPTION
===========



### sub pod2markdown

```
sub pod2markdown(
    Pod::Heading $pod,
    Bool :$no-fenced-codeblocks
) returns Mu
```

Render Pod as Markdown
