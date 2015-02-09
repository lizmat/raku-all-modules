class IO::Socket::SSL;

use OpenSSL;
use OpenSSL::Err;

sub v4-split($uri) {
    $uri.split(':', 2);
}
sub v6-split($uri) {
    my ($host, $port) = ($uri ~~ /^'[' (.+) ']' \: (\d+)$/)[0, 1];
    $host ?? ($host, $port) !! $uri;
}

has Str $.encoding = 'utf8';
has Str $.host;
has Int $.port = 443;
has Str $.localhost;
has Int $.localport;
has Str $.certfile;
has Bool $.listen;
has Str $.input-line-separator is rw = "\n";
has Int $.ins = 0;

has $.client-socket;
has $.listen-socket;
has $.accepted-socket;
has $!socket;
has OpenSSL $.ssl;

method new(*%args is copy) {
    fail "Nothing given for new socket to connect or bind to" unless %args<host>
                                                                  || %args<listen>
                                                                  || %args<client-socket>
                                                                  || %args<accepted-socket>
                                                                  || %args<listen-socket>;

    if %args<host> {
        my ($host, $port) = %args<family> && %args<family> == PIO::PF_INET6()
            ?? v6-split(%args<host>)
            !! v4-split(%args<host>);
        if $port {
            %args<port> //= $port;
            %args<host> = $host;
        }
    }
    if %args<localhost> {
        my ($peer, $port) = %args<family> && %args<family> == PIO::PF_INET6()
            ?? v6-split(%args<localhost>)
            !! v4-split(%args<localhost>);
        if $port {
            %args<localport> //= $port;
            %args<localhost> = $peer;
        }
    }

    %args<listen>.=Bool if %args.exists_key('listen');

    self.bless(|%args)!initialize;
}

method !initialize {
    if $!client-socket || ($!host && $!port) {
        # client stuff
        $!socket = $!client-socket || IO::Socket::INET.new(:host($!host), :port($!port));

        # handle errors
        $!ssl = OpenSSL.new(:client);
        $!ssl.set-socket($!socket);
        $!ssl.set-connect-state;
        my $ret = $!ssl.connect;
        if $ret < 0 {
            my $e = OpenSSL::Err::ERR_get_error();
            repeat {
                say "err code: $e";
                say OpenSSL::Err::ERR_error_string($e);
               $e = OpenSSL::Err::ERR_get_error();
            } while $e != 0 && $e != 4294967296;
        }
    }
    elsif $!accepted-socket {
        $!socket = $!accepted-socket;
        
        $!ssl = OpenSSL.new();
        $!ssl.set-socket($!socket);
        $!ssl.set-accept-state;
        
        $!ssl.use-certificate-file($!certfile);
        $!ssl.use-privatekey-file($!certfile);
        $!ssl.check-private-key;
        
        my $ret = $!ssl.accept;
        if $ret < 0 {
            my $e = OpenSSL::Err::ERR_get_error();
            repeat {
                say "err code: $e";
                say OpenSSL::Err::ERR_error_string($e);
               $e = OpenSSL::Err::ERR_get_error();
            } while $e != 0 && $e != 4294967296;
        }
    }
    elsif $!listen-socket || $!listen {
        $!socket = $!listen-socket || IO::Socket::INET.new(:localhost($!localhost), :localport($!localport), :listen);
    }
    self;
}

method recv(Int $n = 1048576, Bool :$bin = False) {
    $!ssl.read($n, :$bin);
}

method read(Int $n) {
    my $res = buf8.new;
    my $buf;
    repeat {
        $buf = self.recv($n - $res.elems, :bin);
        $res ~= $buf;
    } while $res.elems < $n && $buf.elems;
    $res;
}

method send(Str $s) {
    $!ssl.write($s);
}

method write(Blob $b) {
    $!ssl.write($b);
}

method get() {
    my $buf = buf8.new;
    loop {
        my $more = self.recv(1, :bin);
        if !$more {
            return Str unless $buf.bytes;
            return $buf.decode;
        }
        $buf ~= $more;
        my $str = $buf.decode;
        if $str && $str.index($.input-line-separator) {
            return $str.substr(0, $str.chars - $.input-line-separator.chars);
        }
    }
}

method accept {
    my $newsock = $!socket.accept;
    self.bless(:accepted-socket($newsock))!initialize;
}

method close {
    $!ssl.close;
    $!socket.close;
}

=begin pod

=head1 NAME

IO::Socket::SSL - interface for SSL connection

=head1 SYNOPSIS

    use IO::Socket::SSL;
    my $ssl = IO::Socket::SSL.new(:host<example.com>, :port(443));
    if $ssl.send("GET / HTTP/1.1\r\n\r\n") {
        say $ssl.recv;
    }

=head1 DESCRIPTION

This module provides an interface for SSL connections.

It uses C to setting up the connection so far (hope it will change soon).

=head1 METHODS

=head2 method new

    method new(*%params) returns IO::Socket::SSL

Gets params like:

=item encoding             : connection's encoding
=item input-line-separator : specifies how lines of input are separated

for client state:
=item host : host to connect
=item port : port to connect

for server state:
=item localhost : host to use for the server
=item localport : port for the server
=item listen    : create a server and listen for a new incoming connection
=item certfile  : path to a file with certificates

=head2 method recv

    method recv(IO::Socket::SSL:, Int $n = 1048576, Bool :$bin = False)

Reads $n bytes from the other side (server/client).

Bool :$bin if we want it to return Buf instead of Str.

=head2 method send

    method send(IO::Socket::SSL:, Str $s)

Sends $s to the other side (server/client).

=head2 method accept

    method accept(IO::Socket::SSL:)

Waits for a new incoming connection and accepts it.

=head2 close

    method close(IO::Socket::SSL:)

Closes the connection.

=head1 SEE ALSO

L<OpenSSL>

=head1 EXAMPLE

To download sourcecode of e.g. github.com:

    use IO::Socket::SSL;
    my $ssl = IO::Socket::SSL.new(:host<github.com>, :port(443));
    my $content = Buf.new;
    $ssl.send("GET /\r\n\r\n");
    while my $read = $ssl.recv {
        $content ~= $read;
    }
    say $content;

=end pod
