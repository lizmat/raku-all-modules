use v6.c;
use Test;
use Trait::Env;
use lib "{$*PROGRAM.dirname}/lib";
use Config;

class TestClass {
    has $.attribute is env;
    has $.ATTRIBUTE is env;
    has $.dash-to-underscore is env;
    has $.dash_to_underscore is env;
    has Int $.int is env;
    has Bool $.bool is env;
    has Str $.str is env;
}

subtest {
    temp %*ENV = { "ATTRIBUTE" => "Here" };

    my $tc;
    ok $tc = TestClass.new(), "Test Class created OK";
    is $tc.attribute, "Here", "We have a test value";
    is $tc.ATTRIBUTE, "Here", "We have a test value (uc WORKS)";

}, "Basic Test Class. ENV Var exists";

subtest {
    temp %*ENV = {};

    my $tc;
    ok $tc = TestClass.new(), "Test Class created OK";
    is $tc.attribute, Any, "Test value is undefined";   

}, "Basic Test Class. ENV Var not set";

subtest {
    temp %*ENV = { "DASH_TO_UNDERSCORE" => "Worked" };

    my $tc;
    ok $tc = TestClass.new(), "Test Class created OK";
    is $tc.dash-to-underscore, "Worked", "Dashes converted";
    is $tc.dash_to_underscore, "Worked", "Underscore version works too.";

}, "Dashes -> Underscores";

subtest {
    temp %*ENV = { INT => "5", BOOL => "", STR => "String" };
   
    my $tc;
    ok $tc = TestClass.new(), "Test Class created OK";
    is $tc.int, 5, "Integer interploated";
    is $tc.bool, False, "Bool interpolated";
    is $tc.str, "String", "String interpolated";
    
}, "Interpolation";

subtest {
    temp %*ENV = {};
   
    my $tc;
    ok $tc = TestClass.new(), "Test Class created OK";
    is $tc.int, Int, "Integer not found";
    is $tc.bool, Bool, "Bool not found";
    is $tc.str, Str, "String not found";
    
}, "Interpolation not found";

subtest {
    temp %*ENV = { :VALUE<value> }
    my $c;
    ok $c = Config.new(), "External Class created OK";
    is $c.value, 'value', "Config value OK";
}, "External class test";

done-testing;
