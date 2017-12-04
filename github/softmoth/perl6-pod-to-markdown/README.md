NAME
====

Pod::To::Markdown - Render Pod as Markdown

[![Build Status](https://travis-ci.org/softmoth/perl6-pod-to-markdown.svg?branch=master)](https://travis-ci.org/softmoth/perl6-pod-to-markdown)

SYNOPSIS
========

From command line:

    $ perl6 --doc=Markdown lib/To/Class.pm

From Perl6:

```perl6
use Pod::To::Markdown;

=NAME
foobar.pl

=SYNOPSIS
    foobar.pl <options> files ...

say pod2markdown($=pod);
```

EXPORTS
=======

    class Pod::To::Markdown
    sub pod2markdown

DESCRIPTION
===========



### sub pod2markdown

```
sub pod2markdown(
    $pod,
    Str :$positional-separator = "\n\n",
    Bool :$no-fenced-codeblocks
) returns Str
```

Render Pod as Markdown

To render without fenced codeblocks (```` ``` ````), as some markdown engines don't support this, use the :no-fenced-codeblocks option. If you want to have code show up as ```` ```perl6```` to enable syntax highlighting on certain markdown renderers, use:

    =begin code :lang<perl6>

LICENSE
=======

This is free software; you can redistribute it and/or modify it under the terms of the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).
