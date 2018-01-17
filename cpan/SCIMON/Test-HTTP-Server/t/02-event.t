use v6.c;
use Test;

use Test::HTTP::Server::Event; 

my $event = Test::HTTP::Server::Event.new( :code(404), :path</test.html>, :method<GET> );
ok $event, "Made an event";
is $event.code, 404, "Code as expected";
is $event.path, "/test.html", "Path as expected";
is $event.method, "GET", "Method as expected";

done-testing;
