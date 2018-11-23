
use v6;
use Test;
use Duo;

my \term  = Duo.new(1, 2);  # sigil-less
my $item  = Duo.new(1, 2);  # scalar
my $bind := Duo.new(1, 2);  # binding

my $i;

$i = 0; for  term -> $obj { $i++; is-deeply $obj,  term, 'eqv obj term' }; is $i, 1, 'one iteration term $obj';
$i = 0; for $item -> $obj { $i++; is-deeply $obj, $item, 'eqv obj item' }; is $i, 1, 'one iteration item $obj';
$i = 0; for $bind -> $obj { $i++; is-deeply $obj, $bind, 'eqv obj bind' }; is $i, 1, 'one iteration bind $obj';

$i = 0; for  term -> \obj { $i++; ok obj =:=  term, 'same obj term' }; is $i, 1, 'one iteration term \obj';
$i = 0; for $item -> \obj { $i++; ok obj =:= $item, 'same obj item' }; is $i, 1, 'one iteration item \obj';
$i = 0; for $bind -> \obj { $i++; ok obj =:= $bind, 'same obj bind' }; is $i, 1, 'one iteration bind \obj';

my @a;
@a = ( term,).map: { $_ }; is-deeply @a, [ term], 'term map';
@a = ($item,).map: { $_ }; is-deeply @a, [$item], 'item map';
@a = ($bind,).map: { $_ }; is-deeply @a, [$bind], 'bind map';

done-testing;

# my @a = o;
# my @b = o, o;
# 
# my %h = o;
# my %i = o, o;

# vim: ft=perl6
