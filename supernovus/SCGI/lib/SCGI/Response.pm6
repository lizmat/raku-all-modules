unit class SCGI::Response;

use HTTP::Status;
use SCGI::Constants;
use PSGI;

has $.connection;

method send ($response-data)
{
  my $http_message;
  if $.connection.parent.PSGI || $.connection.parent.P6SGI
  {
    my $nph = $.connection.parent.NPH;
    $http_message = encode-psgi-response($response-data, :$nph);
  }
  else 
  {
    if $.connection.parent.NPH && $response-data !~~ /^HTTP/ 
    {
      $response-data ~~ s:g/^ Status: \s* (\d+) \s* (\w)* $//;
      my $code = +$0;
      my $message;
      if ($1) 
      {
        $message = ~$1;
      }
      else 
      {
        $message = get_http_status_msg($code);
      }
      $http_message = "HTTP/1.1 $code $message"~CRLF~$response-data;
    }
    else 
    {
      $http_message = $response-data; 
    }
  }
  $.connection.socket.send($http_message);
}

