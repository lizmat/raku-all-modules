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
    is Crane.exists(%data, :path(), :v), True, 'Exists';
    is Crane.exists(%data, :path('legumes',)), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 0)), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 0, 'instock')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 0, 'name')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 0, 'unit')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 1)), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 1, 'instock')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 1, 'name')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 1, 'unit')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 2)), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 2, 'instock')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 2, 'name')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 2, 'unit')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 3)), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 3, 'instock')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 3, 'name')), True, 'Exists';
    is Crane.exists(%data, :path('legumes', 3, 'unit')), True, 'Exists';

    my @a = 'she', 'want', 'more', [ 'more', [ 'more', [ 'more' ] ] ];
    is Crane.exists(@a, :path(2,1,1,*-1)), False, 'Does not exist';
    is Crane.exists(@a, :path(2,1,1,*-1), :v), False, 'Does not exist';

    my %h = :a<alpha>,:b<bravo>,:c<charlie>;
    is Crane.exists(%h, :path(qw<d e f>)), False, 'Does not exist';
    is Crane.exists(%h, :path(qw<a alpha foo>)), False, 'Does not exist';
    is Crane.exists(%h, :path(qw<a alpha foo bar>)), False, 'Does not exist';
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
