use v6.c;
use Test;
use Trait::Env;

class TestClass {
    has %.sep-hash is env( :default({"a"=>"b"}), :sep<:>, :kvsep<;> );
}

subtest {
    temp %*ENV = ( :SEP_HASH<a;b:b;c:d;e> );

    my $tc = TestClass.new();
    is $tc.sep-hash, { "a" => "b", "b" => "c", "d" => "e" } , "String to Hash works";

}, "Simple KV Hash";

subtest {
    temp %*ENV = ();

    my $tc = TestClass.new();
    is $tc.sep-hash, { "a" => "b" } , "Default is good";

}, "Simple KV Hash Default";

class RequiredTest {
    has %.sep-hash is env{:required, :sep<:>, :kvsep<;>};
}

subtest {
    temp %*ENV = ();

    throws-like { my $tc = RequiredTest.new() }, X::Trait::Env::Required::Not::Set, "Test Class dies with missing required";

}, "Required Test";

class NamedHash {
    has %.post-hash is env( :post_match<_POST> );
    has %.pre-hash is env( :pre_match<PRE_> );
    has %.both-hash is env{ :pre_match<PRE_>, :post_match<_POST> };
}

subtest {
    temp %*ENV = ( :TEST_POST<test>, :HOME_POST<home>,
		   :THIS_PRE_POST_NOT<nope>,
		   :PRE_TEST<test>, :PRE_HOME<home>,
		   :PRE_TEST_POST<test>
		 );

    my $tc = NamedHash.new();
    is $tc.post-hash, { "TEST_POST" => "test", "HOME_POST" => "home", "PRE_TEST_POST" => "test"  } , "Post Named hashes";
    is $tc.pre-hash, { "PRE_TEST" => "test", "PRE_HOME" => "home", "PRE_TEST_POST" => "test"  } , "Pre Named hashes";
    is $tc.both-hash, { "PRE_TEST_POST" => "test"  } , "Both Named hashes";

}, "Named hashes";

class TypedHash {
    has Int %.int-hash is env{ :sep<:>, :kvsep<;> };
    has Str %.str-hash is env{ :sep<:>, :kvsep<;> };
    has Bool %.bool-hash is env{ :sep<:>, :kvsep<;> };
}

subtest {
    temp %*ENV = (
        INT_HASH => "a;1:b;2",
        STR_HASH => "a;1:b;2",
        BOOL_HASH => "a;true:b;false",
    );

    my $tc = TypedHash.new();
    
    is-deeply $tc.int-hash, Hash[Int].new( "a", 1, "b", 2 ), "Int Hash OK";
    is-deeply $tc.str-hash, Hash[Str].new( "a", "1", "b", "2" ), "Str Hash OK";
    is-deeply $tc.bool-hash, Hash[Bool].new( "a", True, "b", False ), "Bool Hash Ok";
    
}, "Typed with values";

subtest {
    temp %*ENV = ();

    my $tc = TypedHash.new();
    
    is-deeply $tc.int-hash, Hash[Int].new(), "Empty Int Hash OK";
    is-deeply $tc.str-hash, Hash[Str].new(), "Empty Str Hash OK";
    is-deeply $tc.bool-hash, Hash[Bool].new(), "Empty Bool Hash Ok";
    
}, "Typed with values";


done-testing;
