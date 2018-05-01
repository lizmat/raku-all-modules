use Cro::Connection;
use Cro::Connector;
use Cro::HTTP::Client;
use Cro::HTTP::RequestParser;
use Cro::HTTP::ResponseSerializer;
use Cro::HTTP2::FrameParser;
use Cro::HTTP2::FrameSerializer;
use Cro::HTTP2::RequestParser;
use Cro::HTTP2::ResponseSerializer;
use Cro::TCP;

class Cro::HTTP::Test::Client is Cro::HTTP::Client {
    has $.connector is required;
    method choose-connector($) {
        $!connector
    }
}

class Cro::HTTP::Test::Replier does Cro::Sink {
    has Channel $.out is required;
    
    method consumes() { Cro::TCP::Message }

    method sinker(Supply:D $pipeline) returns Supply:D {
        supply {
            whenever $pipeline {
                $!out.send(.data);
                LAST $!out.close;
            }
        }
    }
}
class Cro::HTTP::Test::Connection does Cro::Connection does Cro::Replyable {
    has Channel $.in .= new;
    has Channel $.out .= new;
    has $.replier = Cro::HTTP::Test::Replier.new(:$!out);

    method produces() { Cro::TCP::Message }

    method incoming() {
        supply whenever $!in.Supply -> $data {
            emit Cro::TCP::Message.new(:$data);
        }
    }
}

class Cro::HTTP::Test::Listener does Cro::Source {
    has Channel $.connection-channel is required;

    method produces() { Cro::HTTP::Test::Connection }

    method incoming() {
        $!connection-channel.Supply
    }
}

class Cro::HTTP::Test::Connector does Cro::Connector {
    has Channel $.connection-channel is required;

    class Transform does Cro::Transform {
        has Channel $.out is required;
        has Channel $.in is required;

        method consumes() { Cro::TCP::Message }
        method produces() { Cro::TCP::Message }

        method transformer(Supply $incoming --> Supply) {
            supply {
                whenever $incoming {
                    $!out.send(.data);
                }
                whenever $!in -> $data {
                    emit Cro::TCP::Message.new(:$data);
                    LAST done;
                }
            }.on-close({ $!out.close })
        }
    }

    method consumes() { Cro::TCP::Message }
    method produces() { Cro::TCP::Message }

    method connect(--> Promise) {
        start {
            my $in = Channel.new;
            my $out = Channel.new;
            my $connection = Cro::HTTP::Test::Connection.new(:$in, :$out);
            $!connection-channel.send($connection);
            Transform.new(out => $in, in => $out)
        }
    }
}

class Cro::HTTP::Test::FakeAuthHolder {
    has @!auths;

    method push-auth($auth --> Nil) {
        push @!auths, $auth;
    }

    method pop-auth(--> Nil) {
        pop @!auths;
    }

    method auth() {
        @!auths ?? @!auths[*-1] !! Nil
    }
}

my class FakeAuthInsertion does Cro::Transform {
    has Cro::HTTP::Test::FakeAuthHolder $.auth-holder is required;
    method consumes() { Cro::HTTP::Request }
    method produces() { Cro::HTTP::Request }
    method transformer(Supply $in --> Supply) {
        supply whenever $in -> $req {
            with $!auth-holder.auth {
                $req.auth = $_;
            }
            emit $req;
        }
    }
}

sub build-client-and-service(Cro::Transform $testee, %client-options, :$fake-auth-holder,
                             :$http) is export {
    my @fake-auth;
    with $fake-auth-holder {
        push @fake-auth, FakeAuthInsertion.new(auth-holder => $_);
    }
    my $connection-channel = Channel.new;
    my $connector = Cro::HTTP::Test::Connector.new(:$connection-channel);
    my $client = Cro::HTTP::Test::Client.new(:$connector, :$http, |%client-options, base-uri => 'http://test/');
    my $service = do if !$http.defined || $http eq '1.1' {
        Cro.compose:
            Cro::HTTP::Test::Listener.new(:$connection-channel),
            Cro::HTTP::RequestParser.new,
            |@fake-auth,
            $testee,
            Cro::HTTP::ResponseSerializer.new
    }
    elsif $http eq '2' {
        Cro.compose:
            Cro::HTTP::Test::Listener.new(:$connection-channel),
            Cro::HTTP2::FrameParser.new,
            Cro::HTTP2::RequestParser.new,
            $testee,
            Cro::HTTP2::ResponseSerializer.new,
            Cro::HTTP2::FrameSerializer.new
    }
    else {
        die "Must pick either HTTP/1.1 or HTTP/2 for running tests (got $http.perl())";
    }
    return ($client, $service);
}
