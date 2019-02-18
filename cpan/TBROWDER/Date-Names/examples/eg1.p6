#!/usr/bin/env perl6

use lib <../lib>;
use Date::Names;

# VERSION 2

my @dow = $Date::Names::nl::dow;
say "index {$_ + 1}" for @dow.keys.sort; # 1..7
say "******************************************";

my $d = Date::Names.new: :lang<nl>;
$d.dump;
say "Month 3, Dutch: '{$d.mon(3)}'"; # output: ''
say "******************************************";

$d .= clone: :lang('it');
$d.dump;
say "Weekday 3, Italian: '{$d.dow(3)}'"; # output: ''
say "******************************************";

$d .= clone: :lang('de');
$d.dump;
say "******************************************";

$d .= clone: :dset('dow2');
$d.dump;
say "Two-letter abbrev., weekday 6, German: '{$d.dow(6)}'";
say "******************************************";

$d .= clone: :lang('fr');
$d.dump;
say "******************************************";

$d .= clone: :mset('mon2');
$d.dump;
say "Two-letter abbrev., month 7, French: '{$d.mon(7)}'";
say "******************************************";
