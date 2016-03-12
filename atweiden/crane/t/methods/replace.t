use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 6;

# testing replace in Any {{{

subtest
{
    my $x = 0;
    my $y = Crane.replace($x, :path(), :value(1));
    is $y, 1, 'Is expected value';
    is $x, 0, 'Original container is unchanged';
}

# end testing replace in Any }}}

# testing replace in Associative {{{

subtest
{
    # container root
    my %f = :right({:now<yes>});
    my %g = Crane.replace(%f, :path(), :value({:wrong({:later<no>})}));
    is-deeply %g, {:wrong({:later<no>})}, 'Is expected value';
    is-deeply %f, {:right({:now<yes>})}, 'Original container is unchanged';

    # 1 level deep
    my %h = :a<alpha>,:b<bravo>,:c<charlie>;
    my %i = Crane.replace(%h, :path('a',), :value<Alpha>);
    is-deeply %i, {:a<Alpha>,:b<bravo>,:c<charlie>}, 'Is expected value';
    is-deeply %h, {:a<alpha>,:b<bravo>,:c<charlie>},
        'Original container is unchanged';

    # 2 levels deep
    my %j = :why({:do({:you(7)})});
    my %k = Crane.replace(%j, :path(qw<why do>), :value({:You<Always>}));
    is-deeply %k, {:why({:do({:You<Always>})})}, 'Is expected value';
    is-deeply %j, {:why({:do({:you(7)})})}, 'Original container is unchanged';

    # 3 levels deep
    my %l = :why({:do({:you({:always(7)})})});
    my %m = Crane.replace(
        %l,
        :path(qw<why do you>),
        :value({:Always<Kick>})
    );
    is-deeply %m, {:why({:do({:you({:Always<Kick>})})})}, 'Is expected value';
    is-deeply %l, {:why({:do({:you({:always(7)})})})},
        'Original container is unchanged';

    # 7 levels deep
    my %n = :why({:do({:you({:always({:kick({:me({:when({:im(7)})})})})})})});
    my %o = Crane.replace(
        %n,
        :path(qw<why do you always kick me when im>),
        :value<High>
    );
    is-deeply %o,
        {:why({:do({:you({:always({:kick({:me({:when({:im<High>})})})})})})})},
        'Is expected value';
    is-deeply %n,
        {:why({:do({:you({:always({:kick({:me({:when({:im(7)})})})})})})})},
        'Original container is unchanged';
}

# end testing replace in Associative }}}

# testing replace in Positional {{{

subtest
{
    # container root
    my @a = qw<zero one two>;
    my @b = Crane.replace(@a, :path(), :value([qw<Zero One Two>]));
    is-deeply @b, [qw<Zero One Two>], 'Is expected value';
    is-deeply @a, [qw<zero one two>], 'Original container is unchanged';

    # 1 level deep
    my @c = qw<zero one two>;
    my @d = Crane.replace(@c, :path(0,), :value<Zero>);
    is-deeply @d, [qw<Zero one two>], 'Is expected value';
    is-deeply @c, [qw<zero one two>], 'Original container is unchanged';

    # 2 levels deep
    my @e = [ ['she', 'cried'], ['more', 'more', 'more', 'more'] ];
    my @f = Crane.replace(@e, :path(1, 3), :value<More>);
    is-deeply @f, [ ['she', 'cried'], ['more', 'more', 'more', 'More'] ],
        'Is expected value';
    is-deeply @e, [ ['she', 'cried'], ['more', 'more', 'more', 'more'] ],
        'Original container unchanged';

    # 3 levels deep
    my @g = [ 'she', 'want', 'more', [ 'more', [ 'more', [ 'more' ] ] ] ];
    my @h = Crane.replace(@g, :path(3, 1, 1), :value(['More']));
    is-deeply @h, ['she','want','more',['more',['more',['More']]]],
        'Is expected value';
    is-deeply @g, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';

    # 7 levels deep
    my @i =
        [
            'i',
            [
                'want',
                [
                    'my',
                    [
                        'i',
                        [
                            'want',
                            [
                                'my',
                                [
                                    'i',
                                    [
                                        'want',
                                        [
                                            'my',
                                            [
                                                'MTV'
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ];
    my @i-expected =
        [
            'i',
            [
                'want',
                [
                    'my',
                    [
                        'i',
                        [
                            'want',
                            [
                                'my',
                                [
                                    'i',
                                    [
                                        'want',
                                        [
                                            'my',
                                            [
                                                'MTV'
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ];
    my @j-expected =
        [
            'i',
            [
                'want',
                [
                    'my',
                    [
                        'i',
                        [
                            'want',
                            [
                                'my',
                                [
                                    'i',
                                    [
                                        'want',
                                        [
                                            'my',
                                            [
                                                'mtv'
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ];
    my @j = Crane.replace(
        @i,
        :path(1, 1, 1, 1, 1, 1, 1),
        :value(['want',['my',['mtv']]])
    );
    is-deeply @j, @j-expected, 'Is expected value';
    is-deeply @i, @i-expected, 'Original container is unchanged';
}

# end testing replace in Positional }}}

# testing Exceptions {{{

subtest
{
    my %h = :a<alpha>,:b<bravo>,:c<charlie>;
    throws-like {Crane.replace(%h, :path('d',), :value<delta>)},
        X::Crane::ReplacePathNotFound,
        'Replace operation fails when path not found';
    my %i = :a(:b(:c(True)));
    throws-like {Crane.replace(%i, :path(qw<a b c>), :value({:d(True)}))},
        X::Crane::Replace::RO,
        'Replace operation fails when target is immutable';
    my @a = qw<zero one two>;
    throws-like {Crane.replace(@a, :path(*-0,), :value<three>)},
        X::Crane::ReplacePathNotFound,
        'Replace operation fails when path not found';
    my $list = (qw<zero one two>);
    throws-like {Crane.replace($list, :path(0,), :value<Zero>)},
        X::Crane::Replace::RO,
        'Replace operation fails when target is immutable';
    throws-like {Crane.replace($list, :path(9,), :value<nine>)},
        X::Crane::ReplacePathNotFound,
        'Replace operation fails when path not found';
    throws-like {Crane.replace($list, :path('d',), :value<d>)},
        X::Crane::PositionalIndexInvalid,
        'Replace operation fails when Positional index invalid';
}

# end testing Exceptions }}}

# testing documentation examples {{{

subtest
{
    my %data = %TestCrane::data;
    my %data-orig = %data.deepmap(*.clone);
    my %legume = :name("green beans"), :unit<lbs>, :instock(3);
    my %data-new = Crane.replace(%data, :path('legumes', 0), :value(%legume));
    my %data-expected =
        :legumes([
            {
                :instock(3),
                :name("green beans"),
                :unit("lbs")
            },
            {
                :instock(21),
                :name("lima beans"),
                :unit("lbs")
            },
            {
                :instock(13),
                :name("black eyed peas"),
                :unit("lbs")
            },
            {
                :instock(8),
                :name("split peas"),
                :unit("lbs")
            }
        ]);
    is-deeply %data-new, %data-expected, 'Is expected value';
    is-deeply %data, %data-orig, 'Original container is unchanged';

    my %a = :a<aaa>, :b<bbb>, :c<ccc>;
    my %b = Crane.replace(%a, :path([]), :value({:vm<moar>}));
    is-deeply %b, {:vm<moar>}, 'Is expected value';
    is-deeply %a, {:a<aaa>,:b<bbb>,:c<ccc>}, 'Original container is unchanged';
}

# end testing documentation examples }}}

# testing in-place modifications {{{

subtest
{
    my %data = %TestCrane::data;
    my %expected =
        :legumes([
            {
                :instock(4),
                :name("pinto beans"),
                :unit("lbs")
            },
            {
                :instock(21),
                :name("lima beans"),
                :unit("lbs")
            },
            {
                :instock(13),
                :name("black eyed peas"),
                :unit("lbs")
            },
            {
                :instock(88),
                :name("snow peas"),
                :unit("lbs")
            }
        ]);
    Crane.replace(
        %data,
        :path('legumes', *-1),
        :value({:instock(88),:name("snow peas"),:unit("lbs")}),
        :in-place
    );
    is-deeply %data, %expected, 'Is expected value';
}

# end testing in-place modifications }}}

# vim: ft=perl6 fdm=marker fdl=0
