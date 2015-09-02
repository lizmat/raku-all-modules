## Some helpers for PSGI frameworks.
unit module PSGI;

use HTTP::Status;

constant CRLF = "\x0D\x0A";              ## Output lines separated by CRLF.
constant STATUS_HEADER = 'Status: ';     ## Used for Parsed Headers.
constant DEFAULT_PROTOCOL = 'HTTP/1.0';  ## Used for Non-Parsed Headers.

## Encode a PSGI-compliant response.
## The Code must be a Str or Int representing the numeric HTTP status code.
## Headers can be an Array of Pairs, or a Hash.
## Body can be an Array, a Str or a Buf.
multi sub encode-psgi-response (
  Int(Any) $code, $headers, $body,             ## Required parameters.
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

  if ($body ~~ Supply)
  {
    $body.tap(-> $segment {
      if $segment ~~ Buf {
        if $output ~~ Buf {
          $output ~= $segment;
        }
        else {
          $output = $output.encode('UTF-8') ~ $segment;
        }
      }
      else {
        if $output ~~ Buf {
          $output ~= $segment.Str.encode('UTF-8');
        }
        else {
          $output ~= $segment.Str;
        }
      }
    });
    $body.wait;
  }
  else
  {
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
  }

  return $output;
}

## A version that takes a Promise.
multi sub encode-psgi-response (
  Promise(Any) $p,
  Bool :$nph, :$protocol=DEFAULT_PROTOCOL
) is export {
  encode-psgi-response($p.result, :$nph, :$protocol);
}

## A version that takes the traditional Array of three elements,
## and uses them as the positional parameters for the above version.
multi sub encode-psgi-response (
  @response,
  Bool :$nph, :$protocol=DEFAULT_PROTOCOL
) is export {
  encode-psgi-response(|@response, :$nph, :$protocol);
}

## Take an environment hash, and populate the P6SGI/PSGI variables.
sub populate-psgi-env (
    %env, 
    :$input,                      # input stream (if any)
    :$errors,                     # error stream (if any)
    :$input-buffered  = False,    # is input buffered? (P6SGI only)
    :$errors-buffered = False,    # are errors buffered? (P6SGI only)
    :$url-scheme      = 'http',   # HTTP or HTTPS
    :$multithread     = False,    # Can be multithreaded?
    :$multiprocess    = False,    # Can be multiprocessed?
    :$run-once        = False,    # Should only be run once in a process?
    :$encoding        = 'UTF-8',  # Character encoding (P6SGI only)
    :$nonblocking     = False,    # Non-blocking IO (PSGI Classic only)
    :$streaming       = False;    # Streaming IO (PSGI Classic only)
    :$psgi-classic    = False,    # include PSGI Classic headers
    :$p6sgi           = True,     # include P6SGI headers
) is export {
  if ($p6sgi)
  {
    %env<p6sgi.version>         = Version.new('0.4.Draft');
    %env<p6sgi.url-scheme>      = $url-scheme;
    %env<p6sgi.input>           = $input;
    %env<p6sgi.input.buffered>  = $input-buffered;
    %env<p6sgi.errors>          = $errors;
    %env<p6sgi.errors.buffered> = $errors-buffered;
    %env<p6sgi.multithread>     = $multithread;
    %env<p6sgi.multiprocess>    = $multiprocess;
    %env<p6sgi.run-once>        = $run-once;
    %env<p6sgi.encoding>        = $encoding;
  }
  if ($psgi-classic)
  {
    %env<psgi.version>       = [1,0];
    %env<psgi.url_scheme>    = $url-scheme;
    %env<psgi.multithread>   = $multithread;
    %env<psgi.multiprocess>  = $multiprocess;
    %env<psgi.input>         = $input;
    %env<psgi.errors>        = $errors;
    %env<psgi.run_once>      = $run-once;
    %env<psgi.nonblocking>   = $nonblocking;
  }
}

