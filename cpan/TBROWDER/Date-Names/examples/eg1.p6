#!/usr/bin/env perl6

use lib <../lib>;
use Date::Names;

my $debug = @*ARGS ?? 1 !! 0;

# VERSION 2
say "VERSION 2 ==================";

my @dow = $Date::Names::nl::dow;
print "indices:";
print " {$_ + 1}" for @dow.keys.sort; # 1..7
say "";
say "******************************************" if $debug;

my $d = Date::Names.new: :lang('nl'), :debug(1);
$d.dump if $debug;
say "Month 3, Dutch: '{$d.mon(3)}'"; # output: ''
say "******************************************" if $debug;

$d .= clone: :lang('it');
$d.dump if $debug;
say "Weekday 3, Italian: '{$d.dow(3)}'"; # output: ''
say "******************************************" if $debug;

$d .= clone: :lang('de');
$d.dump if $debug;
say "******************************************" if $debug;

#enum Dset (dow2 => 'dow2', mon2 => 'mon2');
$d .= clone: :dset('dow2');
$d.dump if $debug;
say "Two-letter abbrev., weekday 6, German: '{$d.dow(6)}'";
say "******************************************" if $debug;

$d .= clone: :lang('fr');
$d.dump if $debug;
say "******************************************" if $debug;

$d .= clone: :mset('mon2');
$d.dump if $debug;
say "Two-letter abbrev., month 7, French: '{$d.mon(7)}'";
say "******************************************" if $debug;

Date::Names.new(:debug(1)).show-all;
