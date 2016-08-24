use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 1;

subtest
{
    my %data = %TestCrane::data;

    is-deeply Crane.get(%data, :path()), %data,
        'Get operation on root container value succeeds';
    throws-like {Crane.get(%data, :path(), :k)}, X::Crane::GetRootContainerKey,
        'Get operation on root container key fails';
    throws-like {Crane.get(%data, :path(), :p)}, X::Crane::GetRootContainerKey,
        'Get operation on root container pair fails';
    throws-like {Crane.get(%data, :path(qw<legumes foo>))},
        X::Crane::PositionalIndexInvalid,
        'Get operation on invalid positional index fails';
    throws-like {Crane.get(%data, :path('foo',))}, X::Crane::GetPathNotFound,
        'Get operation on nonexistent path fails';
    throws-like {Crane.get(%data, :path('legumes', 99))},
        X::Crane::GetPathNotFound,
        'Get operation on nonexistent path fails';
    throws-like {Crane.get(%data, :path('legumes', 0, 'bar'))},
        X::Crane::GetPathNotFound,
        'Get operation on nonexistent path fails';
    is-deeply Crane.get(%data, :path('legumes',)), %data<legumes>,
        'Is expected value';
    is-deeply Crane.get(%data, :path('legumes',), :k), %data<legumes>:!k,
        'Is expected key';
    is-deeply Crane.get(%data, :path('legumes',), :p), %data<legumes>:!p,
        'Is expected pair';
    is-deeply Crane.get(%data, :path('legumes', 0)), %data<legumes>[0],
        'Is expected value';
    is-deeply Crane.get(%data, :path('legumes', 0), :k), %data<legumes>[0]:!k,
        'Is expected key';
    is-deeply Crane.get(%data, :path('legumes', 0), :p), %data<legumes>[0]:!p,
        'Is expected pair';
    is Crane.get(%data, :path('legumes', 0, 'instock')), 4,
        'Is expected value';
    is Crane.get(%data, :path('legumes', 0, 'instock'), :k), 'instock',
        'Is expected key';
    is Crane.get(%data, :path('legumes', 0, 'instock'), :p), {:instock(4)},
        'Is expected pair';
    is Crane.get(%data, :path('legumes', 0, 'name')), 'pinto beans',
        'Is expected value';
    is Crane.get(%data, :path('legumes', 0, 'name'), :k), 'name',
        'Is expected key';
    is Crane.get(%data, :path('legumes', 0, 'name'), :p), {:name<pinto beans>},
        'Is expected pair';
    is Crane.get(%data, :path('legumes', 0, 'unit')), 'lbs',
        'Is expected value';
    is Crane.get(%data, :path('legumes', 0, 'unit'), :k), 'unit',
        'Is expected key';
    is Crane.get(%data, :path('legumes', 0, 'unit'), :p), {:unit<lbs>},
        'Is expected pair';
    is Crane.get(%data, :path('legumes', *-1, 'name')), 'split peas',
        'Is expected value';
    my @path = 'legumes', *-2, 'name';
    is Crane.get(%data, :@path), 'black eyed peas',
        'Is expected value';

    my %toml = :a({:b({:c<doh>})});
    throws-like {Crane.get(%toml, :path(qw<a b c d>))},
        X::Crane::GetPathNotFound,
        'Get operation fails when path not found';
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
