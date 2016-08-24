use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 6;

# testing remove from Any {{{

subtest
{
    my $x = 0;
    my $y = Crane.remove($x, :path());
    is $y, Any, 'Is expected value';
    is $x, 0, 'Original container is unchanged';
}

# end testing remove from Any }}}

# testing remove from Associative {{{

subtest
{
    # container root
    my %f = :right({:now<yes>});
    my %g = Crane.remove(%f, :path());
    is-deeply %g, {}, 'Is expected value';
    is-deeply %f, {:right({:now<yes>})}, 'Original container is unchanged';

    # 1 level deep
    my %h = :a<alpha>,:b<bravo>,:c<charlie>;
    my %i = Crane.remove(%h, :path('a',));
    is-deeply %i, {:b<bravo>,:c<charlie>}, 'Is expected value';
    is-deeply %h, {:a<alpha>,:b<bravo>,:c<charlie>},
        'Original container is unchanged';

    # 2 levels deep
    my %j = :why({:do({:you(7)})});
    my %k = Crane.remove(%j, :path(qw<why do>));
    is-deeply %k, {:why({})}, 'Is expected value';
    is-deeply %j, {:why({:do({:you(7)})})}, 'Original container is unchanged';

    # 3 levels deep
    my %l = :why({:do({:you({:always(7)})})});
    my %m = Crane.remove(%l, :path(qw<why do you>));
    is-deeply %m, {:why({:do({})})}, 'Is expected value';
    is-deeply %l, {:why({:do({:you({:always(7)})})})},
        'Original container is unchanged';

    # 7 levels deep
    my %n = :why({:do({:you({:always({:kick({:me({:when({:im(7)})})})})})})});
    my %o = Crane.remove(%n, :path(qw<why do you always kick me when>));
    is-deeply %o, {:why({:do({:you({:always({:kick({:me({})})})})})})},
        'Is expected value';
    is-deeply %n,
        {:why({:do({:you({:always({:kick({:me({:when({:im(7)})})})})})})})},
        'Original container is unchanged';
}

# end testing remove from Associative }}}

# testing remove from Positional {{{

subtest
{
    # container root
    my @a = qw<zero one two>;
    my @b = Crane.remove(@a, :path());
    is-deeply @b, [], 'Is expected value';
    is-deeply @a, [qw<zero one two>], 'Original container is unchanged';

    # 1 level deep
    my @c = qw<zero one two>;
    my @d = Crane.remove(@c, :path(0,));
    is-deeply @d, [qw<one two>], 'Is expected value';
    is-deeply @c, [qw<zero one two>], 'Original container is unchanged';

    # 2 levels deep
    my @e = [ ['she', 'cried'], ['more', 'more', 'more', 'more'] ];
    my @f = Crane.remove(@e, :path(1, 3));
    is-deeply @f, [ ['she', 'cried'], ['more', 'more', 'more'] ],
        'Is expected value';
    is-deeply @e, [ ['she', 'cried'], ['more', 'more', 'more', 'more'] ],
        'Original container unchanged';

    # 3 levels deep
    my @g = [ 'she', 'want', 'more', [ 'more', [ 'more', [ 'more' ] ] ] ];
    my @h = Crane.remove(@g, :path(3, 1, 1));
    is-deeply @h, ['she','want','more',['more',['more']]],
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
        [ 'i', [ 'want', [ 'my', [ 'i', [ 'want', [ 'my', [ 'i' ] ] ] ] ] ] ];
    my @j = Crane.remove(@i, :path(1, 1, 1, 1, 1, 1, 1));
    is-deeply @j, @j-expected, 'Is expected value';
    is-deeply @i, @i-expected, 'Original container is unchanged';
}

# end testing remove from Positional }}}

# testing Exceptions {{{

subtest
{
    my %h = :a<alpha>,:b<bravo>,:c<charlie>;
    throws-like {Crane.remove(%h, :path('d',))}, X::Crane::RemovePathNotFound,
        'Remove operation fails when path not found';
    my %i = :a(:b(:c(True)));
    throws-like {Crane.remove(%i, :path(qw<a b c>))}, X::Crane::Remove::RO,
        'Remove operation fails when target is immutable';
    my @a = qw<zero one two>;
    throws-like {Crane.remove(@a, :path(*-0,))}, X::Crane::RemovePathNotFound,
        'Remove operation fails when path not found';
    my $list = (qw<zero one two>);
    throws-like {Crane.remove($list, :path(0,))}, X::Crane::Remove::RO,
        'Remove operation fails when target is immutable';
    throws-like {Crane.remove($list, :path(9,))}, X::Crane::RemovePathNotFound,
        'Remove operation fails when path not found';
    throws-like {Crane.remove($list, :path('d',))},
        X::Crane::PositionalIndexInvalid,
        'Remove operation fails when Positional index invalid';
}

# end testing Exceptions }}}

# testing documentation examples {{{

subtest
{
    my %h = :example<hello>;
    my %h2 = Crane.remove(%h, :path(['example']));
    is-deeply %h2, {}, 'Is expected value';
    is-deeply %h, {:example<hello>}, 'Original container is unchanged';

    my %i = :a({:b({:c(True)})});
    my %j = %i.deepmap(*.clone);
    %j<a><b>:delete;
    my %k = Crane.remove(%i, :path(qw<a b>));
    is-deeply %j, %k, 'Is expected value';
    is-deeply %i, {:a({:b({:c(True)})})}, 'Original container is unchanged';

    my $a = [1, 2, 3];
    my $b = Crane.remove($a, :path([]));
    # XXX Slip?
    # tried multi dispatch with .VAR.isa(Scalar) assigning Nil but multi
    # dispatch caught Array types
    # suspect this has to do with use of sigilless variable \container
    is-deeply $b, slip(), 'Is expected value';
    is-deeply $a, [1, 2, 3], 'Original container unchanged';
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
            }
        ]);
    Crane.remove(%data, :path('legumes', *-1), :in-place);
    is-deeply %data, %expected, 'Is expected value';
}

# end testing in-place modifications }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
