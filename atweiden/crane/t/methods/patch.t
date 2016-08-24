use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 5;

# testing patch in Any {{{

subtest
{
    my $x = 0;
    my @patch = { :op<replace>, :path(), :value(1) },;
    Crane.patch($x, @patch, :in-place);
    is $x, 1, 'Is expected value';
}

# end testing patch in Any }}}

# testing patch in Associative {{{

subtest
{
    # container root
    my %f = :right({:now<yes>});
    my @a = { :op<replace>, :path(), :value({:wrong({:later<no>})}) },;
    is-deeply Crane.patch(%f, @a), {:wrong({:later<no>})}, 'Is expected value';
    is-deeply %f, {:right({:now<yes>})}, 'Original container is unchanged';

    # 1 level deep
    my %h = :a<alpha>,:b<bravo>,:c<charlie>;
    my @b = { :op<replace>, :path('a',), :value<Alpha> },;
    is-deeply Crane.patch(%h, @b), {:a<Alpha>,:b<bravo>,:c<charlie>},
        'Is expected value';
    is-deeply %h, {:a<alpha>,:b<bravo>,:c<charlie>},
        'Original container is unchanged';

    # 2 levels deep
    my %j = :why({:do({:you(7)})});
    my @c = { :op<replace>, :path(qw<why do>), :value({:You<Always>}) },;
    is-deeply Crane.patch(%j, @c), {:why({:do({:You<Always>})})},
        'Is expected value';
    is-deeply %j, {:why({:do({:you(7)})})}, 'Original container is unchanged';

    # 3 levels deep
    my %l = :why({:do({:you({:always(7)})})});
    my @d = { :op<replace>, :path(qw<why do you>), :value({:Always<Kick>}) },;
    is-deeply Crane.patch(%l, @d), {:why({:do({:you({:Always<Kick>})})})},
        'Is expected value';
    is-deeply %l, {:why({:do({:you({:always(7)})})})},
        'Original container is unchanged';

    # 7 levels deep
    my %n = :why({:do({:you({:always({:kick({:me({:when({:im(7)})})})})})})});
    my @e =
        {
            :op<replace>,
            :path(qw<why do you always kick me when im>),
            :value<High>
        },;
    is-deeply Crane.patch(%n, @e),
        {:why({:do({:you({:always({:kick({:me({:when({:im<High>})})})})})})})},
        'Is expected value';
    is-deeply %n,
        {:why({:do({:you({:always({:kick({:me({:when({:im(7)})})})})})})})},
        'Original container is unchanged';
}

# end testing patch in Associative }}}

# testing patch in Positional {{{

subtest
{
    # container root
    my @a = qw<zero one two>;
    my @patch0 = { :op<replace>, :path(), :value([qw<Zero One Two>]) },;
    is-deeply Crane.patch(@a, @patch0), [qw<Zero One Two>], 'Is expected value';
    is-deeply @a, [qw<zero one two>], 'Original container is unchanged';

    # 1 level deep
    my @c = qw<zero one two>;
    my @patch1 = { :op<replace>, :path(0,), :value<Zero> },;
    is-deeply Crane.patch(@c, @patch1), [qw<Zero one two>], 'Is expected value';
    is-deeply @c, [qw<zero one two>], 'Original container is unchanged';

    # 2 levels deep
    my @e = [ ['she', 'cried'], ['more', 'more', 'more', 'more'] ];
    my @patch2 = { :op<replace>, :path(1, 3), :value<More> },;
    is-deeply Crane.patch(@e, @patch2),
        [ ['she', 'cried'], ['more', 'more', 'more', 'More'] ],
        'Is expected value';
    is-deeply @e, [ ['she', 'cried'], ['more', 'more', 'more', 'more'] ],
        'Original container unchanged';

    # 3 levels deep
    my @g = [ 'she', 'want', 'more', [ 'more', [ 'more', [ 'more' ] ] ] ];
    my @patch3 = { :op<replace>, :path(3, 1, 1), :value(['More']) },;
    is-deeply Crane.patch(@g, @patch3),
        ['she','want','more',['more',['more',['More']]]],
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
    my @patch4 =
        {
            :op<replace>,
            :path(1, 1, 1, 1, 1, 1, 1),
            :value(['want',['my',['mtv']]])
        },;
    is-deeply Crane.patch(@i, @patch4), @j-expected, 'Is expected value';
    is-deeply @i, @i-expected, 'Original container is unchanged';
}

# end testing patch in Positional }}}

# testing Exceptions {{{

subtest
{
    my %h = :a({:b({:c})});

    my @a = { :op<add>, :path(qw<d e f>), :value(1) },; # trailing comma needed
    throws-like {Crane.patch(%h, @a)}, X::Crane::Patch,
        :message(/'add failed'/),
        'Patch operation fails when add operation fails';

    my @b = { :op<remove>, :path(qw<d e f>) },;
    throws-like {Crane.patch(%h, @b)}, X::Crane::Patch,
        :message(/'remove failed'/),
        'Patch operation fails when remove operation fails';

    my @c = { :op<replace>, :path(qw<d e f>), :value(1) },;
    throws-like {Crane.patch(%h, @c)}, X::Crane::Patch,
        :message(/'replace failed'/),
        'Patch operation fails when replace operation fails';

    my @d = { :op<move>, :from['a'], :path(qw<a b c>) },;
    throws-like {Crane.patch(%h, @d)}, X::Crane::Patch,
        :message(/'move failed'/),
        'Patch operation fails when move operation fails';

    my @e = { :op<copy>, :from['a'], :path(qw<a b c>) },;
    throws-like {Crane.patch(%h, @e)}, X::Crane::Patch,
        :message(/'copy failed'/),
        'Patch operation fails when copy operation fails';

    my @f =
        { :op<replace>, :path(qw<a b c>), :value(42) },
        { :op<test>, :path(qw<a b c>), :value<C> };
    throws-like {Crane.patch(%h, @f)}, X::Crane::Patch,
        :message(/'test failed'/),
        'Patch operation fails when test operation fails';
}

# end testing Exceptions }}}

# testing documentation examples {{{

subtest
{
    my %h;
    my @a =
        { :op<add>, :path['a'], :value({:b({:c<here>})}) },
        { :op<add>, :path(qw<a b d>), :value([]) },
        { :op<add>, :path(|qw<a b d>, 0), :value<diamond> },
        { :op<replace>, :path(|qw<a b d>, *-1), :value<dangerous> },
        { :op<remove>, :path(qw<a b c>) },
        { :op<move>, :from(qw<a b d>), :path['d'] },
        { :op<copy>, :from(qw<a b>), :path['b'] },
        { :op<remove>, :path(qw<a b>) },
        { :op<replace>, :path['a'], :value(['alligators']) },
        { :op<replace>, :path['b'], :value(['be']) };
    my %i = Crane.patch(%h, @a);
    is-deeply %i, {:a(["alligators"]), :b(["be"]), :d(["dangerous"])},
        'Is expected value';
    is-deeply %h, {}, 'Original container is unchanged';

    my %data = %TestCrane::data;
    my %green-beans = :name("green beans"), :unit<lbs>, :instock(3);
    my %lima-beans = :name("lima beans"), :unit("lbs"), :instock(21);
    my %pinto-beans = :name("pinto beans"), :unit("lbs"), :instock(4);

    my @b =
        { :op<add>, :path('legumes', 0), :value(%green-beans) },
        { :op<test>, :path('legumes', 0), :value(%green-beans) };
    is-deeply Crane.patch(%data, @b)<legumes>[0], %green-beans,
        'Is expected value';

    my @c =
        { :op<remove>, :path('legumes', 0) },
        { :op<test>, :path('legumes', 0), :value(%lima-beans) };
    is-deeply Crane.patch(%data, @c)<legumes>[0], %lima-beans,
        'Is expected value';

    my @d =
    { :op<replace>, :path('legumes', 0), :value(%green-beans) },
        { :op<test>, :path('legumes', 0), :value(%green-beans) };
    is-deeply Crane.patch(%data, @d)<legumes>[0], %green-beans,
        'Is expected value';

    my @e =
        { :op<move>, :from('legumes', 0), :path('legumes', 1) },
        { :op<test>, :path('legumes', 0), :value(%lima-beans) },
        { :op<test>, :path('legumes', 1), :value(%pinto-beans) };
    my %data-a = Crane.patch(%data, @e);
    is-deeply %data-a<legumes>[0], %lima-beans, 'Is expected value';
    is-deeply %data-a<legumes>[1], %pinto-beans, 'Is expected value';

    my @f =
        { :op<copy>, :from('legumes', 0), :path('legumes', *-0) },
        { :op<test>, :path('legumes', 0), :value(%pinto-beans) },
        { :op<test>, :path('legumes', *-1), :value(%pinto-beans) };
    my %data-b = Crane.patch(%data, @f);
    is-deeply %data-b<legumes>[0], %pinto-beans, 'Is expected value';
    is-deeply %data-b<legumes>[*-1], %pinto-beans, 'Is expected value';
}

# end testing documentation examples }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
