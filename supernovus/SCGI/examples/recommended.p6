#!/usr/bin/env perl6
###############################################################################
#
# Test script using the recommended API.
#
###############################################################################

use SCGI;

my $scgi = SCGI.new( :port(8118) );

my $handler = sub (%env) 
{
  my $name = %env<QUERY_STRING> || 'World';
  my $status = '200';
  my @headers = 'Content-Type' => 'text/plain';
  my @body = "Hello $name\n";
  @headers.push: 'Content-Length' => @body.join.encode.bytes;
  return [ $status, @headers, @body ];
}

$scgi.handle: $handler;

