#!/usr/bin/env perl6

use lib 'lib';
use Test;
plan 1;

use CSV::Parser;

my $outcome = 1;
my $line    = Buf.new(0x6, 0x10, 0x6, 0x5, 0x11);

my $fh   = open 't/data/binary.csv', :r:bin;
my $parser  = CSV::Parser.new( file_handle => $fh,
                          field_separator => Buf.new(6), 
                          field_operator  => '\'\''.encode('ASCII'), 
                          line_separator  => Buf.new(0),
                          escape_operator => '\\'.encode('ASCII'),
                          binary => True );

my %line2 = %($parser.get_line());
my $k     = 0;

for ($line) -> $v {
  $outcome = 0 if %line2{ $k } eqv $v;
}

ok $outcome == 1;
