use v6;

=begin pod

=head1 NAME

Lumberjack::Application::PSGI - Web receiver for Lumberjack messages

=head1 SYNOPSIS

=begin code

use Lumberjack::Application::PSGI;

my &app = Lumberjack::Application::PSGI.new;

# Start listener on port 8898
HTTP::Server::Tiny.new(port => 8898).run(&app);

=end code

=head1 DESCRIPTION

This provides a mechanism to receive the C<Lumberjack> 
logging messages that have been sent by a remote
L<Lumberjack::Dispatcher::Proxy> dispatcher and cause
them to be re-dispatched to the local C<Lumberjack>
dispatchers.

An instance of the class is a C<P6SGI> compliant application
callable so can be used with any compliant server container.

The class has no public methods or attributes and the way that
the messages are onward dispatched is entirely in the hands of
the local Lumberjack framework setup.

The application will only accept 'POST' requests of content type
'application/json' (which content will be a JSON serialised
message.)  The actual location on the server is the responsibility
of the larger application configuration.

=end pod

use Lumberjack;
use Lumberjack::Message::JSON;

class Lumberjack::Application::PSGI does Callable {


    constant JSONMessage = ( Lumberjack::Message but Lumberjack::Message::JSON );

    method CALL-ME(%env) {
        self.call(%env);
    }

    method call(%env) {
        if %env<REQUEST_METHOD> eq 'POST' {
	        my $c = %env<p6w.input>.list.map({ .decode }).join('');
            my $mess = JSONMessage.from-json($c);
            Lumberjack.log($mess);
	        return 200, [ Content-Type => 'application/json' ], [ '{ "status" : "OK" }' ];
        }
        else {
            return 405, [Allow => 'POST', Content-Type => 'application/json' ], ['{ "status" : "Only POST method allowed" }'];
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
