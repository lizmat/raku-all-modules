use v6;

unit class FastCGI::Connection;

use PSGI;
use FastCGI::Request;
use FastCGI::Errors;
use FastCGI::Constants;
use FastCGI::Protocol;
use FastCGI::Protocol::Constants :ALL;
#use FastCGI::Logger;

has $.socket;
has $.parent;
has $.err = FastCGI::Errors.new;
has %!requests;
has $!closed = False;

method handle-requests (&closure)
{
#  my $debug = $.parent.debug;
#  my $log = FastCGI::Logger.new(:name<C::handle>);
  loop
  {
#    $log.say: "Reading header." if $debug; 
    my Buf $header = $.socket.read(FCGI_HEADER_LEN);
#    $log.say: "Header read, parsing it." if $debug;
    my ($type, $id, $content-length) = parse_header($header);
#    $log.say: "Header parsed. Now reading record." if $debug;
    my Buf $record = $.socket.read($content-length);
#    $log.say: "Record read, parsing it." if $debug;
    my %record = parse_record_body($type, $id, $record);
#    $log.say: "Record parsed." if $debug;

    given $type
    {
      when FCGI_BEGIN_REQUEST
      {
#        $log.say: "Creating Request object." if $debug;
        if %!requests.exists($id) { die "Request of id $id already exists"; }
        %!requests{$id} = FastCGI::Request.new(:$id, :connection(self));
#        $log.say: "Object created." if $debug;
      }
      when FCGI_PARAMS
      {
#        $log.say: "Parsing param." if $debug;
        if ! %!requests.exists($id) { die "Invalid request id: $id"; }
        my $req = %!requests{$id};
        if %record<content>.defined
        {
          $req.param(%record<content>);
        }
#        $log.say: "Param parsed." if $debug;
      }
      when FCGI_STDIN
      {
#        $log.say: "Parsing STDIN" if $debug;
        if ! %!requests.exists($id) { die "Invalid request id: $id"; }
        my $req = %!requests{$id};
        if %record<content>.defined
        {
          $req.in(%record<content>);
#          $log.say: "Added content to STDIN." if $debug;
        }
        else
        {
          my %env = $req.env;
#          $log.say: "Build environment, sending to closure." if $debug;
          my $return = &closure(%env);
#          $log.say: "Got response from closure, sending it." if $debug;
          self.send-response($id, $return);
          %!requests.delete($id);
#          $log.say: "Sent response." if $debug;
          if ! $.parent.multiplex { return; }
        }
      }
      when FCGI_GET_VALUES
      {
#        $log.say: "Handling GET_VALUES request." if $debug;
        if $id != FCGI_NULL_REQUEST_ID
        {
          die "Invalid management request.";
        }
        self.send-values(%record<values>);
#        $log.say: "Sent GET_VALUES_RESULT.";
        if ! $.parent.multiplex { return; }
      }
      ## TODO: FCGI_UNKNOWN_TYPE handling.
    }
  }
}

## Send management values.
method send-values (%wanted)
{
  my %values;
  for %wanted.keys -> $wanted
  {
    given $wanted
    {
      when FCGI_MAX_CONNS
      {
        %values{FCGI_MAX_CONNS} = $.parent.max-connections;
      }
      when FCGI_MAX_REQS
      {
        %values{FCGI_MAX_REQS} = $.parent.max-requests;
      }
      when FCGI_MPXS_CONNS
      {
        %values{FCGI_MPXS_CONNS} = $.parent.multiplex ?? 1 !! 0;
      }
    }
  }
  my $values = build_params(%values);
  my $res = build_record(FCGI_GET_VALUES_RESULT, FCGI_NULL_REQUEST_ID, $values);
  $.socket.write($res);
}

method send-response ($request-id, $response-data)
{
#  my $debug = $.parent.debug;
#  my $log = FastCGI::Logger.new(:name<C::response>);
  my $http_message;
  if $.parent.PSGI
  {
    $http_message = encode-psgi-response($response-data);
    if $http_message ~~ Str {
      $http_message .= encode;
    }
  }
  else
  {
    if $response-data ~~ Buf
    {
      $http_message = $response-data;
    }
    else
    {
      $http_message = $response-data.Str.encode;
    }
  }

  my $res;
  if $.err.messages.elems > 0
  {
#    $log.say: "Building response with error stream." if $debug;
    my $errors = '';
    for $.err.messages -> $emsg
    {
      $errors ~= $emsg.decode;
    }
    $res = build_end_request($request-id, $http_message, $errors);
  }
  else
  {
#    $log.say: "Building response." if $debug;
    $res = build_end_request($request-id, $http_message);
  }

#  $log.say: "Response built, writing to socket." if $debug;
  $.socket.write($res);
#  $log.say: "Wrote response." if $debug;
}

method close
{
  $!socket.close if $!socket;
  $!closed = True;
}

submethod DESTROY
{
  self.close unless $!closed;
}

