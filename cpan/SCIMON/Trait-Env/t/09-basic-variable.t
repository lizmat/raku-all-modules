use v6.c;
use Test;
use Trait::Env;

my %env_copy;

subtest {
    BEGIN {
        %env_copy = %*ENV;
        %*ENV = {
	    "ATTRIBUTE" => "Here",
	    "INT" => 1,
	    "STR" => "Text",
	    "BOOL" => "true"
		};
    }
    END { %*ENV = %env_copy; }
        
    my $attribute is env;
    my $ATTRIBUTE is env;
    my Int $int is env;
    my Str $str is env;
    my Bool $bool is env;
    
    is $attribute, "Here", "We have a test value";
    is $ATTRIBUTE, "Here", "We have a test value (uc WORKS)";
    is $int, 1, "Int Coercion is OK";
    is $str, "Text", "Test Coercion is OK";
    is $bool, True, "Bool coercion is OK";
    
}, "Initial Variable version. Loaded from Package";

subtest {
    BEGIN {
	my $value = <1 2 3 4>.join($*DISTRO.path-sep);
        %env_copy = %*ENV;
        %*ENV = {
	    "DEFAULT_SEP" => $value,
	    "SIMPLE_1" => "1",
	    "SIMPLE_2" => "2",
	    "SET_SEP" => "1;2;3",
	    "BOOL" => "true:false:True:FALSE",
	    "INT" => "1:2:3",
	    "STR" => "A:B:C",
		};
    }
    END { %*ENV = %env_copy; }

    my @default_sep is env;
    my @simple is env;
    my @set-sep is env(:sep<;>);
    my Bool @bool is env(:sep<:>); 
    my Int @int is env(:sep<:>);
    my Str @str is env(:sep<:>);

    is-deeply @default_sep, ["1","2","3","4"], "Default Seperator OK";
    is-deeply @simple, ["1","2"], "Prefix array";
    is-deeply @set-sep, ["1","2","3"], "Set sperator";
    is-deeply @bool, Array[Bool].new(True,False,True,False);
    is-deeply @int, Array[Int].new(1,2,3);
    is-deeply @str, Array[Str].new("A","B","C");
    
}, "Arrays";


subtest {
    BEGIN {
	my $value = <1 2 3 4>.join($*DISTRO.path-sep);
        %env_copy = %*ENV;
        %*ENV = (
	    :TEST_POST<test>,
	    :HOME_POST<home>,
	    :THIS_PRE_POST_NOT<nope>,
	    :PRE_TEST<test>,
	    :PRE_HOME<home>,
	    :PRE_TEST_POST<test>,
	    :SEP_HASH<a;b:b;c:d;e>,
	);
    }
    END { %*ENV = %env_copy; }

    my %post-hash is env( :post_match<_POST> );
    my %pre-hash is env( :pre_match<PRE_> );
    my %both-hash is env( :pre_match<PRE_>, :post_match<_POST> );
    my %sep-hash is env( :default({"a"=>"b"}), :sep<:>, :kvsep<;> );

    is %post-hash, { "TEST_POST" => "test", "HOME_POST" => "home", "PRE_TEST_POST" => "test"  } , "Post Named hashes";
    is %pre-hash, { "PRE_TEST" => "test", "PRE_HOME" => "home", "PRE_TEST_POST" => "test"  } , "Pre Named hashes";
    is %both-hash, { "PRE_TEST_POST" => "test"  } , "Both Named hashes";
    is %sep-hash, { "a" => "b", "b" => "c", "d" => "e" } , "String to Hash works";

}, "Hashes";


done-testing;
