use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 2;

subtest
{
    # Any
    my $x = 1;
    is-deeply Crane.list($x), List({:path(()), :value(1)}), 'Is expected value';

    # Associative
    my %h = :a<alpha>,:b<bravo>,:c<charlie>;
    is-deeply
        Crane.list(%h),
        (
            {
                :path(["a"]),
                :value("alpha")
            },
            {
                :path(["b"]),
                :value("bravo")
            },
            {
                :path(["c"]),
                :value("charlie")
            }
        ),
        'Is expected value';

    # Positional
    my $a = qw<zero one two>;
    is-deeply
        Crane.list($a),
        (
            {
                :path([0]),
                :value("zero")
            },
            {
                :path([1]),
                :value("one")
            },
            {
                :path([2]),
                :value("two")
            }
        ),
        'Is expected value';

    my %data = %TestCrane::data;
    is-deeply
        Crane.list(%data),
        (
            {
                :path(["legumes", 0, "instock"]),
                :value(4)
            },
            {
                :path(["legumes", 0, "name"]),
                :value("pinto beans")
            },
            {
                :path(["legumes", 0, "unit"]),
                :value("lbs")
            },
            {
                :path(["legumes", 1, "instock"]),
                :value(21)
            },
            {
                :path(["legumes", 1, "name"]),
                :value("lima beans")
            },
            {
                :path(["legumes", 1, "unit"]),
                :value("lbs")
            },
            {
                :path(["legumes", 2, "instock"]),
                :value(13)
            },
            {
                :path(["legumes", 2, "name"]),
                :value("black eyed peas")
            },
            {
                :path(["legumes", 2, "unit"]),
                :value("lbs")
            },
            {
                :path(["legumes", 3, "instock"]),
                :value(8)
            },
            {
                :path(["legumes", 3, "name"]),
                :value("split peas")
            },
            {
                :path(["legumes", 3, "unit"]),
                :value("lbs")
            }
        ),
        'Is expected value';
}

subtest
{
    # my Str $toml = "[hello]\n";
    my %from-toml = :hello({});
    is-deeply Crane.list(%from-toml), List({:path["hello"], :value({})}),
        'Is expected value';

    # $toml = "[[hello]]\n";
    %from-toml = :hello([{}]);
    is-deeply Crane.list(%from-toml), List({:path["hello"], :value([{}])}),
        'Is expected value';

    %from-toml = :hello([]);
    is-deeply Crane.list(%from-toml), List({:path["hello"], :value([])}),
        'Is expected value';
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
