use Test;
use lib 'lib';
use Pod::Perl5::Grammar;

plan 4;

use Pod::Perl5::ToHTML; pass 'Import ToHTML';

my $pod = 'test-corpus/readme_example.pod'.IO.slurp;
my $target_html = 'test-corpus/output.html'.IO.slurp;

ok my $actions = Pod::Perl5::ToHTML.new(output_string => ''), 'constructor';
ok Pod::Perl5::Grammar.parse($pod, :$actions), 'convert string to html';
is $actions.output_string, $target_html, 'Generated html matches expected';
