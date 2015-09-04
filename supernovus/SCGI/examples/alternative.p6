#!/usr/bin/env perl6
###############################################################################
#
# Test script using raw HTTP responses, and its own request loop.
#
###############################################################################
use SCGI;

my $scgi = SCGI.new( :port(8118), :!PSGI );

say "Starting raw SCGI server.";

while (my $connection = $scgi.accept())
{
  my $request = $connection.request;
  if $request.success
  {
    my $name = $request.env<QUERY_STRING> || 'World';
    my $return = "Hello $name\n";
    my $len = $return.encode.bytes;
    my $headers = "Content-Type: text/plain\nContent-Length: $len\n";
    $connection.send("$headers\n$return");
  }
  $connection.close;
}

