use Test;
use Template::Protone;

plan 1;

my Template::Protone $p .=new; 
my $r = $p.render(:template<t/templates/recursion.protone>).trim;

ok $r eq "Factorial 5 = 120\n\nFactorial 4 = 24\n\nFactorial 3 = 6\n\nFactorial 2 = 2\n\nFactorial 1 = 1", 'Recursion test';
