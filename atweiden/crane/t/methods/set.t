use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 5;

# testing set in Any {{{

subtest
{
    my $x = 0;
    Crane.set($x, :path(), :value(1));
    is $x, 1, 'Is expected value';
}

# end testing set in Any }}}

# testing set in Associative {{{

subtest
{
    # container root
    my %f = :right({:now<yes>});
    Crane.set(%f, :path(), :value({:wrong({:later<no>})}));
    is-deeply %f, {:wrong({:later<no>})}, 'Is expected value';

    # 1 level deep
    my %h = :a<alpha>,:b<bravo>,:c<charlie>;
    Crane.set(%h, :path('a',), :value<Alpha>);
    is-deeply %h, {:a<Alpha>,:b<bravo>,:c<charlie>}, 'Is expected value';

    # 2 levels deep
    my %j = :why({:do({:you(7)})});
    Crane.set(%j, :path(qw<why do>), :value({:You<Always>}));
    is-deeply %j, {:why({:do({:You<Always>})})}, 'Is expected value';

    # 3 levels deep
    my %l = :why({:do({:you({:always(7)})})});
    Crane.set(%l, :path(qw<why do you>), :value({:Always<Kick>}));
    is-deeply %l, {:why({:do({:you({:Always<Kick>})})})}, 'Is expected value';

    # 7 levels deep
    my %n = :why({:do({:you({:always({:kick({:me({:when({:im(7)})})})})})})});
    Crane.set(%n, :path(qw<why do you always kick me when im>), :value<High>);
    is-deeply %n,
        {:why({:do({:you({:always({:kick({:me({:when({:im<High>})})})})})})})},
        'Is expected value';

    # container root
    my %i;
    my %legume = :instock(43), :name("black beans"), :unit<lbs>;
    is-deeply Crane.set(%i, :path(), :value(%legume)), %legume,
        'Is expected value';

    # deep container
    my %data = %TestCrane::data;
    my %data-b = %data.deepmap(*.clone);
    push %data-b<legumes>, %legume;
    is-deeply Crane.set(%data, :path('legumes', *-0), :value(%legume)), %data-b,
        'Is expected value';
}

# end testing set in Associative }}}

# testing set in Positional {{{

subtest
{
    # container root
    my @a = qw<zero one two>;
    Crane.set(@a, :path(), :value(qw<Zero One Two>));
    is-deeply @a, [qw<Zero One Two>], 'Is expected value';

    # 1 level deep
    my @c = qw<zero one two>;
    Crane.set(@c, :path(0,), :value<Zero>);
    is-deeply @c, [qw<Zero one two>], 'Is expected value';

    # 2 levels deep
    my @e = [ ['she', 'cried'], ['more', 'more', 'more', 'more'] ];
    Crane.set(@e, :path(1, 3), :value<More>);
    is-deeply @e, [ ['she', 'cried'], ['more', 'more', 'more', 'More'] ],
        'Is expected value';

    # 3 levels deep
    my @g = [ 'she', 'want', 'more', [ 'more', [ 'more', [ 'more' ] ] ] ];
    Crane.set(@g, :path(3, 1, 1), :value(['More']));
    is-deeply @g, ['she','want','more',['more',['more',['More']]]],
        'Is expected value';

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
    Crane.set(@i, :path(1, 1, 1, 1, 1, 1, 1), :value(['want',['my',['mtv']]]));
    is-deeply @i, @j-expected, 'Is expected value';
}

# end testing set in Positional }}}

# testing Exceptions {{{

subtest
{
    # Exceptions
    my %i = :a(:pair(:is(:not(:a<hash>))));
    throws-like {Crane.set(%i, :path(qw<a pair is not>), :value({:a<Hash>}))},
        X::Crane::OpSet::RO,
        'Set operation fails when path is immutable';

    my $list = (qw<zero one two>);
    throws-like {Crane.set($list, :path(0,), :value<Zero>)},
        X::Crane::OpSet::RO,
        'Set operation fails when target is immutable';
    throws-like {Crane.replace($list, :path('d',), :value<d>)},
        X::Crane::PositionalIndexInvalid,
        'Set operation fails when Positional index invalid';
}

# end testing Exceptions }}}

# testing documentation examples {{{

subtest
{
    my %p;
    Crane.set(%p, :path(qw<peter piper>), :value<man>);
    Crane.set(%p, :path(qw<peter pan>), :value<boy>);
    Crane.set(%p, :path(qw<peter pickle>), :value<dunno>);
    is-deeply %p, { :peter({ :pan("boy"), :pickle("dunno"), :piper("man") }) },
        'Is expected value';

    my $a = (1, 2, 3);
    Crane.set($a, :path(), :value<foo>);
    is-deeply $a, 'foo', 'Is expected value';
}

# end testing documentation examples }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
