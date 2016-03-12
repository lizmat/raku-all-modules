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
    ok Crane.test(%data, :path('legumes', 0, 'name'), :value("pinto beans")),
        'Is expected value';
    ok Crane.test(%data, :path('legumes', 0, 'instock'), :value(4)),
        'Is expected value';
    my @path = 'legumes', 1, 'instock';
    ok Crane.test(%data, :@path, :value(21)), 'Is expected value';
    sub getpath() { ('legumes', 2, 'instock') }
    ok Crane.test(%data, :path(getpath()), :value(13)), 'Is expected value';
    ok Crane.test(%data, :path('legumes', 3, 'instock'), :value(8)),
        'Is expected value';
    throws-like {Crane.test(%data, :path(qw<a b c>), :value(1))},
        X::Crane::TestPathNotFound,
        'Test operation fails when path not found';
}

# vim: ft=perl6 fdm=marker fdl=0
