# SCGI for Perl 6

## Introduction

This is a simple SCGI library for Perl 6.

It's main influences are the Perl 5 SCGI library, and the
Perl 6 HTTP::Daemon library.

It offers a bit of candy coating compared to the Perl 5 version.

By default is uses a PSGI-compliant interface, but can also handle
raw HTTP responses.

You don't need to create your own IO::Socket::INET object.
Just pass an 'addr' and 'port' attribute to the new() declaration and it'll
create the object for you.

## Usage

The simplest (and recommended) form of usage is to use the handle() method
with PSGI-compliant output. Here's an example:

```perl
  use SCGI;

  my $scgi = SCGI.new( :port(8118) );

  my $handler = sub (%env) 
  {
    my $name = %env<QUERY_STRING> || 'world';
    my $status = '200';
    my @headers = 'Content-Type' => 'text/plain';
    my @body = "Hello $name\n";
    @headers.push: 'Content-Length' => @body.join.encode.bytes;
    return [ $status, @headers, @body ];
  }

  $scgi.handle: $handler;
```

There are other ways of using SCGI, such as writing your own run loop,
or using a raw HTTP output instead of PSGI. Here's an example doing both:

```perl
  use SCGI;

  my $scgi = SCGI.new( :port(8118), :!PSGI, :!P6SGI );
  while (my $connection = $scgi.accept())
  {
    my $request = $connection.request;
    if $request.success
    {
      my $name = $request.env<QUERY_STRING> || 'world';
      my $return = "Hello $name\n";
      my $len = $return.encode.bytes;
      my $headers = "Content-Type: text/plain\nContent-Length: $len\n";
      $connection.send("$headers\n$return");
    }
    $connection.close;
  }
```

Test script representing both examples can be found in the 'test' folder.

If you are serious about using SCGI for web application development, see
the [Perl 6 Web](https://github.com/supernovus/perl6-web/) library set, 
or one of the full blown frameworks built using it.

## Configuration

### nginx

Make sure you compiled nginx with the SCGI plugin (it is included by default.)
Then, in one of your server blocks, add a location mount:

```nginx
  location /scgi/ {
    scgi_pass 127.0.0.1:8118;
    include scgi_params;
    # Optionally rewrite document URI path
    rewrite ^/scgi/(.*) /$1 break;
    # Some applications may need rewritten URI in PATH_INFO
    scgi_param PATH_INFO $uri;
  }
```

### lighttpd

First, make sure the SCGI library is being loaded.

```lighttpd
  server.modules += ( "mod_scgi" )
```

Next, set up an SCGI handler:

```lighttpd
  scgi.server = (
    "/scgi" =>
    ((
      "host" => "127.0.0.1",
      "port" => 8118,
      "check-local" => "disable"
    ))
  )
```

### Apache 2 with mod_scgi:

Add the following line to your site config, changing the details to match your
SCGI script configuration:

```apache
  SCGIMount /scgi/ 127.0.0.1:8118
```

### Apache 2 with mod_proxy_scgi:

Add the following line to your site config, changes the details to match your
SCGI script configuration:

```apache
  <Proxy *>
    Order deny,allow
    Allow from all
  </Proxy>
  ProxyPass /scgi/ scgi://localhost:8118/
```

## Requirements

 * [HTTP::Status](https://github.com/supernovus/perl6-http-status)
 * [Netstring](https://github.com/supernovus/perl6-netstring)

## Author 

Timothy Totten, supernovus on #perl6, https://github.com/supernovus/

## License

Artistic License 2.0

