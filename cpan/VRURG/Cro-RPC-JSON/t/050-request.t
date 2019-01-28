use lib 't/lib';
use Test;
use Cro::HTTP::Test;
use Cro::RPC::JSON::Exception;
use JSON::Fast;

plan 2;

subtest "Basics", {
    plan 4;
    use Basic-JRPC;

    test-service routes, {
        test post('api', content-type => "application/notjson"),
            status => 415 ;

        test post('api', json => { jsonrpc=>"2.0", id=>123, method => "oops", params => [1,2,3] }),
            status => 200,
            json => { jsonrpc => "2.0", id => 123, result => { a => 1, b => 2 } },
            ;

        test post(
                'api',
                content-type => 'application/json',
                body => to-json( [
                    { jsonrpc => "2.0", id => 321, method => "go", params => <a b c> },
                    { jsonrpc => "2.0", method => "go", params => <a b c> },
                    { jsonrpc => "2.0", id => 322, method => "do", params => <d e f> },
                    { method  => "go", id => 323, params => "aaa" },
                    { jsonrpc => "1.0", id => 324, method => "do", },
                    { jsonrpc => "2.0", id => 325, method => "rpc.method", },
                ] ),
            ),
            status => 200,
            json => [
                { jsonrpc => "2.0", id => 321, result => { a=>1, b=>2 } },
                { jsonrpc => "2.0", id => 322, result => { a=>1, b=>2 } },
                { 
                    jsonrpc => "2.0",
                    error   => {
                        code    => JRPCInvalidRequest,
                        message => "Missing required 'jsonrpc' key",
                    },
                },
                { 
                    jsonrpc => "2.0",
                    id      => 324,
                    error   => {
                        code    => JRPCInvalidRequest,
                        message => "Invalid jsonrpc version: 1.0",
                    },
                },
                { 
                    jsonrpc => "2.0",
                    id      => 325,
                    error   => {
                        code    => JRPCInvalidRequest,
                        message => "Invalid method name: rpc.method",
                    },
                },
            ],
            ;

        test get( '/api' ),
                status => 500,
                content-type => "text/plain",
                body-text => /"500 JSON-RPC is only supported for POST method"/,
                ;
    }
}

subtest "Actor Class" => {
    plan 9;
    use Object-JRPC;

    my $id = 123;
    test-service routes, {
        test post('api', json => { jsonrpc=>"2.0", id => $id, method => "foo", params => { a => 2, b => "two" } }),
            status => 200,
            json => {jsonrpc => "2.0", id => $id, result => "two and 2"};

        $id++;

        test post('api', json => { jsonrpc=>"2.0", id => $id, method => "by-request", params => { a => 2, b => "two" } }),
            status => 200,
            json => {jsonrpc => "2.0", id => $id, result => { param-count => 2 } };

        $id++;

        test post( 'api', json => { jsonrpc=>"2.0", id => $id, method => "bar", params => { a => "A!" } } ),
            status => 200,
            json => {jsonrpc => "2.0", id => $id, result => "single named Str param"};


        $id++;

        test post( 'api', json => { jsonrpc=>"2.0", id => $id, method => "bar", params => [ 1, pi, "whatever" ] } ),
            status => 200,
            json => {jsonrpc => "2.0", id => $id, result => "Int, Num, Str positionals"};

        $id++;

        test post( 
                'api', 
                json => {
                    jsonrpc => "2.0",
                    id      => $id, 
                    method  => "bar", 
                    params  => { :t("Їхав до бабусі один сірий гусик"), :p("π"), :e(e) } 
                },
                content-type => "application/json; charset=UTF-8",
            ),
            status => 200,
            json => {
                jsonrpc => "2.0",
                id      => $id,
                result  => [ 
                    "slurpy hash:", 
                    { :t("Їхав до бабусі один сірий гусик"), :p("π"), :e(e) }
                ],
            };

        $id++;

        test post('api', json => { jsonrpc=>"2.0", id => $id, method => "non-json" }),
            status => 200,
            json   => {
                jsonrpc => "2.0",
                id      => $id,
                error   => {
                    code    => JRPCMethodNotFound,
                    message => "Method JRPC-Actor::non-json: doesn't have 'is json-rpc' trait",
                    data    => { method => "non-json" },
                }
            };

        $id++;
 
        test post('api', json => { jsonrpc=>"2.0", id => $id, method => "no-method" }),
            status => 200,
            json   => {
                jsonrpc => "2.0",
                id      => $id,
                error   => {
                    code    => JRPCMethodNotFound,
                    message => "Method JRPC-Actor::no-method: doesn't exists",
                    data    => { method => "no-method" },
                }
            };

        $id++;

        test post('api', json => { jsonrpc=>"2.0", id => $id, method => "fail", params => { a => 2, b => "two" } }),
            status => 200,
            json => {jsonrpc => "2.0", id => $id, error => { code => JRPCInvalidParams, message => "I always fail" }};

        $id++;

        if %*ENV<AUTHOR_TESTING> {
            test post('api', json => { jsonrpc=>"2.0", id => $id, method => "mortal", params => { a => 2, b => "two" } }),
                status => 200,
                json   => {
                    jsonrpc => "2.0", 
                    id      => $id, 
                    error   => { 
                        code    => JRPCInternalError, 
                        message => "Simulate... well... something",
                        data    => {
                            exception => 'X::AdHoc',
                            backtrace => / .* /,
                        },
                    }
                };
        }
        else {
            skip "for author testing only", 1;
        }
    };
}

done-testing;

# vim: ft=perl6
