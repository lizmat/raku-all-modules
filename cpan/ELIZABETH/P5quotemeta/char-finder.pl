#!/usr/bin/env perl

use 5.020;
use Number::Range;
use Data::Dumper;

my $r = Number::Range->new;

for ( 0 .. 0xFFFFF ) {
    next if chr eq quotemeta chr;
    $r->addrange($_);
}

print "<[\n";
for ( $r->rangeList ) {
    my ( $s, $e ) = @$_;
    unless ( defined $e ) {
        say "    \\x[" . sprintf('%x', $s) . "]";
        next;
    }

    say "    \\x[" . sprintf('%x', $s) . "]..\\x[" . sprintf('%x', $e) . "]";
}
print "]>\n";
