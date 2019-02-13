#!/usr/bin/env perl6

use lib <../lib>;
use Date::Names;

=finish

# VERSION 1
say "The example from the README:";
say "Month 3 in Dutch is '{%Date::Names::mon<nl><3>}'";
say "Month 3 in English is '{%Date::Names::mon<3>}' or '{%Date::Names::mon<en><3>}'";
say "Month 3 in French is '{%Date::Names::mon<fr><3>}'";
say "Weekday 3 in Italian is '{%Date::Names::dow<it><3>}'";
say "Weekday 3 in Spanish is '{%Date::Names::dow<es><3>}'";
say "Two-letter abbrev. of weekday 3 in German is '{%Date::Names::dow2<de><3>}'";
say "Three-letter abbrev. of weekday 3 in English is '{%Date::Names::dow3<en><3>}'";

say "";

my %dow = %Date::Names::dow<nl>;
say "Weekdays in Dutch:";
for 1..7 -> $n {
    say "  day $n: {%dow{$n}}";
}
