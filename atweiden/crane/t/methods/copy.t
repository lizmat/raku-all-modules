use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 6;

# testing copy in Any {{{

subtest
{
    my $x = 0;
    my $y = Crane.copy($x, :from(), :path());
    is $y, 0, 'Is expected value';
    is $x, 0, 'Original container is unchanged';
}

# end testing copy in Any }}}

# testing copy in Associative {{{

subtest
{
    my %h = :t({:doc({:exp(7)})});
    my %i = Crane.copy(%h, :from(qw<t doc exp>), :path(qw<t doc seven>));
    is-deeply %i, {:t({:doc({:exp(7),:seven(7)})})}, 'Is expected value';
    is-deeply %h, {:t({:doc({:exp(7)})})}, 'Original container is unchanged';
    my %j = Crane.copy(%h, :from('t',), :path('t',));
    is-deeply %j, {:t({:doc({:exp(7)})})}, 'Is expected value';
    is-deeply %h, {:t({:doc({:exp(7)})})}, 'Original container is unchanged';
    my %k = Crane.copy(%h, :from(), :path());
    is-deeply %k, {:t({:doc({:exp(7)})})}, 'Is expected value';
    is-deeply %h, {:t({:doc({:exp(7)})})}, 'Original container is unchanged';
    my %l = Crane.copy(%h, :from(qw<t doc>), :path('q',));
    is-deeply %l, {:t({:doc({:exp(7)})}),:q({:exp(7)})}, 'Is expected value';
    is-deeply %h, {:t({:doc({:exp(7)})})}, 'Original container is unchanged';
    my %m = Crane.copy(%h, :from(qw<t doc>), :path(qw<t q>));
    is-deeply %m, {:t({:doc({:exp(7)}),:q({:exp(7)})})}, 'Is expected value';
    is-deeply %h, {:t({:doc({:exp(7)})})}, 'Original container is unchanged';
}

# end testing copy in Associative }}}

# testing copy in Positional {{{

subtest
{
    my @a = 'she', 'want', 'more', [ 'more', [ 'more', [ 'more' ] ] ];
    my @b = Crane.copy(@a, :from(), :path());
    is-deeply @b, ['she','want','more',['more',['more',['more']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @c = Crane.copy(@a, :from(0,), :path(1,));
    is-deeply @c, ['she','she','want','more',['more',['more',['more']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @d = Crane.copy(@a, :from(1,), :path(0,));
    is-deeply @d, ['want','she','want','more',['more',['more',['more']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @e = Crane.copy(@a, :from(1,), :path(3,1,1,1));
    is-deeply @e, ['she','want','more',['more',['more',['more','want']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @f = Crane.copy(@a, :from(1,), :path(3,1,1,*-0));
    is-deeply @f, ['she','want','more',['more',['more',['more','want']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @g = Crane.copy(@a, :from(1,), :path(3,1,1,*-1));
    is-deeply @g, ['she','want','more',['more',['more',['want','more']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @h = Crane.copy(@a, :from(*-1,), :path(*-0,));
    is-deeply @h, ['she','want','more',['more',['more',['more']]],['more',['more',['more']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
}

# end testing copy in Positional }}}

# testing Exceptions {{{

subtest
{
    # X::Crane::CopyParentToChild
    my %h = :a({:b({:c({:d({:e(True)})})})});
    throws-like {Crane.copy(%h, :from(), :path('a',))},
        X::Crane::CopyParentToChild,
        'Not allowed to copy parent into child';
    throws-like {Crane.copy(%h, :from(), :path('a', 'b'))},
        X::Crane::CopyParentToChild,
        'Not allowed to copy parent into child';
    throws-like {Crane.copy(%h, :from('a',), :path('a', 'b'))},
        X::Crane::CopyParentToChild,
        'Not allowed to copy parent into child';
    throws-like {Crane.copy(%h, :from('a',), :path('a', 'b', 'c'))},
        X::Crane::CopyParentToChild,
        'Not allowed to copy parent into child';
    throws-like {Crane.copy(%h, :from('a', 'b'), :path('a', 'b', 'c'))},
        X::Crane::CopyParentToChild,
        'Not allowed to copy parent into child';
    throws-like {Crane.copy(%h, :from('a', 'b'), :path('a', 'b', 'c', 'd'))},
        X::Crane::CopyParentToChild,
        'Not allowed to copy parent into child';
    throws-like {Crane.copy(%h, :from('a', 'b', 'c'), :path('a', 'b', 'c', 'd'))},
        X::Crane::CopyParentToChild,
        'Not allowed to copy parent into child';
    throws-like {Crane.copy(%h, :from('a', 'b', 'c'), :path('a', 'b', 'c', 'd', 'e'))},
        X::Crane::CopyParentToChild,
        'Not allowed to copy parent into child';

    # X::Crane::CopyFromNotFound
    my %i = :a([qw<zero one two>]);
    throws-like {Crane.copy(%i, :from('a', *-0), :path('b',))},
        X::Crane::CopyFromNotFound, 'Copy operation fails when from not found';

    # X::Crane::CopyPathNotFound
    throws-like {Crane.copy(%i, :from('a', 0), :path('foo', 'bar'))},
        X::Crane::CopyPathNotFound, 'Copy operation fails when path not found';

    # X::Crane::CopyPath::RO
    my %k =
        :immutable({:list({:here(qw<a list is not an array>)})}),
        :mutable({:array({:here([qw<zero one two>])})});
    throws-like
    {
        Crane.copy(
            %k,
            :from('mutable', 'array', 'here', 0),
            :path('immutable', 'list', 'here', 0)
        )
    }, X::Crane::CopyPath::RO, 'Copy operation fails when path is immutable';

    # X::Crane::PositionalIndexInvalid
    throws-like {Crane.copy(%i, :from('a', 'b'), :path('b',))},
        X::Crane::PositionalIndexInvalid, 'Positional index invalid';

    my %doc = :a([qw<zero one two>]);

    # Positional index of path out of range
    throws-like {Crane.copy(%doc, :from('a', 1), :path('a', *-20))},
        X::Crane::CopyPathOutOfRange,
        :message(
            /'copy operation failed, Positional index out of range.'/
        ),
        'Copy operation fails when positional index out of range';
    throws-like {Crane.copy(%doc, :from('a', 1), :path('a', 20))},
        X::Crane::CopyPathOutOfRange,
        :message(
            /'copy operation failed, creating sparse Positional not allowed.'/
        ),
        'Copy operation fails when attempts to create a sparse Positional';
    throws-like {Crane.copy(%doc, :from('a', 1), :path('a', *+1))},
        X::Crane::CopyPathOutOfRange,
        :message(
            /'copy operation failed, creating sparse Positional not allowed.'/
        ),
        'Copy operation fails when attempts to create a sparse Positional';
}

# end testing Exceptions }}}

# testing documentation examples {{{

subtest
{
    my %h = :example<hello>;
    my %h2 = Crane.copy(%h, :from(['example']), :path(['sample']));
    is-deeply %h2, {:example("hello"), :sample("hello")}, 'Is expected value';
    is-deeply %h, {:example("hello")}, 'Original container is unchanged';
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
                :instock(8),
                :name("split peas"),
                :unit("lbs")
            }
        ]);
    Crane.copy(
        %data,
        :from('legumes', 0),
        :path('legumes', 1),
        :in-place
    );
    is-deeply %data, %expected, 'Is expected value';
}

# end testing in-place modifications }}}

# vim: ft=perl6 fdm=marker fdl=0
