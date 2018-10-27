#!/usr/bin/env perl6

use v6;

use Text::Table::List;

sub sum1 ($n) { [+] ^$n }
sub sum2 ($n) { return ($n ** 2 - $n) / 2; }

sub timer ($table, $label, &func) {
  $table.line;
  $table.label("Using $label");
  $table.blank;

  my $start = now;
  $table.field("Result:", func());
  my $end = now;
  my $duration = $end - $start;
  $table.field("Took:", $duration);
}

sub make_test ($num) {
  my $table = Text::Table::List.new(:length(40)).start;
  $table.label("Testing $num");
  timer $table, "sum1", { sum1($num) };
  timer $table, "sum2", { sum2($num) };
  say ~$table;
}

my @tests = 10, 100, 1000, 10000, 100000, 1000000;

for @tests { make_test($_); }

