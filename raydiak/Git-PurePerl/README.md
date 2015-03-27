# Git::PurePerl

This is a Perl 6 port of Perl 5's Git::PurePerl. It is a very young and largely
untested experiment, extremely slow, and will not work with any but the most
bleeding-edge Rakudos (after Mar 23 2015). Its first goals are basic cloning
and checkouts, which already seem to work for small repos with very little
commit history.

## Synopsis

It can be used to clone a repo over the git protocol, like so:

    my $repo = Git::PurePerl.new: :$directory;
    $repo.clone: 'git://url.to/repo.git';
    $repo.checkout;

or from the command line using the included script:

    ./clone.pl git://url.to/repo.git directory

## Status

Nothing besides clone and checkout has been ported yet.

When cloning, the packfiles are downloaded and indexes are built for them. This
is currently quite slow even for small repos so don't worry if there is no
output for a long time. This step also currently crashes on all but the
smallest repos with only a short commit history.

A few files other than packfiles are generated in a new .git directory if one
does not already exist, but it is not as complete as a normally initialized git
repo, e.g. .git/config doesn't exist.

## Requirements

In spite of the name, both this module and its P5 progenitor rely on a zlib DLL
or .so being available. Luckily, Perl 6's Compress::Zlib downloads a DLL for
Windows when one is not found at install time, and any non-Win system which
runs Rakudo probably already has zlib available, so this module should be as
portable as expected.
