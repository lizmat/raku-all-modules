use v6.c;

=begin pod

=head1 NAME

Lumberjack::Application::WebSocket - Lumberjack websocket provider

=head1 SYNOPSIS

=begin code

use Lumberjack;
use Lumberjack::Dispatcher::Supply;
use Lumberjack::Application::WebSocket;

my $s = Lumberjack::Dispatcher::Supply.new;
Lumberjack.dispatchers.append: $s;

my &ws-app = Lumberjack::Application::WebSocket.new(supply => $s.Supply);

# You can of course use it anywhere a P6SGI app can be used:
HTTP::Server::Tiny.new(port => 8898).run(&ws-app);

=end code

=head1 DESCRIPTION

This class provides a C<P6SGI> application that implements a
WebSocket server endpoint that will emit the C<Lumberjack::Message>s
that are received on the C<Supply> provided to the constructor.

The messages are emitted as a JSON serialised form and it is the
responsibility of the receiving clients to parse and interpret
as appropriate.  The structure that is used by the
C<Lumberjack::Dispatcher::Proxy> and is described (implemented
by,) C<Lumberjack::Message::JSON>.

It is the responsibility of the container application to locate
the endpoint appropriately, itself it is agnostic to which path
it is called at.

=head1 METHODS

=head2 method new

    method new(Supply :$supply!)

The class only has a constructor, with one required parameter
C<supply> which must be a Supply which will provide the
Lumberjack::Messages that will be sent out by the websocket
connect.  Typically this will be the C<Supply> of a 
C<Lumberjack::Dispatcher::Supply>.

=end pod

use Lumberjack::Message::JSON;
use WebSocket::P6SGI;


class Lumberjack::Application::WebSocket does Callable {
    has Supply $.supply is required;

    method CALL-ME(%env) {
        self.call(%env);
    }

    method call(%env) {
        my $tap;
        my $supply = $!supply;
        my $closed-promise = Promise.new;
        ws-psgi(%env,
                on-ready => -> $ws {
                    $tap = $supply.tap(-> $got {
                        if $got !~~ Lumberjack::Message::JSON {
                            $got does Lumberjack::Message::JSON;
                        }
                        if $closed-promise.status ~~ Planned {
                            try $ws.send-text( $got.to-json );
                        }
                    });
                },
                on-text => -> $ws, $txt {
                    # Not expecting anything back
                },
                on-binary => -> $ws, $binary {
                    # Not expecting anything back
                },
                on-close => -> $ws {
                        $closed-promise.keep: "GOT CLOSE";
                        $tap.close if $tap;
                },
        );
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
