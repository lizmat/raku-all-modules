#!/usr/bin/env perl6
###############################################################################
#
# Test script using the recommended API.
#
###############################################################################

use FastCGI;

my $fcgi = FastCGI.new( :port(9119), :debug, :!fancy-log );

my $handler = sub (%env) 
{
  my $name = %env<QUERY_STRING> || 'World';
  my $status = '200';
  my @headers = 'Content-Type' => 'text/plain';
  my @body = "Hello $name\n";;
  return [ $status, @headers, @body ];
}

$fcgi.handle: $handler;

