use v6;
use Test;
plan *;
use Math::Quaternion;

sub mqn { "Math::Quaternion.new(r => $^a, i => $^b, j => $^c, k => $^d)" }

{
    my $q;
    lives_ok { $q = Math::Quaternion.new },          'Bare Quat: .new';
    is $q.Str,  '0 + 0i + 0j + 0k',                  'Bare Quat: .Str';
    is $q.perl, mqn( 0, 0, 0, 0),                    'Bare Quat: .perl';
}
{
    my $q;
    lives_ok { $q = Math::Quaternion.unit },         'Unit Quat: .new';
    is $q.Str,  '1 + 0i + 0j + 0k',                  'Unit Quat: .Str';
    is $q.perl, mqn( 1, 0, 0, 0 ),                   'Unit Quat: .perl';
}
{
    my $q;
    lives_ok { $q = Math::Quaternion.new(3) },       'Real Quat: .new';
    is $q.Str, '3 + 0i + 0j + 0k',                   'Real Quat: .Str';
    is $q.perl, mqn( 3, 0, 0, 0 ),                   'Real Quat: .perl';
}
{
    my $q;
    lives_ok { $q = Math::Quaternion.new(3,4,5,6) }, 'Full Quat: .new';
    is $q.Str, '3 + 4i + 5j + 6k',                   'Full Quat: .Str';
    is $q.perl, mqn( 3, 4, 5, 6 ),                   'Full Quat: .perl';
}
{
    my $q;
    lives_ok { $q = Math::Quaternion.new(8+9i) },    'Complex Quat: .new';
    is $q.Str, '8 + 9i + 0j + 0k',                   'Complex Quat: .Str';
    ok $q eqv Math::Quaternion.new(8,9,0,0),         'Complex Quat:  eqv';
    is $q.perl, mqn( '8e0', '9e0', 0, 0 ),           'Complex Quat: .perl';
}

done;
# vim: ft=perl6
