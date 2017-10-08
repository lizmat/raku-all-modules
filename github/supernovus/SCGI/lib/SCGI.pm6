unit class SCGI;

use SCGI::Connection;

has $.version = 2.3;

has Int $.port = 8118;
has Str $.addr = 'localhost';
has $.socket;

has $.NPH  = False;   ## Set to true to use NPH mode (not recommended.)

has $.PSGI  = False;  ## Include PSGI Classic Headers.
has $.P6SGI = True;   ## Include default P6SGI Headers.
                      ## If neither of those is used, assume raw HTTP headers.

has $.debug  = False; ## Set to true to debug stuff.
has $.strict = True;  ## If set to false, don't ensure proper SCGI.

has $.multithread = False; ## Set to true for asynchronous concurrent requests.

method connect (:$port=$.port, :$addr=$.addr)
{
  $!socket = IO::Socket::INET.new(
    :localhost($addr), 
    :localport($port), 
    :listen
  );
}

method accept () 
{
  if ! $.socket
  {
    self.connect;
  }
  if $.debug 
  {
    $*ERR.say: "Waiting for connection.";
  }
  my $connection = $.socket.accept() or return;
  if $.debug 
  {
    $*ERR.say: "connection family is "~$connection.family;
    $*ERR.say: "connection proto is "~$connection.proto;
    $*ERR.say: "connection type is "~$connection.type;
  }
  SCGI::Connection.new(:socket($connection), :parent(self));
}

method handle (&closure)
{
  if ($.debug) {
    if $!socket
    {
      $*ERR.say: "socket family is "~$.socket.family;
      $*ERR.say: "socket proto is "~$.socket.proto;
      $*ERR.say: "socket type is "~$.socket.type;
    }
    else
    {
      $*ERR.say: "No socket yet";
    }
  }
  $*ERR.say: "[{time}] SCGI is ready and waiting ($!addr:$!port)";
  loop
  {
    my $connection = self.accept or last;
    if ($.debug) { $*ERR.say: "Doing the loop"; }
    my $request = $connection.request;
    if $request.success {
      my %env = $request.env;
      if $!multithread {
        my $s = Supplier.new;

        start {
          $s.emit: closure(%env);
          $s.done;
        };

        $s.Supply.tap: -> $return {
          $connection.send: $return;
          $connection.close;
        }

      } else {
        my $return = closure(%env);
        $connection.send: $return;
        $connection.close;
      }
    }
    else
    {
      $connection.close;
    }
  }
}

method shutdown {
  exit;
}

