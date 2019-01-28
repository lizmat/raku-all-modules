use v6.c;
use Test;
use Trait::Env;

class TestClassSimple {
    has Bool $.bool-simple-true is env;
    has Bool $.bool-simple-false is env;
}

class TestClassString {
    has Bool $.bool-string-true is env;
    has Bool $.bool-string-false is env;
}

subtest {
    temp %*ENV = { BOOL_SIMPLE_TRUE => "1", BOOL_SIMPLE_FALSE => "" };

    my $tc = TestClassSimple.new();
    is $tc.bool-simple-true, True, "Simple True works";
    is $tc.bool-simple-false, False, "Simple True works";
    
}, "Simple Bool interpolation";

subtest {
    for < true True TRUE > -> $t {
        temp %*ENV = { BOOL_STRING_TRUE => $t };
        my $tc = TestClassString.new();
        is $tc.bool-string-true, True, "String $t works";
    }
}, "Truthiness";

subtest {
    for < false False FALSE > -> $f {
        temp %*ENV = { BOOL_STRING_FALSE => $f };
        my $tc = TestClassString.new();
        is $tc.bool-string-false, False, "String $f works";
    }
}, "Falsiness";


done-testing;
