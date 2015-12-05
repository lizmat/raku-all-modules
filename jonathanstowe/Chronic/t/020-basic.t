#!perl6

use v6;
use lib 'lib';

use Test;

use Chronic;

my %ranges = (
    minute      =>  0 .. 59,
    hour        =>  0 .. 23,
    day         =>  1 .. 31,
    month       =>  1 .. 12,
    day-of-week =>  1 .. 7,
);

for %ranges.kv -> $k, $v {
    subtest {
        for $v.list -> $min {
            for ($min .. $v.max).list -> $max {
                my Range $r = $min .. $max;
                lives-ok { Chronic::Description.new(|($k => $r)) }, "range constructor for $k ($r)";
                my Int @m = $r.list;
                lives-ok { Chronic::Description.new(|($k => @m)) }, "array constructor for $k  ({@m})";
                my Int $i = @m.pick;
                lives-ok { Chronic::Description.new(|($k => $i)); }, "integer constructor for $k  ( $i )";
                last if Bool.pick;
            }
            last if Bool.pick;
        }
    }, "constructor for $k";
}

my @tests = (
    {
        chronic => {
            minute  => any(10,23),
        },
        dt  =>  {
            minute  => 23,
        },
        result  =>  True,
        description => "minutes",
    },
    {
        chronic => {
            minute  => 10 .. 23,
        },
        dt  =>  {
            minute  => 23,
        },
        result  =>  True,
        description => "minutes (range)",
    },
    {
        chronic => {
            minute  => (10 .. 23).list,
        },
        dt  =>  {
            minute  => 23,
        },
        result  =>  True,
        description => "minutes (list)",
    },
    {
        chronic => {
            hour  => any(10,23),
        },
        dt  =>  {
            hour  => 23,
        },
        result  =>  True,
        description => "hour",
    },
    {
        chronic => {
            hour  => 10 .. 23,
        },
        dt  =>  {
            hour  => 23,
        },
        result  =>  True,
        description => "hour (range)",
    },
    {
        chronic => {
            hour  => (10,23),
        },
        dt  =>  {
            hour  => 23,
        },
        result  =>  True,
        description => "hour (list)",
    },
    {
        chronic => {
            hour  => any(10,23),
        },
        dt  =>  {
            hour  => 20,
        },
        result  =>  False,
        description => "hour negative",
    },
    {
        chronic => {
            hour  => (10,23),
        },
        dt  =>  {
            hour  => 20,
        },
        result  =>  False,
        description => "hour negative (list)",
    },
    {
        chronic => {
            hour  => 10 .. 23,
        },
        dt  =>  {
            hour  => 9,
        },
        result  =>  False,
        description => "hour negative (range)",
    },
    {
        chronic => {
            day  => any(10,23),
            month   => any(12),
        },
        dt  =>  {
            day  => 23,
            month => 12,
        },
        result  =>  True,
        description => "Day and month",
    },
    {
        chronic => {
            day  => (10,23),
            month   => (12),
        },
        dt  =>  {
            day  => 23,
            month => 12,
        },
        result  =>  True,
        description => "Day and month (list)",
    },
    {
        chronic => {
            day  => 10 .. 23,
            month   => (12),
        },
        dt  =>  {
            day  => 23,
            month => 12,
        },
        result  =>  True,
        description => "Day and month (range)",
    },
    {
        chronic => {
            day  => any(10,23),
            month   => any(12),
        },
        dt  =>  {
            day  => 23,
            month => 11,
        },
        result  =>  False,
        description => "Day and month (negative)",
    },
    {
        chronic => {
            day  => (10,23),
            month   => (12),
        },
        dt  =>  {
            day  => 23,
            month => 11,
        },
        result  =>  False,
        description => "Day and month (negative) (list)",
    },
    {
        chronic => {
            day  => 10 .. 23,
            month   => 12,
        },
        dt  =>  {
            day  => 23,
            month => 11,
        },
        result  =>  False,
        description => "Day and month (negative) (range)",
    },
    {
        chronic => {
            minute  => any(15),
            month   => any(12),
        },
        dt  =>  {
            day  => 23,
            month => 11,
        },
        result  =>  False,
        description => "Minute and month (negative)",
    },
    {
        chronic => {
            minute  => (15),
            month   => (12),
        },
        dt  =>  {
            day  => 23,
            month => 11,
        },
        result  =>  False,
        description => "Minute and month (negative) (list)",
    },
    {
        chronic => {
            minute  => 15 .. 16,
            month   =>  9 .. 10
        },
        dt  =>  {
            day  => 23,
            month => 11,
        },
        result  =>  False,
        description => "Minute and month (negative) (range)",
    },
    {
        chronic => {
            minute  => any(15),
            month   => any(12),
        },
        dt  =>  {
            minute  => 15,
            month => 12,
        },
        result  =>  True,
        description => "Minute and month",
    },
);

my $d = DateTime.now;
my $now = DateTime.new(date => $d.Date, minute => $d.minute, hour => $d.hour);
ok $now ~~ Chronic::Description.new, "default comparison works";
ok Chronic::Description.new ~~ $now, "default comparison works (the other way round";

for @tests -> $test {
    $test<dt><year> = (1971 .. 2037).pick;
    if $test<result> {
        ok Chronic::Description.new(|$test<chronic>) ~~ DateTime.new(|$test<dt>), $test<description>;
    }
    else {
        nok Chronic::Description.new(|$test<chronic>) ~~ DateTime.new(|$test<dt>), $test<description>;

    }
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
