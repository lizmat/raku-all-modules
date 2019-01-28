use Cro::HTTP::Server;
use Cro::HTTP::Router;
use Cro::RPC::JSON;

sub routes is export {
    route {
        post -> "api" {
            json-rpc -> $json-req {
                { a => 1, b => 2 }
            }
        }
        get -> "api" {
            # This must die with 'POST only' error
            json-rpc -> $json-req {
                { a => 1, b => 2 }
            }
        }
    }
}
