class SCGI::Request;

use Netstring;
use SCGI::Constants;

has $.connection;
has $.success = False;
has %.env;
has $.input;
has $.request;

method parse ()
{
  my $debug = $.connection.parent.debug;

  my $netstring = read-netstring($.connection.socket);
  $!request = $netstring.decode;

  my $rlen = $.request.chars;
  my $err = $.connection.err;
  if $debug { $*ERR.say: "Receieved request: $.request"; }
  my @env = $.request.split(SEP);
  @env.pop;
  %!env = @env;

  if $.connection.parent.strict 
  {
    unless defined %.env<CONTENT_LENGTH> 
    && %.env<CONTENT_LENGTH> ~~ / ^ \d+ $ / 
    {
      $err.say(SCGI_E_CONTENT);
      return self;
    }
    unless %.env<SCGI> && %.env<SCGI> eq '1' 
    {
      $err.say(SCGI_E_SCGI);
      return self;
    }
  }

  my $clen = +%.env<CONTENT_LENGTH>;
  if $clen > 0
  {
    $!input = $.connection.socket.read($clen);
  }

  %.env<scgi.request> = self;
  if $.connection.parent.PSGI
  {
    %.env<psgi.version>      = [1,0];
    %.env<psgi.url_scheme>   = 'http';  ## FIXME: detect this.
    %.env<psgi.multithread>  = False;
    %.env<psgi.multiprocess> = False;
    %.env<psgi.input>        = $.input;
    %.env<psgi.errors>       = $.connection.err;
    %.env<psgi.run_once>     = False;
    %.env<psgi.nonblocking>  = False;   ## Allow when NBIO.
    %.env<psgi.streaming>    = False;   ## Eventually?
  }

  $!success = True;
  return self;
}

