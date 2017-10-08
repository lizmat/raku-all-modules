use v6;
use Test;
use JSON::Hjson;
use JSON::Tiny;

my @files = dir('t/testCases').grep: /_test\.h?json$/;
for @files -> $f {
    my $text = slurp($f);
    my $name = $f.basename;
    if ($f.basename ~~ /^fail/) {
        dies-ok { from-hjson($text) }, $name;
    } else {
        my $got = coerce-numeric(from-hjson($text));
        my $result = $f.subst(/_test.h?json$/, '_result.json');
        my $expected = from-json(slurp($result));
        # XXX Prefer not to use `is-deeply` due to rational number comparison
        #     (See also t/testCases/pass1_test.json)
        # is-deeply $got, $expected, $name;
        cmp-ok $got.perl, 'eq', $expected.perl, $name;
    }
}

sub coerce-numeric($a) {
    given $a.WHAT {
        when Numeric {
            my $retval = $a;
            if $retval.WHAT === Num && $retval.perl ~~ /e0$/ {
                $retval = $retval.Rat;
            }
            if $retval.WHAT === Rat && $retval.perl ~~ /\.0$/ {
                $retval = $retval.Int;
            }
            return $retval;
        }
        when Array {
            return [$a.map: { coerce-numeric($_) }];
        }
        when Hash {
            return ($a.pairs.map: { .key => coerce-numeric(.value) }).hash;
        }
    }
    return $a;
}

done-testing;
