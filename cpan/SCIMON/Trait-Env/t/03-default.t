use v6.c;
use Test;
use Trait::Env;

class TestClass {
    has $.attribute is env is default("attr");
    has $.attribute-two is default("attr2") is env;
    has $.attribute-three is env(:default<attr3>);
}

subtest {
    temp %*ENV = {
        ATTRIBUTE => "Here",
        ATTRIBUTE_TWO => "Here2",
        ATTRIBUTE_THREE => "Here3"                      
    };

    my $tc;
    ok $tc = TestClass.new(), "Test Class created OK";
    is $tc.attribute, "Here", "We have a test value";
    is $tc.attribute-two, "Here2", "We have a test value";
    is $tc.attribute-three, "Here3", "We have a test value";

}, "Defaults OK work and are ignored";

subtest {
    temp %*ENV = {};

    my $tc;
    ok $tc = TestClass.new(), "Test Class created OK";
    is $tc.attribute, "attr", "Test value is default";
    is $tc.attribute-two, "attr2", "Test value is default";   
    is $tc.attribute-three, "attr3", "Internal default works";

}, "Defaults OK.";


done-testing;
