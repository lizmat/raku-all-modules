use v6;

use Test;

use LibYAML;
use LibYAML::Parser;
use LibYAML::Loader::TestSuite;

my $DATA = $*PROGRAM.parent.child('data');

my $loader = LibYAML::Loader::TestSuite.new;
my $parser = LibYAML::Parser.new(
    loader => $loader,
);

plan 155;

my @tests = <
229Q 3MYT 5BVJ 6FWR 735Y 87E4 9J7A AZW3 CUP7 EW3V GT5M J9HZ L94M MJS9
PBJ2 TS54 236B 5C5M 6H3V 74H7 9KBC BD7L D49Q F2C7 H2RW JHB9 L9U5 MXS3
PRH3 S4JQ U3C3 X38W 4CQQ 5GBF 6HB6 77H8 8MK2 9SHH D88J F8F9 H7J7 S4T7
U3XV XW4D 2AUY 4GC6 5KJE 6JQW 7A4E 8QBE 9U5K BS4K D9TU HMK4 JS2J LP6E
MZX3 Q88A S9E8 U9NS YD5X 2CMS 4HVU 5NYZ 6JWB 7BUB 8UDB 9WXW BU8L FQ7F
HMQ5 JTV5 Q9WF SBG9 UDR7 Z9M4 4JVG 5TYM 7FWL 9YRD HS5T K4SU M29M QF4Y
SR86 UGM3 ZCZ6 4UYU 5U3A 7LBH 93JH C2SP DHP8 FUP4 HU3P K527 M5C3 SYW4
UT92 ZF4X 2XXW 4ZYM 5WE3 6S55 7MNF 96L6 A6F9 C4HZ DMG6 J3BT K858 M5DY
NP9H RLU9 V55R ZH7C 35KP 54T7 65WH 6SLA 7T8X A984 CC74 DWX9 G7JE J5UC
P2AD RR7F TD5N V9D5 ZVH3 3ALJ 565N 6VJK 7W2P 9CWY G992 J7PZ KSS4 M9B4
P76L TE2A W42U 3GZX 57H4 82AN 9FMG AZ63 CT4Q EHF6 GH63 J7VC P94K RZT7
TL85
>;
#@tests = ('229Q');
#@tests = ('P76L');
#@tests = ('EHF6');
for @tests -> $test {
    $loader.events = ();
    my $testdir = $DATA.child($test);

    my $testname = $testdir.child('===').lines[0];

#    diag "$test $testname";

    my $yaml = $testdir.child('in.yaml').Str;
    if $testdir.child('error').e
    {
        diag "$test ERROR";

        throws-like { $parser.parse-file($yaml) },
                    X::LibYAML::Parser-Error,
                    message => /ERROR/;

        next;
    }

    $parser.parse-file($yaml);

    my Str @expected-events = $testdir.child('test.event').lines;
    my Str @events = $loader.events.Array;
    # temp workaround
    @expected-events.map: {
        $_ ~~ s/\+DOC\s\-\-\-/+DOC/;
        $_ ~~ s/\-DOC\s\.\.\./-DOC/;
    };
    @events.map: {
        $_ ~~ s/\+DOC\s\-\-\-/+DOC/;
        $_ ~~ s/\-DOC\s\.\.\./-DOC/;
    };
    is-deeply(@events, @expected-events, "$test - events");


}

done-testing;
