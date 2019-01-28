use Cro::Transform;
use Cro::RPC::JSON::Exception;
use Cro::RPC::JSON::Message;

class Cro::RPC::JSON::Handler does Cro::Transform is export {
    has Code $.code;

    multi method new (Code $code) { self.bless(:$code) }

    method consumes { Cro::RPC::JSON::Message }
    method produces { Cro::RPC::JSON::Message }

    method transformer (Supply:D $in) {
        supply {
            #note "Handler supply";
            whenever $in -> $msg {
                #note "Handling JSON block ", $msg.perl;
                my $jrpc-response;
                given $msg {
                    when Cro::RPC::JSON::Request {
                        $jrpc-response = self.handle-request( $_ );
                    }
                    when Cro::RPC::JSON::BatchRequest {
                        $jrpc-response = Cro::RPC::JSON::BatchResponse.new;
                        for .requests -> $req {
                            $jrpc-response.responses.push: self.handle-request( $req )
                        }
                        #note "RETURNING BATCH RESPONSE: ", $jrpc-response.responses;
                    }
                    default {
                        X::Cro::RPC::JSON::ServerError.new(
                            msg => "Cannot handle a request object of type " ~ .^name
                        ).throw;
                    }
                }
                emit $jrpc-response;
            }
        }
    }

    method handle-request ( Cro::RPC::JSON::Request $req ) {
        my $response = Cro::RPC::JSON::MethodResponse.new(
            request => $req,
            id => $req.id,
        );

        #note "+++ Handling request on ", $!code;

        if $req.invalid {
            #note "INV REQUEST: ", $req.invalid;
            $response.set-error( code => JRPCInvalidRequest, message => $req.invalid );
        }
        else {
            $response.result = &$!code( $req );
            CATCH {
                when X::Cro::RPC::JSON {
                    #note "HANDLING JSON-RPC EXCEPTION";
                    #note " . data: ", .data;
                    $response.set-error( code => .jrpc-code, message => .msg );
                    $response.error.data = .data if .data;
                }
                default { 
                    #note "HANDLER DEFAULT EXCEPTION: [{$_.WHO}]: ", ~$_;
                    $response.set-error( code => JRPCInternalError, message => ~$_, data => { exception => $_ } );
                }
            }
        }

        return $response;
    }
}

# Copyright (c) 2018, Vadim Belman <vrurg@cpan.org>

