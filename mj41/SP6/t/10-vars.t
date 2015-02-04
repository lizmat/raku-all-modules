use Test;
use SP6;

plan 1;

my $templ_dir = 't/templ';
my $sp6 = SP6.new( :templ_dir($templ_dir), );

is
	$sp6.process(:tfpath<vars.sp6>),
	'line 1 - a
line 2 - b
line 3 - 42 - my@email.cz
line 4 - varB-text - $not_Qc
line 5',
	'vars';
