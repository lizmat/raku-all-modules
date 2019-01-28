use Cro::Transform;
use Cro::HTTP::Request;
use Cro::RPC::JSON::Message;
use Cro::RPC::JSON::Exception;
use JSON::Fast;

class Cro::RPC::JSON::RequestParser does Cro::Transform is export {
    method consumes { Cro::HTTP::Request }
    method produces { Cro::RPC::JSON::Message }

    method transformer (Supply:D $in) {
        #note "RequestParser got \$in: ", $in.WHO;
        supply {
            #note "supply?";
            whenever $in -> $request {
                unless $request.method.fc ~~ 'post'.fc {
                    # Must produce HTTP 500
                    die "JSON-RPC is only supported for POST method";
                }
                my $content-type = $request.content-type;
                #note "REQUEST CONTENT TYPE: ", $content-type;
                #note "PARAMETER: ", $_ for $content-type.parameters;

                unless $content-type.type-and-subtype ~~ 'application/json' {
                    X::Cro::RPC::JSON::MediaType.new(:$content-type).throw;
                }
                my $body = await $request.body-text;
                #note "GOT from \$in: ", $body;
                my $json = try { 
                    CATCH { default { X::Cro::RPC::JSON::ParseError.new( :msg($_.payload) ).throw } }
                    from-json( $body );
                }
                #note "JSON PARSED: ", $json.perl;
                my $jrpc-request;
                given $json {
                    when Array {
                        #note "DATA {$_.WHO}:", $_;
                        $jrpc-request = Cro::RPC::JSON::BatchRequest.new;
                        .map: {
                            #note "New REQ from ", $_;
                            $jrpc-request.requests.push: Cro::RPC::JSON::Request.new( :data($_), :batch($jrpc-request) )
                        };
                    }
                    when Hash {
                        #note "SINGLE REQUEST";
                        $jrpc-request = Cro::RPC::JSON::Request.new( :data($_) );
                    }
                    default {
                        die "Unsupported JSON RPC data type " ~ $_.WHO;
                    }
                }
                #note $jrpc-request.perl;
                emit $jrpc-request;
            }
        }
    }
}

# Copyright (c) 2018, Vadim Belman <vrurg@cpan.org>

