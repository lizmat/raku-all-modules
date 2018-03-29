#!/usr/bin/env perl6

use LibGit2;

say LibGit2.version;
say LibGit2.features;

try my $repo = Git::Repository.init('testing');

if $!
{
    say $!.code;
    exit;
}


say $repo;
