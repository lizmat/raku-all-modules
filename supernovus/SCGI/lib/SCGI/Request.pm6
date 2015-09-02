unit class SCGI::Request;

use Netstring;
use SCGI::Constants;
use PSGI;

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
  if $.connection.parent.PSGI || $.connection.parent.P6SGI
  {
    populate-psgi-env(%.env, :input($.input), :errors($.connection.err), 
        :psgi-classic($.connection.parent.PSGI), 
        :p6sgi($.connection.parent.P6SCGI)
    );
  }

  $!success = True;
  return self;
}

