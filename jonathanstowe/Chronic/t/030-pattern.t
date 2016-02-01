#!perl6

use v6;

use Test;

use Chronic;

my @tests = (
    {
        attribute   =>  'day-of-week',
        pattern     =>  '*',
        result      =>  (1 .. 7).Array;
    },
    {
        attribute   =>  'day-of-week',
        pattern     =>  '1-7',
        result      =>  (1 .. 7).Array;
    },
    {
        attribute   =>  'day-of-week',
        pattern     =>  '1,2-6,7',
        result      =>  (1 .. 7).Array;
    },
    {
        attribute   =>  'day-of-week',
        pattern     =>  '1,2,3,4,5,6,7',
        result      =>  (1 .. 7).Array;
    },
    {
        attribute   =>  'day-of-week',
        pattern     =>  '*/2',
        result      =>  [2,4,6];
    },
    {
        attribute   =>  'month',
        pattern     =>  '*',
        result      =>  (1 .. 12).Array;
    },
    {
        attribute   =>  'month',
        pattern     =>  '1-12',
        result      =>  (1 .. 12).Array;
    },
    {
        attribute   =>  'month',
        pattern     =>  '1,2,3,4-12',
        result      =>  (1 .. 12).Array;
    },
    {
        attribute   =>  'month',
        pattern     =>  '1,2,3,4-12/3',
        result      =>  (3, 6, 9, 12).Array;
    },
    {
        attribute   =>  'month',
        pattern     =>  '*/3',
        result      =>  (3, 6, 9, 12).Array;
    },
    {
        attribute   =>  'day',
        pattern     =>  '*',
        result      =>  (1 .. 31).Array;
    },
    {
        attribute   =>  'day',
        pattern     =>  '1-31',
        result      =>  (1 .. 31).Array;
    },
    {
        attribute   =>  'day',
        pattern     =>  '1,2,3,4,5-10,11-20,21-31',
        result      =>  (1 .. 31).Array;
    },
    {
        attribute   =>  'day',
        pattern     =>  '11-20',
        result      =>  (11 .. 20).Array;
    },
    {
        attribute   =>  'day',
        pattern     =>  '1,2,3,4,5-10,11-20,21-31/5',
        result      =>  (5, 10, 15, 20, 25, 30).Array;
    },
    {
        attribute   =>  'day',
        pattern     =>  '*/5',
        result      =>  (5, 10, 15, 20, 25, 30).Array;
    },
    {
        attribute   =>  'minute',
        pattern     =>  '*',
        result      =>  (0 .. 59).Array;
    },
    {
        attribute   =>  'minute',
        pattern     =>  '0-13,14,15,16-59',
        result      =>  (0 .. 59).Array;
    },
    {
        attribute   =>  'minute',
        pattern     =>  '59',
        result      =>  (59).Array;
    },
    {
        attribute   =>  'minute',
        pattern     =>  '0-13,14,15,16-59/11',
        result      =>  (0, 11, 22, 33, 44, 55).Array;
    },
    {
        attribute   =>  'minute',
        pattern     =>  '8-40/8',
        result      =>  (8, 16, 24, 32, 40).Array;
    },
    {
        attribute   =>  'hour',
        pattern     =>  '*',
        result      =>  (0 .. 23).Array;
    },
    {
        attribute   =>  'hour',
        pattern     =>  '0-23',
        result      =>  (0 .. 23).Array;
    },
    {
        attribute   =>  'hour',
        pattern     =>  '0,1-10,11-22,23',
        result      =>  (0 .. 23).Array;
    },
    {
        attribute   =>  'hour',
        pattern     =>  '*/8',
        result      =>  (0, 8, 16).Array;
    },
    {
        attribute   =>  'hour',
        pattern     =>  '0-23/8',
        result      =>  (0, 8, 16).Array;
    },
    {
        attribute   =>  'hour',
        pattern     =>  '0,1-10,11-22,23/8',
        result      =>  (0, 8, 16).Array;
    },
);

for @tests -> $test {
    subtest {
        my $obj;
        my $attr = $test<attribute>;
        my $patt =  $test<pattern>;
        lives-ok { $obj = Chronic::Description.new(|($attr => $patt)) }, "create object with pattern";
        ok $obj."$attr"() ~~ all($test<result>.list), "and matches the expected result";
    }, $test<attribute> ~ " with pattern '{ $test<pattern> }'";
}
done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
