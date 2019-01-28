use Cro::HTTP::Server;
use Cro::HTTP::Router;
use Cro::RPC::JSON;

class JRPC-Actor is export {
    method foo ( Int :$a, Str :$b ) is json-rpc {
        return "$b and $a";
    }

    method by-request ( Cro::RPC::JSON::Request $req ) is json-rpc {
        { param-count => $req.params.elems }
    }

    proto method bar (|) is json-rpc { * }

    multi method bar ( Str :$a! ) { "single named Str param" }
    multi method bar ( Int $i, Num $n, Str $s ) { "Int, Num, Str positionals" }
    multi method bar ( *%options ) { [ "slurpy hash:", %options ] }

    method fail (|) is json-rpc {
        X::Cro::RPC::JSON::InvalidParams.new( msg => "I always fail" ).throw;
    }

    method mortal (|) is json-rpc {
        die "Simulate... well... something";
    }

    method non-json (|) { "I won't be called!" }
}

sub routes is export {
    route {
        post -> "api" {
            my $actor = JRPC-Actor.new;
            json-rpc $actor;
        }
    }
}

