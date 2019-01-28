use v6.c;
use Test;
use Trait::Env::Attribute;

class TestClass {
    has $.attribute is env;
    has $.ATTRIBUTE is env;
}

subtest {
    temp %*ENV = { "ATTRIBUTE" => "Here" };

    my $tc;
    ok $tc = TestClass.new(), "Test Class created OK";
    is $tc.attribute, "Here", "We have a test value";
    is $tc.ATTRIBUTE, "Here", "We have a test value (uc WORKS)";

}, "Basic Test Class. Loading Test:Env::Attribute only works OK.";

done-testing;
