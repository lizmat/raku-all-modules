#!/usr/bin/env perl6
use lib <./build-tools/lib ./lib>;
use OOPTest;
use Test;

sub MAIN (Str:D $mod-path) {
    install-distro( $mod-path ) or die "failed to install plugin distro from $mod-path";
}
