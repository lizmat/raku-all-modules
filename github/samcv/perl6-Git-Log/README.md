NAME
====

Git::Log

AUTHOR
======

Samantha McVey (samcv) <samantham@posteo.net>

SYNOPSIS
========

Gets the git log as a Perl 6 object

DESCRIPTION
===========

The first argument is the command line args wanted to be passed into `git log`. Optionally you can also get the files changes as well as the number of lines added or deleted.

Returns an array of hashes in the following format: `ID => "df0c229ad6ba293c67724379bcd3d55af6ea47a0", AuthorName => "Author's Name", AuthorEmail => "sample.email@not-a.url" ...` If the option :get-changes is used (off by default) it will also add a 'changes' key in the following format: `changes => { $[ { filename => 'myfile.txt', added => 10, deleted => 5 }, ... ] }`

If there is a field that you need that is not offered, then you can supply an array, :@fields. Format is an array of pairs: `ID => '%H', AuthorName => '%an' ...` you can look for more [here](https://git-scm.com/docs/pretty-formats).

These are the default fields:

```perl6
my @fields-default =
    'ID'           => '%H',
    'AuthorName'   => '%an',
    'AuthorEmail'  => '%ae',
    'AuthorDate'   => '%aI',
    'Subject'      => '%s',
    'Body'         => '%b'
;
```

EXAMPLES
========

```perl6
# Gets the git log for the specified repository, from versions 2018.06 to master
git-log(:path($path.IO), '2018.06..master')
# Gets the git log for the current directory, and does I<not> get the files
# changed in that commit
git-log(:!get-changes)
```

LICENSE
=======

This is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

### sub git-log

```perl6
sub git-log(
    *@args,
    :@fields = { ... },
    IO::Path :$path,
    Bool:D :$get-changes = Bool::False,
    Bool:D :$date-time = Bool::False
) returns Mu
```

git-log's first argument is an array that is passed to C<git log> and optionally you can provide a path so a directory other than the current are used.

