class SCGI::Connection;

use SCGI::Request;
use SCGI::Response;
use SCGI::Errors;
use SCGI::Constants;

has $.parent;
has $.socket;
has $.err = SCGI::Errors.new(:connection(self));
has $!closed = 0;

method request
{
  SCGI::Request.new(:connection(self)).parse;
}

method send ($output)
{
  SCGI::Response.new(:connection(self)).send($output);
}

method shutdown ($message=SCGI_M_SHUTDOWN)
{
  $.err.sayf($message);
  self.close;
  $.parent.shutdown;
}

method close
{
  $!socket.close if $!socket;
  $!closed = 1;
}

submethod DESTROY 
{
  self.close unless $!closed;
}

