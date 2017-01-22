use v6.c;

=begin pod

=head1 NAME

Lumberjack::Dispatcher::Proxy - dispatch lumberjack messages to a web server

=head1 SYNOPSIS

=begin code

use Lumberjack;
use Lumberjack::Dispatcher::Proxy;

Lumberjack.dispatchers.append: Lumberjack::Dispatcher::Proxy.new(url => 'http://localhost:8898/log');

# Now all messages will be dispatched to the web endpoint as well as the other dispatchers

=end code

=head1 DESCRIPTION

This implements a C<Lumberjack::Dispatcher> that will POST the messages
serialised as JSON to the specified URL.  Typically the endpoint
will be provided by a C<Lumberjack::Application::PSGI> application
which knows how to deserialise and re-dispatch the messages, but you
can equally provide your own if you have different requirements.

=head1 METHODS

=head2 method new

    method new(:$url!, :$username, :$password)

As well as the C<classes> and C<levels> matchers provided for
by the C<Lumberjack::Dispatcher> role, this has a required
C<url> parameter that should be the URI of a web service that
will accept an 'application/json' POST of the message data.
Additionally if the C<username> and C<password> parameters
are provided, it will attempt to authenticate with the HTTP
server, currently only basic authentication is provided,  though
other mechanisms may become available in the future.


=end pod

use Lumberjack;

use Lumberjack::Message::JSON;

use HTTP::UserAgent;


class Lumberjack::Dispatcher::Proxy does Lumberjack::Dispatcher {
    use HTTP::Request::Common;

    has HTTP::UserAgent     $!ua;
    has Str                 $.username;
    has Str                 $.password;
    has Str                 $.url       is required;
    has Bool                $.quiet = False;

    method log(Lumberjack::Message $message) {
        if not $!ua.defined {
            $!ua = HTTP::UserAgent.new;

            if $!username.defined && $!password.defined {
                $!ua.auth($!username, $!password);
            }
        }

        $message does Lumberjack::Message::JSON;

        my $req = POST($!url, content => $message.to-json, Content-Type => "application/json; charset=utf-8");

        my $res = try $!ua.request($req);

        if not $!quiet {
            if not $res.defined {
                # This is likely to be because the
                # server went away beneath us
                $*ERR.say: "proxy-dispatch failed";
            }
            elsif not $res.is-success {
                $*ERR.say: "proxy-dispatch failed : ", $res.status-line;
            }
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
