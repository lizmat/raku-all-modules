#!/usr/bin/env perl6

use lib 'lib';
use RDF::Turtle;

my %*SUB-MAIN-OPTS = :named-anywhere;

sub MAIN($file, Bool :$triples) {
    my $match = parse-turtle($file.IO.slurp);
    if $triples {
        my $trips = $match.made;
        for @$trips -> ($subject, $predicate, $object) {
            say "$subject $predicate $object .";
        }
    } else {
        say $match;
    }
}
