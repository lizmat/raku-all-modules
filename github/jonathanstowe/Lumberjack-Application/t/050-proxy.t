#!perl6

use v6;

use Test;
use Test::Util::ServerPort; 
use Lumberjack;
use Lumberjack::Dispatcher::Proxy;
use Lumberjack::Message::JSON;
use HTTP::Server::Tiny;
         
my $port = get-unused-port(); 

my @messages;

# This basically what the Application does, just don't want to redispatch;
my $p = start {
    constant JSONMessage = ( Lumberjack::Message but Lumberjack::Message::JSON );
    sub app(%env) {
        is %env<REQUEST_METHOD>, 'POST', "request is a post";
        my $c = %env<p6w.input>.list.map({ .decode }).join('');
        ok $c.defined, "got some data";
        my $mess = JSONMessage.from-json($c);
        @messages.append: $mess;
        return 200, [ Content-Type => 'application/json' ], [ '{ "status" : "OK" }' ];
    }
    my $s = HTTP::Server::Tiny.new(:$port);
    $s.run(&app);

};

class Foo does Lumberjack::Logger {
}

Foo.log-level = Lumberjack::All;

my $d;

lives-ok { $d = Lumberjack::Dispatcher::Proxy.new(url => "http://localhost:$port/") }, "create dispatcher";

Lumberjack.dispatchers.append: $d;

Foo.new.log-debug("test message");
is @messages.elems, 1, "got the message in the receiver";
isa-ok @messages[0], Lumberjack::Message, "got the message";
is @messages[0].message, "test message", "and it appears to be the right one";



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
