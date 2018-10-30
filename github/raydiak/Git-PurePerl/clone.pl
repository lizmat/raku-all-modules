#!/usr/bin/env perl6

use lib $?FILE.IO.parent.child: 'lib';
use lib $?FILE.IO.parent.child('blib').child: 'lib';
use Git::PurePerl;

sub MAIN (Str $url!, Str $directory!) {
    die 'Only git:// urls are currently supported' unless $url ~~ /^ 'git://' /;

    my $g = Git::PurePerl.new: :$directory;
    $g.clone: $url;
    $g.checkout;

    True;
}

# vim: ft=perl6
