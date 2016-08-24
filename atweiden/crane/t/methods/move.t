use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 5;

# testing move in Any {{{

subtest
{
    my $x = 0;
    my $y = Crane.move($x, :from(), :path());
    is $y, 0, 'Is expected value';
    is $x, 0, 'Original container is unchanged';
}

# end testing move in Any }}}

# testing move in Associative {{{

subtest
{
    my %h = :t({:doc({:exp(7)})});
    my %i = Crane.move(%h, :from(qw<t doc exp>), :path(qw<t doc seven>));
    is-deeply %i, {:t({:doc({:seven(7)})})}, 'Is expected value';
    is-deeply %h, {:t({:doc({:exp(7)})})}, 'Original container is unchanged';
    my %j = Crane.move(%h, :from('t',), :path('t',));
    is-deeply %j, {:t({:doc({:exp(7)})})}, 'Is expected value';
    is-deeply %h, {:t({:doc({:exp(7)})})}, 'Original container is unchanged';
    my %k = Crane.move(%h, :from(), :path());
    is-deeply %k, {:t({:doc({:exp(7)})})}, 'Is expected value';
    is-deeply %h, {:t({:doc({:exp(7)})})}, 'Original container is unchanged';
    my %l = Crane.move(%h, :from(qw<t doc>), :path('q',));
    is-deeply %l, {:t({}),:q({:exp(7)})}, 'Is expected value';
    is-deeply %h, {:t({:doc({:exp(7)})})}, 'Original container is unchanged';
    my %m = Crane.move(%h, :from(qw<t doc>), :path(qw<t q>));
    is-deeply %m, {:t({:q({:exp(7)})})}, 'Is expected value';
    is-deeply %h, {:t({:doc({:exp(7)})})}, 'Original container is unchanged';
}

# end testing move in Associative }}}

# testing move in Positional {{{

subtest
{
    my @a = 'she', 'want', 'more', [ 'more', [ 'more', [ 'more' ] ] ];
    my @b = Crane.move(@a, :from(), :path());
    is-deeply @b, ['she','want','more',['more',['more',['more']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @c = Crane.move(@a, :from(0,), :path(1,));
    is-deeply @c, ['want','she','more',['more',['more',['more']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @d = Crane.move(@a, :from(1,), :path(0,));
    is-deeply @d, ['want','she','more',['more',['more',['more']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @e = Crane.move(@a, :from(1,), :path(2,1,1,1));
    is-deeply @e, ['she','more',['more',['more',['more', 'want']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @f = Crane.move(@a, :from(1,), :path(2,1,1,*-0));
    is-deeply @f, ['she','more',['more',['more',['more', 'want']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @g = Crane.move(@a, :from(1,), :path(2,1,1,*-1));
    is-deeply @g, ['she','more',['more',['more',['want', 'more']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
    my @h = Crane.move(@a, :from(*-1,), :path(*-0,));
    is-deeply @h, ['she','want','more',['more',['more',['more']]]],
        'Is expected value';
    is-deeply @a, ['she','want','more',['more',['more',['more']]]],
        'Original container is unchanged';
}

# end testing move in Positional }}}

# testing Exceptions {{{

subtest
{
    # X::Crane::MoveParentToChild
    my %h = :a({:b({:c({:d({:e(True)})})})});
    throws-like {Crane.move(%h, :from(), :path('a',))},
        X::Crane::MoveParentToChild,
        'Not allowed to move parent into child';
    throws-like {Crane.move(%h, :from(), :path('a', 'b'))},
        X::Crane::MoveParentToChild,
        'Not allowed to move parent into child';
    throws-like {Crane.move(%h, :from('a',), :path('a', 'b'))},
        X::Crane::MoveParentToChild,
        'Not allowed to move parent into child';
    throws-like {Crane.move(%h, :from('a',), :path('a', 'b', 'c'))},
        X::Crane::MoveParentToChild,
        'Not allowed to move parent into child';
    throws-like {Crane.move(%h, :from('a', 'b'), :path('a', 'b', 'c'))},
        X::Crane::MoveParentToChild,
        'Not allowed to move parent into child';
    throws-like {Crane.move(%h, :from('a', 'b'), :path('a', 'b', 'c', 'd'))},
        X::Crane::MoveParentToChild,
        'Not allowed to move parent into child';
    throws-like {Crane.move(%h, :from('a', 'b', 'c'), :path('a', 'b', 'c', 'd'))},
        X::Crane::MoveParentToChild,
        'Not allowed to move parent into child';
    throws-like {Crane.move(%h, :from('a', 'b', 'c'), :path('a', 'b', 'c', 'd', 'e'))},
        X::Crane::MoveParentToChild,
        'Not allowed to move parent into child';

    # X::Crane::MoveFromNotFound
    my %i = :a([qw<zero one two>]);
    throws-like {Crane.move(%i, :from('a', *-0), :path('b',))},
        X::Crane::MoveFromNotFound, 'Move operation fails when from not found';

    # X::Crane::MovePathNotFound
    throws-like {Crane.move(%i, :from('a', 0), :path('foo', 'bar'))},
        X::Crane::MovePathNotFound, 'Move operation fails when path not found';

    # X::Crane::MoveFrom::RO
    my %j = :a(:pair(:is(:not(:a<hash>))));
    throws-like {Crane.move(%j, :from(qw<a pair is not a>), :path('hash',))},
        X::Crane::MoveFrom::RO, 'Move operation fails when from is immutable';

    # X::Crane::MovePath::RO
    my %k =
        :immutable({:list({:here(qw<a list is not an array>)})}),
        :mutable({:array({:here([qw<zero one two>])})});
    throws-like
    {
        Crane.move(
            %k,
            :from('mutable', 'array', 'here', 0),
            :path('immutable', 'list', 'here', 0)
        )
    }, X::Crane::MovePath::RO, 'Move operation fails when path is immutable';

    # X::Crane::PositionalIndexInvalid
    throws-like {Crane.move(%i, :from('a', 'b'), :path('b',))},
        X::Crane::PositionalIndexInvalid, 'Positional index invalid';

    my %doc = :a([qw<zero one two>]);

    # Positional index of path out of range
    throws-like {Crane.move(%doc, :from('a', 1), :path('a', *-20))},
        X::Crane::MovePathOutOfRange,
        :message(
            /'move operation failed, Positional index out of range.'/
        ),
        'Move operation fails when positional index out of range';
    throws-like {Crane.move(%doc, :from('a', 1), :path('a', 20))},
        X::Crane::MovePathOutOfRange,
        :message(
            /'move operation failed, creating sparse Positional not allowed.'/
        ),
        'Move operation fails when attempts to create a sparse Positional';
    throws-like {Crane.move(%doc, :from('a', 1), :path('a', *+1))},
        X::Crane::MovePathOutOfRange,
        :message(
            /'move operation failed, creating sparse Positional not allowed.'/
        ),
        'Move operation fails when attempts to create a sparse Positional';
}

# end testing Exceptions }}}

# testing in-place modifications {{{

subtest
{
    my %data = %TestCrane::data;
    my %expected = :legumes([
        {
            :instock(21),
            :name("lima beans"),
            :unit("lbs")
        },
        {
            :instock(4),
            :name("pinto beans"),
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
    Crane.move(
        %data,
        :from('legumes', 0),
        :path('legumes', 1),
        :in-place
    );
    is-deeply %data, %expected, 'Is expected value';
}

# end testing in-place modifications }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
