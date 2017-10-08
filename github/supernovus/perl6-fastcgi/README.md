# FastCGI for Perl 6 #

A library for building web applications using FastCGI in Perl 6.
Uses a PSGI-compliant interface by default, so you can use it with
any PSGI-compliant frameworks, such as WWW::App.

## Status

Basic functionality works, but is currently fairly slow using the pure-perl
implementation of the FastCGI protocol.

I haven't done any extensive testing using input streams or error streams.

## Example

Currently the use of the handler() call is required.
More advanced use, such as with the new SCGI is planned, but will require
some significant refactoring.

```perl
use FastCGI;

my $fcgi = FastCGI.new( :port(9119) );

my $handler = sub (%env) 
{
  my $name = %env<QUERY_STRING> || 'World';
  my $status = '200';
  my @headers = 'Content-Type' => 'text/plain';
  my @body = "Hello $name\n";;
  return [ $status, @headers, @body ];
}

$fcgi.handle: $handler;
```



## Requirements

This requires a Perl 6 implementation that can export constants, and has
the pack() and unpack() methods with at least 'C', 'n', 'N', and 'x' format
codes supported.

## TODO

 * Test the STDIN and STDERR streams.
 * Rename FastCGI::Protocol to FastCGI::Protocol:PP
 * Add FastCGI::Protocol::NativeCall as a wrapper to libfcgi
 * Write new FastCGI::Protocol wrapper that uses either PP or NativeCall
 * Refactor the Connection/Request code to allow for custom request loops.

## Author

This was build by Timothy Totten. You can find me on #perl6 with the nickname supernovus.

## License

Artistic License 2.0

