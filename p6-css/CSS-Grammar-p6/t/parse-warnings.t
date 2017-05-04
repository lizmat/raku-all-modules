use v6;

use Test;

use CSS::Grammar::Test;
use CSS::Grammar::CSS1;
use CSS::Grammar::CSS21;
use CSS::Grammar::CSS3;
use CSS::Grammar::Actions;

my $css-sample = 't/parse-warnings.css'.IO.slurp;
my @lines = $css-sample.lines;
my %level-warnings = @lines.map({/^(\w+)\-warnings\:\s/ ?? (~$0 => $/.postmatch) !! Empty});

my $actions = CSS::Grammar::Actions.new;

for css1 => CSS::Grammar::CSS1,
    css21 => CSS::Grammar::CSS21,
    css3 => CSS::Grammar::CSS3 {

    my ($test, $class) = .kv;

    $actions.reset;     
    my $p1 = $class.parse( $css-sample, :$actions);
    ok $p1, $test ~ ' parse';

    my $expected-warnings = %level-warnings{$test};
    my $actual-warnings = ~$actions.warnings;
    todo "issue #4";
    is $actual-warnings, $expected-warnings, $test ~ ' warnings';
}

done-testing;
