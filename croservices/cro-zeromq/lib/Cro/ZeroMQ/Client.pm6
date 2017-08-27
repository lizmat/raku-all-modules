use Cro::ZeroMQ::Socket::Req;
use Cro::ZeroMQ::Socket::Dealer;

class X::Cro::ZeroMQ::Client::AlreadySent is Exception {
    method message() { "The previous response from Req client was still not received." }
}

role Cro::ZeroMQ::Client::Common {
    has $!output;
    has $!input;

    method send() { ... }
}

class Cro::ZeroMQ::Client::Dealer does Cro::ZeroMQ::Client::Common {
    has %!requests;

    method BUILD(:$!input!, :$!output!) {
        $!output.tap: -> $resp {
            with %!requests{$resp.parts[0].decode}:delete {
                $_.keep(Cro::ZeroMQ::Message.new($resp.parts[1..*]));
            }
            else {
                die "Strange response is get: {$resp.parts.perl}";
            }
        }
    }
    method send($message) {
        my $response = Promise.new;
        %!requests{$message.body-text ~ '-resp'} = $response;
        $!input.emit(Cro::ZeroMQ::Message.new($message.body-text ~ '-resp', '', $message.body-text));
        $response;
    }
}

class Cro::ZeroMQ::Client::Req does Cro::ZeroMQ::Client::Common {
    has $!lock = False;
    has $!message;

    method BUILD(:$!input!, :$!output!) {
        $!output.tap: -> $_ {
            $!lock = False;
            $!message.keep($_);
        }
    }
    method send($message) {
        die X::Cro::ZeroMQ::Client::AlreadySent.new if $!lock;
        $!lock = True;
        $!message = Promise.new;
        $!input.emit: $message;
        $!message;
    }
}

class Cro::ZeroMQ::Client {
    # This is a duplication, but we won't win anything by generalization of it
    method req(:$connect) {
        my $req = Cro.compose(Cro::ZeroMQ::Socket::Req);
        my $input = Supplier::Preserving.new;
        my $output = $req.establish($input.Supply, :$connect);
        Cro::ZeroMQ::Client::Req.new(:$input, :$output);
    }

    method dealer(:$connect) {
        my $dealer = Cro.compose(Cro::ZeroMQ::Socket::Dealer);
        my $input = Supplier::Preserving.new;
        my $output = $dealer.establish($input.Supply, :$connect);
        Cro::ZeroMQ::Client::Dealer.new(:$input, :$output);
    }
}
