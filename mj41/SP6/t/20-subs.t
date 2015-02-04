use Test;
use SP6;

plan 1;

my $templ_dir = 't/templ';
my $sp6 = SP6.new( :templ_dir($templ_dir), );
is $sp6.process(:tfpath<subs.sp6>), 'some-text', 'esc sub';
