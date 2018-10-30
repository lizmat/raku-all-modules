#!/usr/bin/env perl6
use v6;
use Test;

use CSS::Grammar::CSS3;
use CSS::Grammar::Actions;

use CSS::Grammar::Test;

my %expected = ast => Mu;

my $test-css = %*ENV<CSS_TEST_FILE>;
if $test-css {
    diag "loading $test-css";
    %expected<warnings> = Mu;
}
else {
    $test-css = 't/jquery-ui-themeroller.css';
    diag "loading $test-css (set \$CSS_TEST_FILE to override)";
}

my $actions = CSS::Grammar::Actions.new;

my $css-body = $test-css.IO.slurp;

diag "...parsing...";

temp $/ = CSS::Grammar::Test::parse-tests(CSS::Grammar::CSS3, $css-body,
                                            :suite('css3 file'),
                                            :$actions,
                                            :%expected);

ok($/, "parsed css content ($test-css)")
    or die "parse failed - can't continue";

ok $/.ast.defined, "AST produced";

diag "...dumping...";
note $/.ast.perl;

done;
