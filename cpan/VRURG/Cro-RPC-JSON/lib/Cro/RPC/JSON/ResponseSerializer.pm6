use Cro::Transform;
use Cro::HTTP::Request;
use Cro::RPC::JSON::Message;
use Cro::RPC::JSON::Exception;

class Cro::RPC::JSON::ResponseSerializer does Cro::Transform is export {
    method consumes { Cro::RPC::JSON::Message }
    method produces { Cro::RPC::JSON::Response }

    method transformer ( Supply $in ) {
        supply {
            whenever $in -> $msg {
                my $jresponse = Cro::RPC::JSON::Response.new;
                given $msg {
                    when Cro::RPC::JSON::MethodResponse {
                        $jresponse.json-body = .request.is-notification ?? "" !! .Hash;
                    }
                    when Cro::RPC::JSON::BatchResponse {
                        my @rlist;
                        for .responses -> $resp {
                            #note "GEN RESP FROM:", $resp;
                            @rlist.push( $resp.Hash ) unless $resp.request.is-notification;
                        }
                        $jresponse.json-body = @rlist;
                    }
                    default {
                        X::Cro::RPC::JSON::ServerError.new(
                            msg => "Cannot handle a request object of type " ~ .^name
                        ).throw;
                    }
                }
                emit $jresponse;
            }
        }
    }
}

# Copyright (c) 2018, Vadim Belman <vrurg@cpan.org>

