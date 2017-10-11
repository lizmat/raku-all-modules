use v6.c;

use NativeCall;

=begin pod

=head1 NAME

FastCGI::NativeCall - An implementation of FastCGI for Perl 6 using NativeCall

=head1 SYNOPSIS

=begin code

use FastCGI::NativeCall;

my $fcgi = FastCGI::NativeCall.new(path => "/tmp/fastcgi.sock", backlog => 32 );

my $count = 0;

while $fcgi.accept() {
	say $fcgi.env;
    $fcgi.header(Content-Type => "text/html");
    $fcgi.Print("{ ++$count }");
}

=end code

=head1 DESCRIPTION

L<FastCGI|https://fastcgi-archives.github.io/> is a protocol that allows
an HTTP server to communicate with a persistent application over a
socket, thus removing the process startup overhead of, say, traditional
CGI applications.  It is supported as standard (or through supporting
modules,) by most common HTTP server software (such as Apache, nginx,
lighthttpd and so forth.)

This module provides a simple mechanism to create FastCGI server
applications in Perl 6.

The FastCGI servers are single threaded, but with good support from
the front end server and tuning of the configuration it can be quite
efficient.

=head1 METHODS

=head2 method new

    method new(Str :$path, Int :$backlog = 16)

The constructor must be supplied with the path where the listening Unix domain
socket will be created, the location must be accessible to both your program
and the host HTTP server which will be delivering the requests.

The C<backlog> option, which defaults to 16, is the number of yet to be
accepted requests that can be queued before subsequent requests receive
an error, you may want to adjust this (in concert with the configuration
of your host HTTP server,) to achieve an acceptable level of throughput
for your application.

    method new(Int $socket)

This is the original constructor which must be passed the file descriptor of
an already opened and listening socket.  A suitable socket can be created
with the C<OpenSocket> helper described below, or you may have got one from
another source.

=head2 method Accept

    method Accept(--> Int)

This blocks until a new request is received, returning a value that indicates
success of zero or greater.

When this returns indicating success, the environment returned by C<env> is
populated and you may use C<Print> to return data to the client.

You may prefer C<accept>.

=head2 method accept

    method accept(--> Bool)

This is the same as C<Accept> above except it returns a Bool to indicate success
or otherwise.

=head2 method env

    method env(--> Hash)

This returns a Hash containing the "environment" as determined by the FastCGI
protocol, this may be dependent on the configuration of your host HTTP server.

=head2 method header

    multi method header(*%header)
    multi method header(%header)

This is a helper to output the header of the response with the correct line endings
and the header/body separator from either the named header fields or from a Hash
containing the header fields.  If you want to return an HTTP status other than the
default '200' then the C<Status> header should be added.

=head2 method Print

    method Print(Str $content)

This returns data, both headers and body content to the server to be sent to
the client. This is somewhat un-sugared so if you are sending headers then each
line must end in a carriage return, line feed pair and the headers must be
separated from the body similarly.

=head2 method Read

    method Read(Int $length --> Str)

This reads any body content from the request to the requested length, because it
returns a string  it will not work very nicely at all with binary data such as
an image or audio file.

=head2 method close

    method close()

The finishes the current request and closes the socket, after which there will
be no new requests and the host HTTP server will get an error.

=head1 HELPER FUNCTIONS

These are part of the original interface and kept for compatibility.  They aren't
exported so must be called with the full package name.

=head2 sub OpenSocket

    sub OpenSocket(Str $path, Int $backlog --> Int)

This returns the file descriptor of a listening Unix domain socket opened at
the specified path and with the specified backlog. You probably want to use
the named argument version of the constructor instead.

=head2 sub CloseSocket

    sub CloseSocket(Int $socket-fd)

This closes the socket returned by the C<OpenSocket> above.  You may prefer
to use the C<close> method instead.

=end pod


class FastCGI::NativeCall {
    my constant HELPER = %?RESOURCES<libraries/fcgi>.Str;

    class FCGX_Request is Pointer is repr('CPointer') { }


    sub FCGX_OpenSocket(Str $path, int32 $backlog)
    is native(HELPER) returns int32 { ... }

    sub XS_Init(int32 $sock)
    is native(HELPER) returns FCGX_Request { ... }

    sub XS_Accept(FCGX_Request $request, &populate_env_callback (Str, Str))
    is native(HELPER) returns int32 { ... }

    sub XS_Print(Str $str, FCGX_Request $request)
    is native(HELPER) returns int32 { ... }

    sub XS_Read(int32 $n, FCGX_Request $request)
    is native(HELPER) returns Pointer { ... }

    sub XS_Flush(FCGX_Request $request)
    is native(HELPER) { ... }

    sub XS_Finish(FCGX_Request $request)
    is native(HELPER) { ... }

    sub free(Pointer $ptr) is native { ... }

    my Lock $accept_mutex = Lock.new();

    has FCGX_Request $!fcgx_req;

    my %env;

    method env { %env; }

    my sub populate_env(Str $key, Str $value) {
        %env{$key} = $value;
    }

    proto method new(|c) { * }

    multi method new(Int $sock) {
        DEPRECATED('named argument');
        self.bless(:$sock);
    }

    multi method new(Int :$sock!) {
        self.bless(:$sock);
    }

    multi method new(Str :$path!, Int :$backlog = 16 ) {
        my $sock = OpenSocket($path, $backlog);
        self.bless(:$sock);
    }

    has $!sock;

    submethod BUILD(:$!sock!) {
        $!fcgx_req = XS_Init($!sock);
    }

    our sub OpenSocket(Str $path, Int $backlog) {
        return FCGX_OpenSocket($path, $backlog);
    }

    our sub CloseSocket(Int $socket) {
        sub close(int32 $d) is native { ... }
        close($socket);
    }

    method close() {
        self.Finish();
        CloseSocket($!sock);
    }

    method Accept() {
        self.Finish();
        %env = ();
        my $ret;
        $accept_mutex.protect( -> {
            $ret = XS_Accept($!fcgx_req, &populate_env);
        });
        $ret;
    }

    method accept(--> Bool) {
        self.Accept() >= 0;;
    }

    proto method header(|c) { * }

    multi method header(*%header) {
        self.header(%header);
    }

    multi method header(%header) {
        my $header = %header.pairs.map( -> ( :$key, :$value ) { "$key: $value" }).join("\r\n") ~ "\r\n\r\n";
        self.Print($header);
    }

    method Print(Str $content) {
        XS_Print($content, $!fcgx_req);
    }

    method Read(Int $length --> Str) {
        my $ptr = XS_Read($length, $!fcgx_req);
        my $ret = nativecast(Str, $ptr);
        free($ptr);
        $ret;
    }

    method Flush() {
        XS_Flush($!fcgx_req);
    }

    method Finish() {
        XS_Finish($!fcgx_req);
    }

    method DESTROY {
        self.Finish();
        free($!fcgx_req);
    }
}

# vim: ft=perl6
