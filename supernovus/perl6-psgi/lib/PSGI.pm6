## Some helpers for PSGI frameworks.
module PSGI;

use HTTP::Status;

constant CRLF = "\x0D\x0A";              ## Output lines separated by CRLF.
constant STATUS_HEADER = 'Status: ';     ## Used for Parsed Headers.
constant DEFAULT_PROTOCOL = 'HTTP/1.0';  ## Used for Non-Parsed Headers.

## Encode a PSGI-compliant response.
## The Code must be a Str or Int representing the numeric HTTP status code.
## Headers can be an Array of Pairs, or a Hash.
## Body can be an Array, a Str or a Buf.
multi sub encode-psgi-response (
  $code, $headers, $body,                      ## Required parameters.
  Bool :$nph, :$protocol=DEFAULT_PROTOCOL      ## Optional parameters.
) is export {
  my Str $output;
  my $message = get_http_status_msg($code);
  if $nph {
    $output = "$protocol $code $message" ~ CRLF;
  }
  else {
    $output = STATUS_HEADER ~ "$code $message" ~ CRLF;
  }
  my @headers;
  if $headers ~~ Array {
    @headers = @$headers;
  }
  elsif $headers ~~ Hash {
    @headers = $headers.pairs;
  }
  for @headers -> $header {
    if $header !~~ Pair { warn "invalid PSGI header found"; next; }
    $output ~= $header.key ~ ': ' ~ $header.value ~ CRLF;
  }
  $output ~= CRLF; ## Finished with headers.
  my @body;
  if $body ~~ Array {
    @body = @$body;
  }
  else {
    @body = $body;
  }
  for @body -> $segment {
    if $segment ~~ Buf {
      if $output ~~ Buf {
        $output ~= $segment;
      }
      else {
        $output = $output.encode ~ $segment;
      }
    }
    else {
      if $output ~~ Buf {
        $output ~= $segment.Str.encode;
      }
      else {
        $output ~= $segment.Str;
      }
    }
  }
  return $output;
}

## A version that takes the traditional Array of three elements,
## and uses them as the positional parameters for the above version.
multi sub encode-psgi-response (
  @response,
  Bool :$nph, :$protocol=DEFAULT_PROTOCOL
) is export {
  encode-psgi-response(|@response, :$nph, :$protocol);
}
