use v6.c;
use Test;
use File::Temp;
use Test::HTTP::Server;
use HTTP::UserAgent;

my $empty-folder = tempdir();

my $server = Test::HTTP::Server.new( :dir($empty-folder) );
my $port = $server.port;

ok $server.port, "Server has a port assigned to it";
is $server.port, $port, "Server port is unchanged";
is $server.dir, $empty-folder, "Server directory path is queryable";
is $server.events, [], "No requests made to server, events list is empty";

my $server2 = Test::HTTP::Server.new( :dir($empty-folder) );

isnt $server.port, $server2.port, "Second server has a new port";

my $ua = HTTP::UserAgent.new();
my $response = $ua.get( "http://localhost:{$server.port}/nothing.html" );
is $response.code, 404, "Empty folder gives a 404 on requests";

my @events = $server.events;
my @events2 = $server2.events;

is @events2.elems, 0, "Server 2 has not been called, no registered events";
is @events.elems, 1, "Server has 1 event";
is $server.events.elems, 1, "Calling events does not clear the list";
is @events[0].path, '/nothing.html', "Expected path called";
is @events[0].method, 'GET', "Expected method used";
is @events[0].code, 404, "Expected response code";
is $server.events.elems, 1, "One event still registered in the server";
is $server.clear-events, 1, "One event cleared from the list";
is $server.events.elems, 0, "No events registered in the server";

$response = $ua.get( "http://localhost:{$server.port}/nada.html" );
is $response.code, 404, "Empty folder gives a 404 on requests";
@events = $server.events;

is @events.elems, 1, "Server has 1 event";
is @events[0].path, '/nada.html', "Expected path called";
is @events[0].method, 'GET', "Expected method used";
is @events[0].code, 404, "Expected response code";
is $server.clear-events, 1, "One event cleared from the list";

$response = $ua.post( "http://localhost:{$server.port}/no-post", { key => "value" } );
is $response.code, 404, "Empty folder gives a 404 on requests";
@events = $server.events;

is @events.elems, 1, "Server has 1 event";
is @events[0].path, '/no-post', "Expected path called";
is @events[0].method, 'POST', "Expected method used";
is @events[0].code, 404, "Expected response code";


done-testing;
