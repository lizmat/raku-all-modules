#!/usr/bin/env perl6

use v6;

BEGIN @*INC.push: './lib';

use Test;
use PSGI;

plan 24;

my $status    = 200;
my @headers   = 'Content-Type'=>'text/plain';
my %headers   = 'Content-Type'=>'text/plain';
my $body      = "Hello world";
my @body      = $body;

sub test_response ($name, $status, $headers, $body, $wanted, *%opts) {
  my $string = encode-psgi-response($status, $headers, $body, |%opts);
  is $string, $wanted, $name;
  my @response = $status, $headers, $body;
  $string = encode-psgi-response(@response, |%opts);
  is $string, $wanted, "array with $name";
}

my $string = encode-psgi-response($status, @headers, @body);

my $CRLF = "\x0D\x0A";

my $wanted ~= "Content-Type: text/plain$CRLF";
   $wanted ~= $CRLF;
   $wanted ~= "Hello world";

my $cgi  = "Status: 200 OK$CRLF";
   $cgi ~= $wanted;

my $nph  = "HTTP/1.0 200 OK$CRLF";
   $nph ~= $wanted;

my $nph2  = "HTTP+TEST/2.2 200 OK$CRLF";
   $nph2 ~= $wanted;

test_response('defaults',     $status, @headers, @body, $cgi);
test_response('hash headers', $status, %headers, @body, $cgi);
test_response('str body',     $status, @headers, $body, $cgi);
test_response('hash & str',   $status, %headers, $body, $cgi);

test_response('NPH defaults',     $status, @headers, @body, $nph, :nph);
test_response('NPH hash headers', $status, %headers, @body, $nph, :nph);
test_response('NPH str body',     $status, @headers, $body, $nph, :nph);
test_response('NPH hash & str',   $status, %headers, $body, $nph, :nph);

my $protocol = 'HTTP+TEST/2.2';

test_response('custom NPH defaults',
  $status, @headers, @body, $nph2, :nph, :$protocol);
test_response('custom NPH hash headers', 
  $status, %headers, @body, $nph2, :nph, :$protocol);
test_response('custom NPH str body',     
  $status, @headers, $body, $nph2, :nph, :$protocol);
test_response('custom NPH hash & str',   
  $status, %headers, $body, $nph2, :nph, :$protocol);
