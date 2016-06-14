#!perl6

use v6.c;

use Test;

use URI::Template;

my URI::Template $tem = URI::Template.new();

my @templates = <
                    http://example.com/~{username}/
                    http://example.com/dictionary/{term:1}/{term}
                    http://example.com/zub/{things*}
                    http://example.com/search{?q,lang}
                    http://www.example.com/foo{?query,number}
                    http://www.example.com/foo{?query,number}
                 >;

for @templates -> $template {
    my $actions = URI::Template::Actions.new;
    ok my $res = URI::Template::Grammar.parse($template, :$actions), "matched '$template'";
    ok  any($res.made) ~~ URI::Template::Expression, "and we have made something with strings and expressions";
}

# tests of individual single arg forms

my @tests = (
{ expression => q/{var}/, operator => Str, explode => False, max-length => Int, description => "Simple variable no operator",},
{ expression => q/{+var}/, operator => "+", explode => False, max-length => Int, description => "reserved operator",},
{ expression => q/{#var}/, operator => "#", explode => False, max-length => Int, description => "fragment operator",},
{ expression => q/{.var}/, operator => ".", explode => False, max-length => Int, description => "suffix operator",},
{ expression => q/{;x}/, operator => ";", explode => False, max-length => Int, description => "Semicolon path operator",},
{ expression => q/{?x}/, operator => "?", explode => False, max-length => Int, description => "? query operator",},
{ expression => q/{&x}/, operator => "&", explode => False, max-length => Int, description => "Ampersand extend query",},
{ expression => q/{var:3}/, operator => Str, explode => False, max-length => 3, description => "No operator max-length set",},
{ expression => q/{list*}/, operator => Str, explode => True, max-length => Int, description => "Simple with explode",},
{ expression => q/{+path:6}/, operator => "+", explode => False, max-length => 6, description => "reserved operator with max-length",},
{ expression => q/{+list*}/, operator => "+", explode => True, max-length => Int, description => "Reserved operator with explode",},
{ expression => q/{#path:6}/, operator => "#", explode => False, max-length => 6, description => "fragment operator with max-length",},
{ expression => q/{#list*}/, operator => "#", explode => True, max-length => Int, description => "Fragment operator with explode",},
{ expression => q/{.var:3}/, operator => ".", explode => False, max-length => 3, description => "suffix operator with max-length",},
{ expression => q/{.list*}/, operator => ".", explode => True, max-length => Int, description => "Suffix operator with explode",},
{ expression => q/{;hello:5}/, operator => ";", explode => False, max-length => 5, description => "semi-colon operator with max-length",},
{ expression => q/{;list*}/, operator => ";", explode => True, max-length => Int, description => "semi-colon with explode",},
{ expression => q/{?var:3}/, operator => "?", explode => False, max-length => 3, description => "query operator with max-length",},
{ expression => q/{?list*}/, operator => "?", explode => True, max-length => Int, description => "query operator with explode",},
{ expression => q/{&var:3}/, operator => "&", explode => False, max-length => 3, description => "ampersand query extend with max-length",},
{ expression => q/{&list*}/, operator => "&", explode => True, max-length => Int, description => "ampersand query extend with explode",},
);

for @tests -> $test {
    subtest {
        my $actions = URI::Template::Actions.new;
        my $template = $test<expression>;
        ok my $res = URI::Template::Grammar.parse($template, :$actions), "matched '$template'";
        ok my $expr = $res.made[0], "got first bit";
        isa-ok $expr, URI::Template::Expression, "and it's an expression";
        is $expr.operator, $test<operator>, "got the right operator";
        ok my $var = $expr.variables[0], "get the (only) variable";
        isa-ok $var, URI::Template::Variable, "and it's a Variable";
        is $var.max-length, $test<max-length>, "correct max-length";
        is $var.explode, $test<explode>, "correct explode";

    }, $test<description>;
}

subtest {
    my $actions = URI::Template::Actions.new;
    my $template = '{+path}/here';
    ok my $res = URI::Template::Grammar.parse($template, :$actions), "matched '$template'";
    is $res.made.elems, 2, "expect two parts";
    is $res.made[1], '/here', "and got /here as we expected";

}, "special cases";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
