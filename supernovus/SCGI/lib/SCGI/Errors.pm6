unit class SCGI::Errors;

use SCGI::Constants;

has $.connection;

method print ($message)
{
  my $crlf = CRLF x 2;
  $*ERR.print: "[{time}] $message";
  $.connection.socket.send(SCGI_ERROR_CODE~$crlf);
  $.connection.close;
}

method say ($message)
{
  self.print($message~"\n");
}

method printf ($message, *@params)
{
  self.print(sprintf($message, |@params));
}

method sayf ($message, *@params)
{
  self.printf($message~"\n", |@params);
}

