use v6;

unit class FastCGI::Request;

use FastCGI::Constants;
use FastCGI::Protocol;
#use FastCGI::Logger;
use PSGI;

has $.connection;
has Buf $.input;
has Int $.id;
has Buf $!params;

method param (Buf $param)
{
  if $!params.defined
  {
    $!params ~= $param;
  }
  else
  {
    $!params = $param;
  }
}

method in (Buf $stdin)
{
  if $!input.defined
  {
    $!input ~= $stdin;
  }
  else
  {
    $!input = $stdin;
  }
}

method env
{
#  my $debug = $.connection.parent.debug;
#  my $log = FastCGI::Logger.new(:name<R::env>);

  ## First, parse the environment.
#  $log.say: "Going to parse params." if $debug;
  my %env = parse_params($!params);
#  $log.say: "Parsed params, adding extra meta data." if $debug;

  ## Now add some meta data.
  %env<fastcgi.request> = self;
  if $.connection.parent.PSGI || $.connection.parent.P6SGI
  {
    populate-psgi-env(%env, :input($.input), :errors($.connection.err),
      :psgi-classic($.connection.parent.PSGI),
      :p6sgi($.connection.parent.P6SGI)
    );
  }

#  $log.say: "Added meta data, returning env." if $debug;

  return %env;
}

