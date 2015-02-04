use Test;
use SP6;

plan 2;

my $templ_dir = 't/templ';

my $sp6 = SP6.new( :templ_dir($templ_dir), );
ok $sp6, 'new';
is $sp6.process(:tfpath<base.sp6>), 'foobar', 'base';
