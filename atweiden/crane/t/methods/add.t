use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 7;

# testing Any root container add operations {{{

subtest
{
    my $x;
    my $y = Crane.add($x, :path(), :value(1));
    is $y, 1, 'Is expected value';
    ok $x.isa(Any), 'Original container is unchanged';

    my $q;
    my $r = Crane.add($q, :path(), :value({:a<alpha>,:b<bravo>,:c<charlie>}));
    is $r<a>, 'alpha', 'Is expected value';
    is $r<b>, 'bravo', 'Is expected value';
    is $r<c>, 'charlie', 'Is expected value';
    ok $q.isa(Any), 'Original container is unchanged';

    my $n;
    my $o = Crane.add($n, :path(), :value(qw<zero one two>));
    is $o[0], 'zero', 'Is expected value';
    is $o[1], 'one', 'Is expected value';
    is $o[2], 'two', 'Is expected value';
    ok $n.isa(Any), 'Original container is unchanged';
}

# end testing Any root container add operations }}}

# testing Associative root container add operations {{{

subtest
{
    my %h;
    my %i = Crane.add(%h, :path(), :value({:a<alpha>,:b<bravo>,:c<charlie>}));
    is %i<a>, 'alpha', 'Is expected value';
    is %i<b>, 'bravo', 'Is expected value';
    is %i<c>, 'charlie', 'Is expected value';
    ok %h.elems == 0, 'Original container is unchanged';

    my Associative $t;
    my $u = Crane.add($t, :path(), :value({:a<alpha>,:b<bravo>,:c<charlie>}));
    is $u<a>, 'alpha', 'Is expected value';
    is $u<b>, 'bravo', 'Is expected value';
    is $u<c>, 'charlie', 'Is expected value';
    ok $t.isa(Any), 'Original container is unchanged';
}

# end testing Associative root container add operations }}}

# testing Associative deep container add operations {{{

subtest
{
    my %h = :level-one({:level-two({:level-three(3)})});
    my %i = Crane.add(
        %h,
        :path('level-one', 'level-two', 'is-level-two'),
        :value(True)
    );
    is %i<level-one><level-two><is-level-two>, True, 'Is expected value';
    is %i<level-one><level-two><level-three>, 3, 'Is expected value';
    is-deeply %h, {:level-one({:level-two({:level-three(3)})})},
        'Original container is unchanged';

    # test replacement of existing value
    my %j = Crane.add(
        %i,
        :path('level-one', 'level-two', 'is-level-two'),
        :value(['yes', 7])
    );
    is %j<level-one><level-two><is-level-two>, ['yes', 7], 'Is expected value';

    # test documentation examples
    my %data = %TestCrane::data;
    my %legume = :name<carrots>, :unit<lbs>, :instock(3);
    my %data-new = Crane.add(%data, :path('legumes', 0), :value(%legume));
    is-deeply %data-new<legumes>[0], {:name<carrots>, :unit<lbs>, :instock(3)},
        'Is expected value';
    is-deeply %data, %TestCrane::data, 'Original container unchanged';

    my %doc = :a({ :foo(1) });
    my %example = Crane.add(%doc, :path(qw<a b>), :value(0));
    is %example<a><b>, 0, 'Is expected value';
    is %example<a><foo>, 1, 'Is expected value';
    ok %doc.isa(Hash), 'Original container unchanged';
    is %doc<a><foo>, 1, 'Original container unchanged';
}

# end testing Associative deep container add operations }}}

# testing Positional root container add operations {{{

subtest
{
    my @a;
    my @b = Crane.add(@a, :path(), :value(qw<zero one two>));
    is @b[0], 'zero', 'Is expected value';
    is @b[1], 'one', 'Is expected value';
    is @b[2], 'two', 'Is expected value';
    my @c = Crane.add(@a, :path(), :value(True));
    is @c[0], True, 'Is expected value';
    ok @a.elems == 0, 'Original container is unchanged';

    my Positional $q;
    my $r = Crane.add($q, :path(), :value(qw<zero one two>));
    is $r[0], 'zero', 'Is expected value';
    is $r[1], 'one', 'Is expected value';
    is $r[2], 'two', 'Is expected value';
    my $s = Crane.add($q, :path(), :value(True));
    is $s[0], True, 'Is expected value';
    ok $q.isa(Any), 'Original container is unchanged';

    my Positional $t = qw<foo bar>;
    my $u = Crane.add($t, :path(), :value(qw<zero one two>));
    is $u[0], 'zero', 'Is expected value';
    is $u[1], 'one', 'Is expected value';
    is $u[2], 'two', 'Is expected value';
    my $v = Crane.add($t, :path(), :value(True));
    is $v[0], True, 'Is expected value';
    is-deeply $t, qw<foo bar>, 'Original container is unchanged';

    my Positional $w = [qw<foo bar>];
    my $x = Crane.add($w, :path(), :value(qw<zero one two>));
    is $x[0], 'zero', 'Is expected value';
    is $x[1], 'one', 'Is expected value';
    is $x[2], 'two', 'Is expected value';
    my $y = Crane.add($w, :path(), :value(True));
    is $y[0], True, 'Is expected value';
    is-deeply $w, [qw<foo bar>], 'Original container is unchanged';
}

# end testing Positional root container add operations }}}

# testing Positional deep container add operations {{{

subtest
{
    my @a =
        [
            [
                [ 'a', 'alpha' ],
                [ 'b', 'bravo' ],
                [ 'c', 'charlie' ]
            ],
            [
                [ 'd', 'delta' ],
                [ 'e', 'echo' ],
                [ 'f', 'foxtrot' ]
            ]
        ];
    my @b = Crane.add(
        @a,
        :path(*-0,),
        :value([ ['g', 'golf'], ['h', 'hotel'], ['i', 'india'] ])
    );
    my @b-expected =
        [
            [
                [ 'a', 'alpha' ],
                [ 'b', 'bravo' ],
                [ 'c', 'charlie' ]
            ],
            [
                [ 'd', 'delta' ],
                [ 'e', 'echo' ],
                [ 'f', 'foxtrot' ]
            ],
            [
                [ 'g', 'golf' ],
                [ 'h', 'hotel' ],
                [ 'i', 'india' ]
            ]
        ];
    is-deeply @b, @b-expected, 'Is expected value';
    is @b[0][0][0], 'a', 'Is expected value';
    is @b[0][0][1], 'alpha', 'Is expected value';
    is @b[0][1][0], 'b', 'Is expected value';
    is @b[0][1][1], 'bravo', 'Is expected value';
    is @b[0][2][0], 'c', 'Is expected value';
    is @b[0][2][1], 'charlie', 'Is expected value';
    is-deeply @a,
        [
            [
                [ 'a', 'alpha' ],
                [ 'b', 'bravo' ],
                [ 'c', 'charlie' ]
            ],
            [
                [ 'd', 'delta' ],
                [ 'e', 'echo' ],
                [ 'f', 'foxtrot' ]
            ]
        ],
        'Original container is unchanged';

    my %times =
        :am([
            # 12-hr time | 24-hr time
            ['12:00', '00:00'],
            ['1:00', '01:00'],
            ['2:00', '02:00'],
            ['3:00', '03:00'],
            ['4:00', '04:00'],
            ['5:00', '05:00'],
            ['6:00', '06:00'],
            ['7:00', '07:00'],
            ['8:00', '08:00'],
            ['9:00', '09:00'],
            ['10:00', '10:00'],
            ['11:00', '11:00'],
        ]),
        :pm([
            # 12-hr time | 24-hr time
            ['12:00', '12:00'],
            ['1:00', '13:00'],
            ['2:00', '14:00'],
            ['3:00', '15:00'],
            ['4:00', '16:00'],
            ['5:00', '17:00'],
            ['6:00', '18:00'],
            ['7:00', '19:00'],
            ['8:00', '20:00'],
            ['9:00', '21:00'],
            ['10:00', '22:00'],
            ['11:00', '23:00'],
        ]);

    my Range $am = 0..11;
    my Range $pm = 12..23;
    my %times-expected-am =
        :am([
            ["12:00", "00:00"],
            ["1:00", "01:00"],
            ["2:00", "02:00"],
            ["3:00", "03:00"],
            ["4:00", "04:00"],
            ["5:00", "05:00"],
            ["6:00", "06:00"],
            ["7:00", "07:00"],
            ["8:00", "08:00"],
            ["9:00", "09:00"],
            ["10:00", "10:00"],
            ["11:00", "11:00"],
            0..11
        ]),
        :pm([
            ["12:00", "12:00"],
            ["1:00", "13:00"],
            ["2:00", "14:00"],
            ["3:00", "15:00"],
            ["4:00", "16:00"],
            ["5:00", "17:00"],
            ["6:00", "18:00"],
            ["7:00", "19:00"],
            ["8:00", "20:00"],
            ["9:00", "21:00"],
            ["10:00", "22:00"],
            ["11:00", "23:00"]
        ]);

    my %times-expected-pm =
        :am([
            ["12:00", "00:00"],
            ["1:00", "01:00"],
            ["2:00", "02:00"],
            ["3:00", "03:00"],
            ["4:00", "04:00"],
            ["5:00", "05:00"],
            ["6:00", "06:00"],
            ["7:00", "07:00"],
            ["8:00", "08:00"],
            ["9:00", "09:00"],
            ["10:00", "10:00"],
            ["11:00", "11:00"]
        ]),
        :pm([
            ["12:00", "12:00"],
            ["1:00", "13:00"],
            ["2:00", "14:00"],
            ["3:00", "15:00"],
            ["4:00", "16:00"],
            ["5:00", "17:00"],
            ["6:00", "18:00"],
            ["7:00", "19:00"],
            ["8:00", "20:00"],
            ["9:00", "21:00"],
            ["10:00", "22:00"],
            ["11:00", 12..23, "23:00"]
        ]);

    my %times-modded-am = Crane.add(%times, :path('am', *-0), :value($am));
    my %times-modded-pm = Crane.add(%times, :path('pm', *-1, *-1), :value($pm));

    is-deeply %times-modded-am, %times-expected-am, 'Is expected value';
    is-deeply %times-modded-pm, %times-expected-pm, 'Is expected value';

    # test documentation example
    my @aa;
    my @bb = Crane.add(@aa, :path([]), :value<foo>);
    is @bb[0], 'foo', 'Is expected value';
    ok @aa.elems == 0, 'Original container unchanged';
}

# end testing Positional deep container add operations }}}

# testing Exceptions {{{

subtest
{
    # documentation example
    my %h = :q({ :bar(2) });
    throws-like {Crane.add(%h, :path(qw<a b>), :value(7))},
        X::Crane::AddPathNotFound,
        'Add operation fails when path not found';

    # A Pair is not a Hash
    my %i = :level-one(:level-two(:level-three(3)));
    throws-like
        {
            Crane.add(
                %i,
                :path('level-one', 'level-two', 'is-level-two'),
                :value(True)
            );
        },
        X::Crane::Add::RO,
        'Add operation fails when requests mutating immutable values';

    # cannot splice non-Array type
    my $list = qw<zero one two>;
    throws-like {Crane.add($list, :path(*-0,), :value<three>)},
        X::Crane::Add::RO,
        'Add operation fails when requests splicing List type';

    my @a = [qw<zero one two>];
    my %doc = :a([]);

    # invalid Positional index
    throws-like {Crane.add(@a, :path(-1,), :value(True))}, # invalid: Int < 0
        X::Crane::PositionalIndexInvalid,
        'Positional index invalid';
    throws-like {Crane.add(@a, :path('0',), :value(True))}, # invalid: Str
        X::Crane::PositionalIndexInvalid,
        'Positional index invalid';

    # path not found
    throws-like {Crane.add(%doc, :path('a', 0, 'b'), :value<barf>)},
        X::Crane::AddPathNotFound,
        'Add operation fails when path not found';

    # Positional index out of range
    throws-like {Crane.add(%doc, :path('a', *-2), :value<eight>)},
        X::Crane::AddPathOutOfRange,
        :message(
            /'add operation failed, Positional index out of range.'/
        ),
        'Add operation fails when positional index out of range';
    throws-like {Crane.add(%doc, :path('a', *-1), :value<eight>)},
        X::Crane::AddPathOutOfRange,
        :message(
            /'add operation failed, Positional index out of range.'/
        ),
        'Add operation fails when positional index out of range';
    throws-like {Crane.add(%doc, :path('a', 1), :value<eight>)},
        X::Crane::AddPathOutOfRange,
        :message(
            /'add operation failed, creating sparse Positional not allowed.'/
        ),
        'Add operation fails when attempts to create a sparse Positional';
    throws-like {Crane.add(%doc, :path('a', *+1), :value<eight>)},
        X::Crane::AddPathOutOfRange,
        :message(
            /'add operation failed, creating sparse Positional not allowed.'/
        ),
        'Add operation fails when attempts to create a sparse Positional';
    throws-like {Crane.add(%doc, :path('a', 8), :value<eight>)},
        X::Crane::AddPathOutOfRange,
        :message(
            /'add operation failed, creating sparse Positional not allowed.'/
        ),
        'Add operation fails when attempts to create a sparse Positional';
}

# end testing Exceptions }}}

# testing in-place modifications {{{

subtest
{
    my $x;
    Crane.add($x, :path(), :value(1), :in-place);
    is $x, 1, 'Is expected value';

    my $y = {:a<alpha>,:b<bravo>,:c<charlie>};
    Crane.add($y, :path('a',), :value<Alpha>, :in-place);
    Crane.add($y, :path('d',), :value<delta>, :in-place);
    is-deeply $y, {:a<Alpha>,:b<bravo>,:c<charlie>,:d<delta>},
        'Is expected value';

    my $z = [qw<zero one two>];
    Crane.add($z, :path(*-0,), :value<three>, :in-place);
    is-deeply $z, [qw<zero one two three>], 'Is expected value';

    my @a;
    Crane.add(@a, :path(), :value(qw<zero one two>), :in-place);
    is-deeply @a, [qw<zero one two>], 'Is expected value';

    my %h;
    Crane.add(%h, :path(), :value({:a(1)}), :in-place);
    is-deeply %h, {:a(1)}, 'Is expected value';

    my %i = :a({:b(:c([qw<zero one two>]))});
    Crane.add(%i, :path(qw<a b c>), :value(qw<zero one two three>), :in-place);
    is-deeply %i, {:a({:b(:c([qw<zero one two three>]))})}, 'Is expected value';

    my %data = %TestCrane::data;
    my %legume = :name<carrots>, :unit<lbs>, :instock(3);
    Crane.add(%data, :path('legumes', 0), :value(%legume), :in-place);
    is-deeply %data<legumes>[0], {:name<carrots>, :unit<lbs>, :instock(3)},
        'Is expected value';
}

# end testing in-place modifications }}}

# vim: ft=perl6 fdm=marker fdl=0
