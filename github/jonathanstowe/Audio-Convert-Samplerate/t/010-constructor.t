#!perl6

use v6.c;
use Test;
plan 4;

use LibraryCheck;

use Audio::Convert::Samplerate;

if !library-exists('samplerate', v0) {
    skip-rest "no samplerate library, won't run tests";
    exit;
}

my $obj;

lives-ok { $obj = Audio::Convert::Samplerate.new }, "create a new Audio::Convert::Samplerate";
isa-ok($obj, Audio::Convert::Samplerate, 'and it is the right sort of object');
my $v;
lives-ok { $v = $obj.samplerate-version }, "get samplerate version";
isa-ok($v, Version, "and it is a version");
diag "testing with samplerate version " ~ $v;

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
