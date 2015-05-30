use v6;

unit class FastCGI;

use FastCGI::Connection;
use FastCGI::Logger;

has Int $.port = 9119;
has Str $.addr = 'localhost';
has $.socket;

has $.PSGI = True;   ## Set to False to use raw HTTP responses.

## Settings for FastCGI management records.
## You can override these per-application, but support is limited.
has $.max-connections = 1;
has $.max-requests = 1;
has $.multiplex = False;

## Settings for logging/debugging.
has $.log   = True;
has $.debug = False;
has $.fancy-log = True;

method connect (:$port=$.port, :$addr=$.addr)
{
  $!socket = IO::Socket::INET.new(
    :localhost($addr), 
    :localport($port), 
    :listen(1)
  );
}

method accept ()
{
  if (! $.socket)
  {
    self.connect();
  }
  my $connection = $.socket.accept() or return;
  FastCGI::Connection.new(:socket($connection), :parent(self));
}

method handle (&closure)
{
  my $log;
  if $.log
  {
    if $.debug
    {
      $log = FastCGI::Logger.new(:name<FastCGI>, :string($.fancy-log));
    }
    else
    {
      $log = FastCGI::Logger.new(:string($.fancy-log), :!duration);
    }
    $log.say: "Loaded and waiting for connections.";
  }
  while (my $connection = self.accept)
  {
    $log.say: "Received request." if $.log;
    $connection.handle-requests(&closure);
    $log.say: "Completed request." if $.log;
    $connection.close;
  }
}

