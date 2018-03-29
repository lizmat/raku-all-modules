#!/usr/bin/env perl6

use LibGit2;


my $g = Git::Repository.clone('https://github.com/CurtTilmes/perl6-epoll.git', '/tmp/mine');

say $g;
