use v6;

unit class Smack::Client;

use HTTP::Headers;
use HTTP::Supply::Response;
use Smack::Client::Request;
use Smack::Client::Response;

# EXPERIMENTAL!

has Int $.request-timeout = 30;

has Str $.enc = 'utf-8';

has Str $.user-agent = "Smack::Client/{::?PACKAGE.^ver//0}";

multi method request(Smack::Client::Request $req --> Promise:D) {
    start {
        $req.headers.User-Agent ||= $!user-agent;
        $req.headers.Connection ||= 'close';

        my $conn = await IO::Socket::Async.connect($req.host, $req.port, :$!enc);

        $req.send($conn);

        my $request-took-too-long = Promise.in($!request-timeout);
        my $finished-response = Promise.new;

        my @res = await supply {
            whenever HTTP::Supply::Response.parse-http($conn.Supply(:bin), :!debug) -> $res {

                # Beginning collecting the body and be ready to close this off
                # for a single request when the body is finished.
                my $body = Supplier::Preserving.new;
                $res[2].tap: { $body.emit($_) },
                    done => { $conn.close; $body.done; $finished-response.keep },
                    quit => { .note; $conn.close; $finished-response.keep },
                    ;

                emit ($res[0], $res[1], $body.Supply);
            }

            whenever $finished-response {
                done;
            }

            whenever $request-took-too-long {
                $conn.close;
                die "server took too long to response to request (more than $!request-timeout seconds)";
            }
        }

        Smack::Client::Response.from-p6wapi(|@res);
    }
}

multi method request(%env) {
    self.request(Smack::Client::Request.new(%env));
}

