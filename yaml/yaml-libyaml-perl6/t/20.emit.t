use v6;

use Test;

use LibYAML;
use LibYAML::Emitter;

my $DATA = $*PROGRAM.parent.child('data');

my $emitter = LibYAML::Emitter.new(
);


my @tests = <
229Q 735Y 87E4 9J7A AZW3 EW3V GT5M J9HZ MJS9
PBJ2 TS54 236B 5C5M 6H3V 9KBC BD7L D49Q JHB9 L9U5 MXS3
PRH3 X38W 4CQQ 9SHH D88J H7J7 S4T7
U3XV XW4D 4GC6 5KJE 7A4E 8QBE 9U5K BS4K D9TU JS2J LP6E
MZX3 Q88A S9E8 U9NS YD5X 2CMS 4HVU 5NYZ 7BUB 8UDB FQ7F
Q9WF SBG9 UDR7 4JVG K4SU QF4Y
SR86 ZCZ6 4UYU 5U3A 7LBH 93JH C2SP DHP8 FUP4 HU3P K527 SYW4
ZF4X 6S55 7MNF 96L6 DMG6 M5DY
NP9H RLU9 V55R ZH7C 54T7 65WH 6SLA 7T8X A984 G7JE J5UC
RR7F TD5N V9D5 ZVH3 3ALJ 6VJK 9CWY G992
TE2A 3GZX 82AN 9FMG AZ63 CT4Q GH63 J7VC P94K
TL85
>;
# TODO: TAGS
# P76L CUP7 EHF6 57H4 J7PZ 565N CC74 35KP C4HZ 2XXW M5C3 5TYM 7FWL Z9M4 HMQ5
# BU8L 9WXW 6JWB 2AUY 8MK2 77H8 U3C3 S4JQ F2C7 74H7 L94M

# TODO EXPLICIT DOC
# RZT7 KSS4 3MYT

# TODO:
# W42U - extra space after dash for empty sequence items
# 7W2P - extra space for empty mapping values
#   JTV5
# UT92 - extra space after ---
# RZT7 - trailing newline in literal style M5C3
# M9B4 - output different style than original
#   P2AD DWX9 K858 A6F9 J3BT 5WE3 4ZYM M5C3 UGM3 M29M HS5T 9YRD HMK4 6JQW
#   F8F9 77H8 6HB6 5GBF H2RW 6FWR 5BVJ

#@tests = ('229Q');
#@tests = ('U3XV');
plan @tests.elems;
my %styles = %(
    ':' => 'plain',
    "'" => 'single',
    '"' => 'double',
    '>' => 'folded',
    '|' => 'literal',
);
for @tests -> $test {
    my $testdir = $DATA.child($test);

    my $testname = $testdir.child('===').lines[0];

#    diag "$test $testname";

    if $testdir.child('error').e {
        ok(1);
        next;
    }
    my $expected-yaml = $testdir.child('in.yaml').slurp;
    if $testdir.child('out.yaml').e {
        $expected-yaml = $testdir.child('out.yaml').slurp;
    }

    my Str @events = $testdir.child('test.event').lines;

    $emitter.init;
    $emitter.buf = '';
    $emitter.set-output-string;

    for @events -> $event {
        my Str $ev = $event;
        @tests == 1 and say "== " ~ $ev;
        $ev ~~ s/^(.(STR|DOC|MAP|SEQ|VAL|ALI))\s?//;
        given $0 {
            when '+STR' {
                $emitter.stream-start-event;
            }
            when '-STR' {
                $emitter.stream-end-event;
            }
            when '+DOC' {
                my $implicit = True;
                if ($ev ~~ m/^\-\-\-/) {
                    $implicit = False;
                }
                $emitter.document-start-event($implicit);
            }
            when '-DOC' {
                my $implicit = True;
                if ($ev ~~ m/^\.\.\./) {
                    $implicit = False;
                }
                $emitter.document-end-event($implicit);
            }
            when '+MAP' {
                my Str $anchor;
                my Str $tag;
                #my Str $style;
                if ($ev ~~ s/^\&(\S+)\s*//) {
                    $anchor = $0.Str;
                }
                if ($ev ~~ s/^\<(\S+)\>\s*//) {
                    $tag = $0.Str;
                }
                $emitter.mapping-start-event($anchor, $tag);
            }
            when '-MAP' {
                $emitter.mapping-end-event();
            }
            when '+SEQ' {
                my Str $anchor;
                my Str $tag;
                #my Str $style;
                if ($ev ~~ s/^\&(\S+)\s*//) {
                    $anchor = $0.Str;
                }
                if ($ev ~~ s/^\<(\S+)\>\s*//) {
                    $tag = $0.Str;
                }
                $emitter.sequence-start-event($anchor, $tag);
            }
            when '-SEQ' {
                $emitter.sequence-end-event();
            }
            when '=VAL' {
                my Str $anchor;
                my Str $tag;
                my Str $style;
                if ($ev ~~ s/^\&(\S+)\s*//) {
                    $anchor = $0.Str;
                }
                if ($ev ~~ s/^\<(\S+)\>\s*//) {
                    $tag = $0.Str;
                }
                if ($ev ~~ s/^(<[:'">|]>)//) {
                    $style = $0.Str;
                }
                $style = %styles{ $style };
                my $value = $ev;
                my %map = %(
                    n => "\n",
                    r => "\r",
                    t => "\t",
                    '\\' => "\\",
                );
                if ($style eq <single double folded>.any) {
                    $value ~~ s:g/\\(<[nrt\\]>)/%map{ $0 }/;
                }
                elsif ($style eq 'literal') {
                    $value ~~ s:g/\\\\/\\/;
                }
                $emitter.scalar-event($anchor, $tag, $value, $style);
            }
            when '=ALI' {
                my Str $alias;
                if ($ev ~~ m/^\*(\S+)/) {
                    $alias = $0.Str;
                    $emitter.alias-event($alias);
                }
            }
        }

    }
#    $emitter.stream-start-event;
#    $emitter.document-start-event(True);
#    $emitter.scalar-event("anchor", "!tag", "foo");
#    $emitter.document-end-event();
#    $emitter.stream-end-event;
    $emitter.delete;
    my $yaml = $emitter.buf;
    @tests == 1 and say ">> $yaml <<";
    cmp-ok($yaml, 'eq', $expected-yaml, "$test - $testname");


}

done-testing;
