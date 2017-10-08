#!/usr/bin/env perl6

use lib 'lib';
use Test;
plan 1;

use CSV::Parser;

my $outcome = 1;
my $fh      = open 't/data/escaped.csv', :r;
my $parser  = CSV::Parser.new( file_handle => $fh , contains_header_row => True );
my $keys    = 0;
my %line    = %($parser.get_line());

for (%line.kv) -> $k,$v {
  $keys++;
  $outcome = 0 if ( $k ne $v && $k ne 'a line' ) || ( $k eq 'a line' && $v eq '"' ); 
}

#$outcome = 0 if $keys != 5; 

$fh.close;
ok $outcome == 1;
