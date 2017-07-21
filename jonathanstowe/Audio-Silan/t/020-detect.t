#!perl6

use v6.c;

use Test;

use Audio::Silan;

my $test-file = $*PROGRAM.parent.child('data/test.wav').Str;

my $obj;

lives-ok { $obj = Audio::Silan.new }, "create new object";

if try $obj.silan-path {

    my $ret;

    lives-ok { $ret = await $obj.find-boundaries($test-file) }, "find-boundaries";

    isa-ok $ret, Audio::Silan::Info, "and we got back what we expected";

    is-approx $ret.start,0.000023, "approximately the right start";
    is-approx $ret.end, 1.000023, "approximately the right end";
    is $ret.sample-rate, 44100, "correct sample rate";
    is $ret.duration, 2, "correct duration";

    lives-ok { $obj = Audio::Silan.new(threshold => 0.001, hold-off => 0.5) }, "create new object (with arguments)";


    lives-ok { $ret = await $obj.find-boundaries($test-file) }, "find-boundaries";

    isa-ok $ret, Audio::Silan::Info, "and we got back what we expected";

    is-approx $ret.start,0.000023, "approximately the right start";
    is-approx $ret.end, 1.000023, "approximately the right end";
    is $ret.sample-rate, 44100, "correct sample rate";
    is $ret.duration, 2, "correct duration";


    throws-like { await $obj.find-boundaries("jkssksks.wav") },X::NoFile, message => "File 'jkssksks.wav' does not exist", "test exception" ;
}
else {
    skip "no silan executable found", 15;
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
