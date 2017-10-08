use v6;

use Test;

use LibYAML;
use LibYAML::Emitter;

my $DATA = $*PROGRAM.parent.child('data');

my @tests = $DATA.dir.map: { .basename };

my @skip;
# TODO: TAGS
@skip.push: | < 5TYM 8MK2 S4JQ >;

# TODO yaml-test-suite bug (fixed, need to update t/data)
@skip.push: | < 35KP >;
# TODO needs an out.yaml
@skip.push: | < 5TYM >;

# TODO EXPLICIT DOC
@skip.push: | < RZT7 KSS4 3MYT >;

# TODO:
# W42U - extra space after dash for empty sequence items
# 7W2P - extra space for empty mapping values
#   JTV5 2XXW
# UT92 - extra space after ---
# RZT7 - trailing newline in literal style M5C3
@skip.push: | <
    W42U 7W2P JTV5 2XXW UT92 RZT7
>;
# output different style than original
@skip.push: | <
    M9B4 P2AD DWX9 K858 A6F9 J3BT 5WE3 4ZYM M5C3 UGM3 M29M HS5T 9YRD HMK4 6JQW
    F8F9 77H8 6HB6 5GBF H2RW 6FWR 5BVJ 565N
>;

my %skip;
@skip.map: { %skip{ $_ } = 1 };

@tests = @tests.grep: { not %skip{ $_ } };

#@tests = ('229Q');

plan @tests.elems;

my $emitter = LibYAML::Emitter.new(
);

my %styles = %(
    ':' => 'plain',
    "'" => 'single',
    '"' => 'double',
    '>' => 'folded',
    '|' => 'literal',
);
for @tests.sort -> $test {
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
                $emitter.document-start-event(implicit => $implicit);
            }
            when '-DOC' {
                my $implicit = True;
                if ($ev ~~ m/^\.\.\./) {
                    $implicit = False;
                }
                $emitter.document-end-event(implicit => $implicit);
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
                $emitter.mapping-start-event(
                    anchor => $anchor, tag => $tag,
                );
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
                $emitter.sequence-start-event(
                    anchor => $anchor, tag => $tag,
                );
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
                $emitter.scalar-event(
                    value => $value,
                    anchor => $anchor,
                    tag => $tag,
                    style => $style,
                );
            }
            when '=ALI' {
                my Str $alias;
                if ($ev ~~ m/^\*(\S+)/) {
                    $alias = $0.Str;
                    $emitter.alias-event(alias => $alias);
                }
            }
        }

    }
#    $emitter.stream-start-event;
#    $emitter.document-start-event(implicit => True);
#    $emitter.scalar-event(value => "foo", anchor => "anchor", tag => "!tag");
#    $emitter.document-end-event();
#    $emitter.stream-end-event;
    $emitter.delete;
    my $yaml = $emitter.buf;
    @tests == 1 and say ">> $yaml <<";
    if ($test eq 'P76L') {
        todo "This test passes on some systems and fails on others";
    }
    cmp-ok($yaml, 'eq', $expected-yaml, "$test - $testname");


}

done-testing;
