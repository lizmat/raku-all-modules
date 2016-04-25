use v6.c;

=begin pod

=head1 NAME

Lumberjack::Application - web application for the Lumberjack logging framework

=head1 SYNOPSIS

=begin code

use Lumberjack::Application;

my $application = Lumberjack::Application.new(port => 8898);

# Run with the default P6SGI container
$application.run;

# Which really does the same as:

# HTTP::Server::Tiny.new(port => 8898).run($application);

# At which point you can point your browser at
# http://localhost::8898/ to access the application

=end code

=head1 DESCRIPTION

This provides a P6SGI compliant application that encapsulates the server
part of the suite of modules, combining the log web receiver, a web
socket endpoint that will transmit the logs to a a client browser and a
'home page' that provides the client websocket part (an angularJS app.)

This can be used 'as-is' for convenience with its own C<run>
method (that starts up a C<HTTP::Server::Tiny> instance on the
specified port,) or an instance of the class can be used as
P6SGI application (or combined into a larger application, via
e.g. L<Crust|https://github.com/tokuhirom/p6-Crust>.)

If you want to compose your application in a different way then
you can combine the C<Lumberjack::Application::WebSocket>,
C<Lumberjack::Application::PSGI> and optionally the
C<Lumberjack::Application::Index> in some way that you see fit.

=head1 METHODS

=head2 method new

    method new(:$port = 8898)

The constructor of the class takes one optional C<port> 
argument which is passed to the C<HTTP::Server::Tiny> if
it is used, if an instance is going to be used as a PSGI
application then this can be ignored.

It is important to note that if it is being used as a PSGI
application, this must be an instance to allow for proper
initialisation.

=head2 method run

    method run()

This runs the application, listening on the supplied port,
using the default C<HTTP::Server::Tiny> container. This is
not required if the instance is being passed as an app to
another container.

This will not return, so if this is being used in a larger
application then you should arrange for this to be done in
its own thread or make sure you have started the rest of
your application first.

=end pod

use Lumberjack;

class Lumberjack::Application does Callable {
    use Lumberjack::Application::PSGI;
    use Lumberjack::Application::WebSocket;
    use Lumberjack::Application::Index;
    use Lumberjack::Dispatcher::Supply;

    use HTTP::Server::Tiny;
    use Crust::Builder;

    has Int $.port = 8898;

    has &.app;

    method CALL-ME(%env) {
        self.app.(%env)
    }

    method app() returns Callable {

        if not &!app.defined {
            my $supply  = Lumberjack::Dispatcher::Supply.new;
            Lumberjack.dispatchers.append: $supply;

            my &ws-app  = Lumberjack::Application::WebSocket.new(supply => $supply.Supply);
            my &log-app = Lumberjack::Application::PSGI.new;
            my &ind-app = Lumberjack::Application::Index.new(ws-url => 'socket');

            &!app = builder {
                mount '/socket', &ws-app;
                mount '/log', &log-app;
                mount '/', &ind-app;
            };
        }
        &!app;
    }

    method run() {
        my $s = HTTP::Server::Tiny.new(port => 8898);
        $s.run(self.app)
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
