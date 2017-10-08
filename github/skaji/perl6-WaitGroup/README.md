[![Build Status](https://travis-ci.org/skaji/perl6-WaitGroup.svg?branch=master)](https://travis-ci.org/skaji/perl6-WaitGroup)

NAME
====

WaitGroup - sys.WaitGroup in perl6

SYNOPSIS
========

```perl6
use WaitGroup;
use HTTP::Tinyish;

my $wg = WaitGroup.new;

my @url = <
    http://www.golang.org/
    http://www.google.com/
    http://www.somestupidname.com/
>;

for @url -> $url {
    $wg.add(1);
    start {
        LEAVE $wg.done;
        my $res = HTTP::Tinyish.new.get($url, :bin);
        note "-> {$res<status>}, $url";
    };
}

$wg.wait;
```

DESCRIPTION
===========

WaitGroup waits for a collection of promises to finish like sys.WaitGroup in golang.

SEE ALSO
========

[https://golang.org/pkg/sync/#WaitGroup](https://golang.org/pkg/sync/#WaitGroup)

AUTHOR
======

Shoichi Kaji <skaji@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
