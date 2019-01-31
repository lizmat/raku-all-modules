use v6;

=begin pod

=head1 NAME

Lumberjack::Application::Index  - serve up the web client page for Lumberjack::Application

=head1 SYNOPSIS

=begin code

use Lumberjack::Application::Index;

my &app = Lumberjack::Application::Index.new(ws-url => 'socket');

# You could use any P6SGI container
HTTP::Server::Tiny.new(port => 8898).run(&app);

=end code

=head1 DESCRIPTION

This provides a P6SGI application that will serve up the client application
page for C<Lumberjack::Application>. The page contains the AngularJS
websocket client that will populate the page with the incoming messages.
The text of the page itself is rendered from a template that is located
in the resources of the distribution.

You can of course use a different page altogether if you are constructing
the application yourself, and just use this code and/or the template
as a starting point.

=head1 METHODS

=head2 method new

    method new(:$ws-url!)

The constructor takes a single required parameter C<ws-url> which is the
path on which the websocket endpoint is located.

=end pod

use Template6;
use Lumberjack::Template::Provider;

class Lumberjack::Application::Index does Callable {
    has Template6 $!template;
    has Str       $.ws-url;

    submethod BUILD(:$!ws-url) {
        $!template = Template6.new;
        my $provider = Lumberjack::Template::Provider.new;
        $provider.add-path('templates');
        $!template.add-provider('resources', $provider);
        $!template.add-path('templates');
    }

    method call(%env) {
        my $html = $!template.process('index', ws-url => $!ws-url);
        return 200, [Content-Type => 'text/html'], [$html];
    }

    method CALL-ME(%env) {
        self.call(%env);
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
