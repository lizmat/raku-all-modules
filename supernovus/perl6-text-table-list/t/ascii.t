#!/usr/bin/env perl6

use v6;

use Text::Table::List::ASCII;
use Test;

plan 2;

my $t1 = Text::Table::List::ASCII.new.start;
$t1.label("A Test Table");
$t1.line;
$t1.field("Hello:", "World");
$t1.field("Goodbye:", "Universe");
$t1.line;
$t1.label("And now for some numbers.");
$t1.blank;
$t1.field("Pi:", pi.base(16));
$t1.field("The Answer:", 42);
$t1.field("Nonsense:", "31.34892");

my $wanted = "#==============================================================================#
| A Test Table                                                                 |
+------------------------------------------------------------------------------+
| Hello:                                                                 World |
| Goodbye:                                                            Universe |
+------------------------------------------------------------------------------+
| And now for some numbers.                                                    |
|                                                                              |
| Pi:                                                                 3.243F6B |
| The Answer:                                                               42 |
| Nonsense:                                                           31.34892 |
#==============================================================================#";

is ~$t1, $wanted, "Table with default length";

my $t2 = Text::Table::List::ASCII.new(:length(40)).start;

$t2.label("Small test");
$t2.line;
my %staff = {
  "Susan Smith"    => "CEO",
  "Kevin Michaels" => "COO",
  "Richard Frank"  => "Janitor",
  "Lisa Dawkins"   => "Designer",
};
$t2.field(|%staff);

$wanted = "#======================================#
| Small test                           |
+--------------------------------------+
| Susan Smith                      CEO |
| Kevin Michaels                   COO |
| Richard Frank                Janitor |
| Lisa Dawkins                Designer |
#======================================#";

is ~$t2, $wanted, "Table with custom length";

