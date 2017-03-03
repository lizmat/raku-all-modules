use v6.c;

=begin pod

=head1 NAME

EventSource::Server - A simple handler to provide Server Sent Events from HTTP::Server::Tiny / Crust applications

=head1 SYNOPSIS

This sends out an event with the DateTime string every second

=begin code
use EventSource::Server;
use HTTP::Server::Tiny;

my $supply = Supply.interval(1).map( { EventSource::Server::Event.new(type => 'tick', data => DateTime.now.Str) } );

my &es = EventSource::Server.new(:$supply);

HTTP::Server::Tiny.new(port => 7798).run(&es)

=end code

And in some Javascript program somewhere else:

=begin code

var EventSource = require('eventsource');

var v = new EventSource(' http://127.0.0.1:7798');

v.addEventListener("tick", function(e) {
    console.info(e);

}, false);
=end code

See also the examples directory in this distribution.

=head1 DESCRIPTION

This provides a simple mechanism for creating a source of
L<Server Sent Events|https://www.w3.org/TR/eventsource/> in a
L<HTTP::Server::Tiny|https://github.com/tokuhirom/p6-HTTP-Server-Tiny>
server.

The EventSource interface is implemented by  most modern web browsers and
provides a lightweight alternative to Websockets for those applications
where only a uni-directional message is required (for example for
notifications,)

=end pod

class EventSource::Server does Callable {
    class Event {
        has Str $.type;
        has Str $.data is required;
        method Str() returns Str {
            my $str = "";

            if $!type.defined {
                $str ~= "event: { $!type }\r\n";
            }
            $str ~= "data: { $!data }\r\n\r\n";

            $str;
        }

        method encode() returns Blob {
            self.Str.encode;
        }
    }

    has Supply   $!out-supply;
    has Supply   $.supply;
    has Supplier $.supplier;

    proto sub map-supply(|c) { * }

    multi sub map-supply(Event $e) returns Event {
        $e;
    }

    multi sub map-supply(Str $data) returns Event {
        Event.new(:$data);
    }

    multi sub map-supply($ (Str $type, Str $data)) returns Event {
        Event.new(:$type, :$data);
    }

    method out-supply() {
        $!out-supply //= Supply.merge(self.supplier.Supply, self.supply).map(&map-supply).map({ $_.encode });
    }

    # If we weren't supplied with a Supply then
    # we just use a no-op one
    method supply() returns Supply {
        $!supply //= supply { };
    }

    method supplier() returns Supplier handles <emit> {
        $!supplier //= Supplier.new;
    }


    method headers() {
        [
            Cache-Control   => 'must-revalidate, no-cache',
            Content-Type    => 'text/event-stream; charset=utf-8'
        ];
    }

    method CALL-ME(%env) {
        return 200, self.headers , self.out-supply;
    }
}

# vim: ft=perl6
