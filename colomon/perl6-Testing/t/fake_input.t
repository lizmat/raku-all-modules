#!/usr/bin/env perl6
use v6;

use Testing;

my $fh = IN(1,2,3);

COMM 'Fake line-by-line...';
OK  $fh.get(),  1,            :desc<Faking first line>;
OK  $fh.get(),  2,            :desc<Faking second line>;
OK  $fh.get(),  3,            :desc<Faking third line>;
OK  $fh.get(),  ! *.defined,  :desc<Faking EOF>;

COMM 'Fake reading all lines...';
$fh = IN(1,2,3);
OK  $fh.lines,  [1,2,3],    :desc<Faking lines()>;

COMM 'Fake slurping all lines...';
$fh = IN(1,2,3);
OK  $fh.slurp,  "1\n2\n3",    :desc<Faking slurp()>;

COMM 'Fake some lines...';
$fh = IN(1,2,3);
OK  $fh.lines(2),  [1,2],   :desc<Faking lines(2)>;
OK  $fh.lines,     [3],     :desc<Faking lines>;
OK  $fh.lines,     [],      :desc<Faking lines at EOF>;

COMM 'Fake bytewise reading...';
$fh = IN(1,2,3);
OK  $fh.getc(),    "1",           :desc<Faking getc>;
OK  $fh.getc(),    "\n",          :desc<Faking getc again>;
OK  $fh.read(3),   "2\n3",        :desc<Faking read>;
OK  $fh.getc(),    ! *.defined,   :desc<Should now hit EOF>;
OK  $fh.eof,       1,             :desc<Should be at EOF>;

COMM 'Fake EOF...';
$fh = IN(1,2,3);
OK $fh.eof(), 0, :desc<Not at EOF>;
$fh.slurp;
OK $fh.eof(), 1, :desc<At EOF>;

$fh = IN('0123456789');
COMM 'Fake file tests...';
OK $fh ~~ :t, 0,  :desc<Faking :t>;
OK $fh ~~ :r, 1,  :desc<Faking :r>;
OK $fh ~~ :d, 0,  :desc<Faking :d>;
OK $fh ~~ :e, 1,  :desc<Faking :e>;
OK $fh ~~ :f, 1,  :desc<Faking :f>;
OK $fh ~~ :s, 1,  :desc<Faking :s (boolean)>;
OK $fh.s,     10, :desc<Faking :s (numeric)>;
OK $fh ~~ :l, 0,  :desc<Faking :l>;
OK $fh ~~ :z, 0,  :desc<Faking :z>;
