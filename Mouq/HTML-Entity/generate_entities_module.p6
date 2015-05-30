#!/usr/bin/env perl6
use JSON::Tiny;
my $*OUT = <lib/HTML/Entities.pm6>.IO.open(:w);
my @ent = qx{curl -s https://raw.githubusercontent.com/w3c/html/master/entities.json}\
    .&from-json.list.map: {; .key => .value<codepoints> }
say 'unit module HTML::Entities;';
say 'our %entities =';
for @ent.classify(*.key.substr(0,3)) {
    say qq«  '{.key}' => \{»;
    for .value.classify(*.value).values {
        say '    ', .map({
            qq«'{.key}'=> "\\x[» ~ .value.map(*.base(16)).join(',') ~ q«]",»
        }).join
    }
    say qq«  \},»;
}
