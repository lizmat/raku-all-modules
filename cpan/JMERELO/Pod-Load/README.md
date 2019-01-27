[![Build Status](https://travis-ci.com/JJ/p6-pod-load.svg?branch=master)](https://travis-ci.com/JJ/p6-pod-load)

NAME
====

Pod::Load - Loads and compiles the Pod documentation of an external file

SYNOPSIS
========

    use Pod::Load;

    # Read a file handle.
    my $pod = load("file-with.pod6".IO);
    say $pod.perl; # Process it as a Pod

    # Or use simply the file name
    my @pod = load("file-with.pod6");
    say .perl for @pod;

    my $string-with-pod = q:to/EOH/;

This ordinary paragraph introduces a code block:

EOH

say load( $string-with-pod ).perl;

You can also reconfigure the global variables. However, if you change one you'll have to change the whole thing. In the future, I might come up with a better way of doing this...

$Pod::Load::tmp-dir= "/tmp/my-precomp-dir/"; $Pod::Load::precomp-store = CompUnit::PrecompilationStore::File.new(prefix => $Pod::Load::tmp-dir.IO); $Pod::Load::precomp = CompUnit::PrecompilationRepository::Default.new(store => $Pod::Load::precomp-store);

DESCRIPTION
===========

Pod::Load is a module with a simple task: obtain the documentation of an external file in a standard, straighworward way. Its mechanism is inspired by [`Pod::To::BigPage`](https://github.com/perl6/perl6-pod-to-bigpage), from where the code to use the cache is taken from.

AUTHOR
======

JJ Merelo <jjmerelo@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

### multi sub load

```perl6
multi sub load(
    Str $string
) returns Mu
```

Loads a string, returns a Pod.

### multi sub load

```perl6
multi sub load(
    Str $file where { ... }
) returns Mu
```

If it's an actual filename, loads a file and returns the pod

### multi sub load

```perl6
multi sub load(
    IO::Path $io
) returns Mu
```

Loads a IO::Path, returns a Pod. Taken from pod2onepage

