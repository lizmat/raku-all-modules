use Test;
use Cro::RPC::JSON::Message;

plan 2;

my @errParams = 
    %(
        :code(-32600),
        :message("неважлио зовсім"),
        :data( { info => "а тут трохи докладніше про те, що не має ніякого значення" } ),
    ),
    %(
        :code(-32600),
        :message("неважлио зовсім"),
    );

subtest "Error object" => { 
    plan 2;

    my $try = 1;
    for @errParams -> %errParams {
        my $err = Cro::RPC::JSON::Error.new( |%errParams );

        is-deeply $err.Hash, %errParams, "error object converted to hash {$try++}";
    }
}

subtest "Response object" => {
    plan 3;

    my $resp;
    my $id = 1;

    for |(<error> X=> @errParams), result => {r1=>pi, r2=>"π"} -> $k {
        my $payload = $k.key ~~ 'error' ??
            :error( Cro::RPC::JSON::Error.new( |$k.value ) )
            !!
            $k;

        my $resp = Cro::RPC::JSON::MethodResponse.new( :$id, |$payload );
        is-deeply $resp.Hash, %(:$id, |$k, :jsonrpc("2.0")), "convertion to hash {$id++}" ;
    };
}

done-testing;

# vim: ft=perl6
