use lib <lib>;
use Test;

use Proxee;
plan 8;

subtest 'coercer, variables' => {
    plan 4;

    my $v := Proxee.new: Int(Cool);
    throws-like { $v = Date.today }, X::TypeCheck, 'throws with incorrect type';

    $v = ' 42.12 ';
    is-deeply $v, 42, 'performs coercion';
    $v = 12;
    is-deeply $v, 12, 'accepts target type';
    $v = <72>;
    is-deeply $v, <72>, 'does not coerce subclasses of target type';
}

subtest 'coercer, attributes' => {
    plan 6;

    class Foo {
        has $.foo is rw;
        submethod TWEAK (:$foo) { ($!foo := Proxee.new: Int()) = $foo }
    }

    my $o = Foo.new: :foo('42.1e0');
    is-deeply $o.foo, 42, 'instantiation coercer';

    $o.foo = 12.42;
    is-deeply $o.foo,   12, 'assignment coercer';

    $o.foo = 72;
    is-deeply $o.foo, 72, 'assignment target type';
    $o.foo = <72>;
    is-deeply $o.foo, <72>, 'does not coerce subclasses of target type';

    throws-like { Foo.new: foo => Date.today }, X::Method::NotFound,
        'throws with incorrect type (instantiation)';
    throws-like { $o.foo = Date.today        }, X::Method::NotFound,
        'throws with incorrect type (assignment)';
}

subtest 'store, fetch (basic)' => {
    plan 4;

    my $store;
    my $v := Proxee.new: :FETCH{ $store }, :STORE{ $store := $_² };
    $v = 11;
    is-deeply $v,     121, 'fetched value after store (1)';
    is-deeply $store, 121, 'store var got updated (1)';

    $v = 13;
    is-deeply $v,     169, 'fetched value after store (2)';
    is-deeply $store, 169, 'store var got updated (2)';
}

subtest 'store, fetch (default fetch)' => {
    plan 2;

    my $v := Proxee.new: :STORE{ $*PROXEE = $_² };
    $v = 11;
    is-deeply $v, 121, 'fetched value after store (1)';

    $v = 13;
    is-deeply $v, 169, 'fetched value after store (2)';
}

subtest 'store, fetch (default store)' => {
    plan 2;

    my $v := Proxee.new: :FETCH{ $*PROXEE³ };
    $v = 11;
    is-deeply $v, 1331, 'fetched value after store (1)';

    $v = 13;
    is-deeply $v, 2197, 'fetched value after store (2)';
}

subtest 'store, fetch (default store, default fetch)' => {
    plan 2;

    my $v := Proxee.new;
    $v = 11;
    is-deeply $v, 11, 'fetched value after store (1)';

    $v = 13;
    is-deeply $v, 13, 'fetched value after store (2)';
}

subtest 'proxee' => {
    plan 3;

    my $v := Proxee.new: :PROXEE{ $_⁴ }, :FETCH{ $*PROXEE - 10 };
    $v = 11;
    is-deeply $v, 14631, 'fetched value after store (1)';

    $v = 13;
    is-deeply $v, 28551, 'fetched value after store (2)';

    throws-like { Proxee.new: :PROXEE{;}, :STORE{;}, :FETCH{;} },
        Proxee::X::CannotProxeeStore, ':PROXEE + :STORE + :FETCH{;} throws';
}

subtest 'proxee (default fetch)' => {
    plan 3;

    my $v := Proxee.new: :PROXEE{ $_⁶ };
    $v = 11;
    is-deeply $v, 1771561, 'fetched value after store (1)';

    $v = 13;
    is-deeply $v, 4826809, 'fetched value after store (2)';

    throws-like { Proxee.new: :PROXEE{;}, :STORE{;} },
        Proxee::X::CannotProxeeStore, ':PROXEE + :STORE throws';
}

done-testing;
