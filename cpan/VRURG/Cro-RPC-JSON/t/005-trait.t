use Test;
use Cro::RPC::JSON;

#role Bar {
#    method jrpc-bar (:$foo) is json_rpc {}
#}

subtest "Basic" => {
    plan 4;

    my $inst;

    my class Foo {
        method foo (:$param1) is json-rpc { "method foo" }
        method jrpc-test (:$param1) is json-rpc("bar") { "method bar" }
    }

    $inst = Foo.new;

    for <foo bar> -> $jmethod {
        my $m = json-rpc-find-method($inst, $jmethod);
        ok so $m, "method $jmethod exists";
        is $inst.&$m, "method $jmethod", "valid return from $jmethod";
    }
}

subtest "Role" => {
    plan 4;

    my $inst;

    my role Bar {
        method foo is json-rpc { "method foo" }
        method jrpc-bar is json-rpc("bar") { "method bar" }
    }

    my class Foo does Bar {
    }

    $inst = Foo.new;

    for <foo bar> -> $jmethod {
        my $m = json-rpc-find-method($inst, $jmethod);
        ok so $m, "method $jmethod exists";
        is $inst.&$m, "method $jmethod", "valid return from $jmethod";
    }

}

subtest "Inheritance" => {
    plan 6;
    my $inst;
    my role Bar {
        method foo is json-rpc { "method foo" }
        method jrpc-bar is json-rpc("bar") { "method bar" }
    }

    my class Baz does Bar {
    }

    my class Foo is Baz {
    }

    my class Fubar is Foo {
        method baz is json-rpc { "method baz" }
    }

    $inst = Fubar.new;

    for <foo bar baz> -> $jmethod {
        my $m = json-rpc-find-method( $inst, $jmethod);
        ok so $m, "method $jmethod exists";
        is $inst.&$m, "method $jmethod", "valid return from $jmethod";
    }
}

subtest "Multi" => {
    plan 3;
    my $inst;
    my role Bar {
        proto method foo (|) is json-rpc { * }
        multi method foo () { "method foo" }
        method jrpc-bar is json-rpc("bar") { "method bar" }
    }

    my class Baz does Bar {
        multi method foo ( Str $s ) { "method foo( $s )" }
        multi method foo ( Num $r ) is json-rpc { "method foo( $r )" }
    }

    my class Foo is Baz {
    }

    my class Fubar is Foo {
        method baz is json-rpc { "method baz" }
        multi method foo ( Int $i, Str $s ) { "method foo( $i, $s )" }
    }

    $inst = Fubar.new;

    my $m = json-rpc-find-method( $inst, "foo" );
    is $inst.&$m(), "method foo", "no params";
    is $inst.&$m( pi ), "method foo( {pi} )", "Num";
    is $inst.&$m( 314, "pi" ), "method foo( 314, pi )", "Int, Str";
}

done-testing;

# vim: ft=perl6
