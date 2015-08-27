#!perl6
use v6;
use lib 'lib';
use Test;

use Audio::Convert::Samplerate;

my $obj;

lives-ok { $obj = Audio::Convert::Samplerate.new }, "create a new Audio::Convert::Samplerate";
isa-ok($obj, Audio::Convert::Samplerate, 'and it is the right sort of object');
my $v;
lives-ok { $v = $obj.samplerate-version }, "get samplerate version";
isa-ok($v, Version, "and it is a version");
diag "testing with samplerate version " ~ $v;

done;

# vim: expandtab shiftwidth=4 ft=perl6
