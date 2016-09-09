unit class HTTP::Request::Supply;

=NAME HTTP::Request::Supply - A modern HTTP/1.x request parser

=begin SYNOPSIS

    use HTTP::Request::Supply;

    react {
        whenever IO::Socket::Async.listen('localhost', 8080) -> $conn {
            my $envs = HTTP::Request::Supply.parse-http($conn);
            whenever $envs -> %env {
                my $res = await app(%env);
                handle-response($conn, $res);

                QUIT {
                    when X::HTTP::Request::Supply::UnsupportedProtocol && .looks-httpish {
                        $conn.print("505 HTTP Version Not Supported HTTP/1.1\r\n");
                        $conn.print("Content-Length: 26\r\n");
                        $conn.print("Content-Type: text/plain\r\n\r\n");
                        $conn.print("HTTP Version Not Supported\r\n");
                    }

                    when X::HTTP::Request::Supply::BadRequest {
                        $conn.print("400 Bad Request HTTP/1.1\r\n");
                        $conn.print("Content-Length: " ~ .message.encode.bytes ~ \r\n");
                        $conn.print("Content-Type: text/plain\r\n\r\n");
                        $conn.print(.message);
                        $conn.print("\r\n");
                    }

                    # N.B. This exception should be rarely emitted and indicates that a
                    # feature is known to exist in HTTP, but this module does not yet
                    # support it.
                    when X::HTTP::Request::Supply::ServerError {
                        $conn.print("500 Internal Server Error HTTP/1.1\r\n");
                        $conn.print("Content-Length: " ~ .message.encode.bytes ~ \r\n");
                        $conn.print("Content-Type: text/plain\r\n\r\n");
                        $conn.print(.message);
                        $conn.print("\r\n");
                    }

                    warn .message;
                    $conn.close;
                }
            }
        }
    }

=end SYNOPSIS

=begin DESCRIPTION

B<EXPERIMENTAL:> The API for this module is experimental and may change.

The L<HTTP::Parser> ported from Perl 5 (and the implementation in Perl 5) is
naïve and really only parses a single HTTP frame (i.e., it provides no
keep-alive support). However, that is not how the HTTP protocol typically works
on the modern web.

This class provides a L<Supply> that is able to parse a series of request frames
from an HTTP/1.x connection. Given a L<Supply>, it consumes binary input from
it. It detects the request frame or frames within the stream and passes them
back to the tapper asynchronously as they arrive.

This Supply emits L<P6WAPI> compatible environments for use by the caller. If a
problem is detected in the stream, it will quit with an exception.

=end DESCRIPTION

=begin pod

=head1 METHODS

=head2 sub parse-http

    sub parse-http(Supply:D() :$conn, :&promise-maker) returns Supply:D

The given L<Supply>, C<$conn>, must emit a stream of bytes. Any other data will
result in undefined behavior. This parser assumes binary data will be sent.

The returned supply will react whenever data is emitted on the input supply. The
incoming bytes are collated into HTTP frames, which are parsed to determine the
contents of the headers. Headers are encoded into strings via ISO-8859-1 (as per
L<RFC7230 §3.2.4|https://tools.ietf.org/html/rfc7230#section-3.2.4>).

Once the headers for a given frame have been read, a partial L<P6WAPI> compatible
environment is generated from the headers and emitted to the returned Supply.
The environment will be filled as follows:

=item The C<Content-Length> will be set in C<CONTENT_LENGTH>.

=item The C<Content-Type> will be set in C<CONTENT_TYPE>.

=item Other headers will be set in C<HTTP_*> where the header name is converted
to uppercase and dashes are replaced with underscores.

=item The C<REQUEST_METHOD> will be set to the method set in the request line.

=item The C<SERVER_PROTOCOL> will be set to the protocol set in the request
line.

=item The C<REQUEST_URI> will be set to the URI set in the request line.

=item The C<p6w.input> variable will be set to a sane L<Supply> that emits
chunks of the body as bytes as they arrive. No attempt is made to decode these
bytes.

All other keys are left empty.

=head1 DIAGNOSTICS

The following exceptions are thrown by this class while processing input, which
will trigger the quit handlers on the Supply.

=head2 X::HTTP::Request::Supply::UnsupportedProtocol

This exception will be thrown if the stream does not seem to be HTTP or if the
requested HTTP version is not 1.0 or 1.1.

This exception includes two attributes:

=item C<looks-httpish> is a boolean value that is set to True if the data sent
resembles HTTP, but the server protocol string does not match either "HTTP/1.0"
or "HTTP/1.1", e.g., an HTTP/2 connection preface.

=item C<input> is a L<Supply> that may be tapped to consume the complete stream
including the bytes already read. This allows chaining of modules similar to
this one to handle other protocols that might happen over the web server's
port.

=head2 X::HTTP::Request::Supply::BadRequest

This exception will be thrown if the HTTP request is incorrectly framed. This
may happen when the request does not specify its content length using a
C<Content-Length> header or chunked C<Transfer-Encoding>.

=head2 X::HTTP::Request::Supply::ServerError

This exception may be thrown when a feature of HTTP/1.0 or HTTP/1.1 is not
implemented.

=head1 CAVEATS

HTTP is complicated and hard. This implementation is not yet complete and not
battle tested yet. Please report bugs to github and patches are welcome.

This interface is built with the intention of making it easier to build HTTP/1.0
and HTTP/1.1 parsers for use with L<P6WAPI>. As of this writing, that
specification is only a proposed draft, so the output of this module is
experiemental and will change as that specification changes.

Finally, one limitation of this module is that it is only responsible for
parsing the incoming HTTP frames. It will not manage the connection and it
provides no tools for sending responses back to the user agent.

=head1 AUTHOR

Sterling Hanenkamp C<< <hanenkamp@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2016 Sterling Hanenkamp.

This software is licensed under the same terms as Perl 6.

=end pod

class GLOBAL::X::HTTP::Request::Supply::UnsupportedProtocol is Exception {
    has Bool:D $.looks-httpish is required;
    has Supply:D $.input is required;
    method message() {
        $.looks-httpish ?? "HTTP version is not supported."
                        !! "Unknown protocol."
    }
}

class GLOBAL::X::HTTP::Request::Supply::BadRequest is Exception {
    has $.reason is required;
    method message() { $!reason }
}

class GLOBAL::X::HTTP::Request::Supply::ServerError is Exception {
    has $.reason is required;
    method message() { $!reason }
}

my constant CR = 0x0d;
my constant LF = 0x0a;

my sub scan-for-header-end(:$scan-start, :$buf) {
    for $scan-start .. $buf.bytes - 4 -> $i {
        # note $buf[$i..$i+3].map(*.fmt("%02X")) ~ " " ~ buf8.new($buf[$i..$i+3]).decode.subst(/\r?\n/, '||', :g);
        next unless $buf[$i..$i+3] eqv (CR,LF,CR,LF);
        #note "BREAK";

        return $i;
    }

    return -1;
}

my sub parse-header($header-buf, Bool :$include-request-line = True, :&other-sink) {

    # note "[{$header-buf.decode}]";

    my @headers = $header-buf.decode('iso-8859-1').split("\r\n");

    my %env;
    if $include-request-line {
        my $request-line = @headers.shift;

        my ($method, $uri, $http-version) = $request-line.split(' ');

        # Looks HTTP-ish, but not our thing... quit now!
        if $http-version ~~ none('HTTP/1.0', 'HTTP/1.1') {
            X::HTTP::Request::Supply::UnsupportedProtocol.new(
                looks-httpish => True,
                input         => other-sink($header-buf),
            ).throw;

        }

        %env =
            REQUEST_METHOD  => $method,
            REQUEST_URI     => $uri,
            SERVER_PROTOCOL => $http-version,
            ;
    }

    my $last-header;
    for @headers -> $header {
        if $last-header && $header ~~ /^\s+/ {
            $last-header.value ~= $header.trim-leading;
        }
        else {
            my ($name, $value) = $header.split(": ");
            $name.=lc.=subst('-', '_');
            $name = "HTTP_" ~ $name.uc;

            if %env{ $name } :exists {
                %env{ $name } ~= ',', $value;
            }
            else {
                %env{ $name } = $value;
            }

            $last-header := %env{ $name } :p;
        }
    }

    if %env<HTTP_CONTENT_TYPE> :delete :v -> $content-type {
        %env<CONTENT_TYPE> = $content-type;
    }

    if %env<HTTP_CONTENT_LENGTH> :delete :v -> $content-length {
        %env<CONTENT_LENGTH> = $content-length;
    }

    return %env;
}

multi method parse-http(Supply:D() $conn) returns Supply:D {
    supply {
        my buf8 $buf .= new;

        # Shared
        my $parser-event = Supplier::Preserving.new;
        my enum <Header Body Closed Other Error>;
        my $mode = Header;
        my %env;
        my Bool $close = False;
        my Bool $no-more-input = False;

        # Header mode
        my $scan-start = 0;

        # Body mode
        my $emitted-bytes = 0;
        my Supplier $body-sink;

        # Other mode
        my Supplier $other-sink;

        # Closed mode
        my Bool $has-closed = False;

        whenever $parser-event.Supply {
            given $mode {
                when Error {
                    # We are in a bad state at this point, ignore any
                    # other parser-events remaining in the queue. If we
                    # are here, then we should have quit already.
                }
                when Closed {
                    unless $has-closed++ {
                        # note "HTTP DONE";
                        done;
                    }
                }
                when Header {
                    my $header-end = scan-for-header-end(:$scan-start, :$buf);

                    # Found the end of headers, let's get parsing
                    if $header-end > 0 {
                        %env := parse-header($buf.subbuf(0, $header-end),
                            :other-sink(-> $header-buf {
                                $other-sink := Supplier::Preserving.new;
                                $other-sink.emit($header-buf);
                                $other-sink.Supply
                            }),
                        );
                        $buf          .= subbuf($header-end + 4);

                        $body-sink = Supplier::Preserving.new;
                        # note "body-sink = ", $body-sink.WHICH;
                        %env<p6w.input> = $body-sink.Supply;

                        # dd %env;
                        emit %env;

                        my $http-connection = %env<HTTP_CONNECTION> // '';
                        if %env<SERVER_PROTOCOL> eq 'HTTP/1.0' {
                            $close = True if $http-connection ne 'keep-alive';
                        }
                        else {
                            $close = True if $http-connection eq 'close';
                        }

                        # note "SWITCH TO BODY";
                        $mode = Body;
                        $emitted-bytes = 0;
                        $parser-event.emit(True);

                        CATCH {
                            when X::HTTP::Request::Supply::UnsupportedProtocol {
                                $mode = Other;
                                $parser-event.emit(True);
                                .rethrow;
                            }
                            default {
                                $mode = Error;
                                .rethrow;
                            }
                        }
                    }

                    # Don't scan from the very start next time to save some
                    # effort
                    else {
                        $scan-start = $buf.bytes;
                    }

                    # We have searched for the end of this header and
                    # didn't find it. We are getting no more input from the
                    # input stream, so time to give up.
                    if $mode === Header && $no-more-input {
                        # note "SWITCH TO Closed";
                        $mode = Closed;
                        $parser-event.emit(True);
                    }
                }
                when Body {
                    my $finished-body = False;

                    # note "READING BODY";
                    if %env<HTTP_TRANSFER_ENCODING>.defined && %env<HTTP_TRANSFER_ENCODING> eq 'chunked' {
                        my enum <Size Chunk Trailers Done>;
                        my $state = Size;
                        my $size = 0;
                        while $state !=== Done {
                            # note "state = $state";
                            given $state {
                                when Size {
                                    my $size-end;
                                    for 0..$buf.bytes - 2 -> $i {
                                        next unless $buf[$i..$i+1] eqv (CR,LF);

                                        $size-end = $i;
                                        # note "size-end = $size-end";
                                        last;
                                    }

                                    if $size-end -> $i {
                                        $size = $buf.subbuf(0, $i).decode('ascii');
                                        # note "size originally = $size";

                                        # throw away extension details, if any
                                        $size .= subst(/';' .*/, '');
                                        # note "size so far = $size";
                                        $size  = :16($size);
                                        # note "size = $size";

                                        $state = Chunk;
                                        $buf.=subbuf($i+2);
                                        # note "buf = {$buf.decode}";
                                    }
                                }
                                when Chunk {
                                    # note "Chunk size = $size";
                                    # note "buf.bytes = {$buf.bytes}";
                                    # note "no-more-input = $no-more-input";
                                    # Last chunk, consume empty chunk and handle
                                    # trailers
                                    if $size == 0 {
                                        $state = Trailers;
                                    }

                                    # Emit the current chunk, go back to look
                                    # for size again
                                    elsif $buf.bytes >= $size {
                                        # note "emit {$buf.subbuf(0, $size).decode}";
                                        $body-sink.emit($buf.subbuf(0, $size));
                                        $buf.=subbuf($size+2);
                                        $state = Size;
                                    }

                                    # We need more data, but no more is coming.
                                    # Skip trailers and just quit.
                                    elsif $no-more-input {
                                        $finished-body = True;
                                        $state = Done;
                                    }

                                    # We don't have the whole chunk yet, we'll
                                    # come back for it later.
                                    else {
                                        $buf = $size.fmt("%X").encode('ascii')
                                             ~ CR ~ LF ~ $buf;
                                        $state = Done;
                                    }
                                }
                                when Trailers {
                                    my $header-end = scan-for-header-end(:0scan-start, :$buf);

                                    # 0 or more trailing headers found, chunking
                                    # is now complete.
                                    if $header-end > -1 {
                                        if $header-end > 0 {
                                            my %trailers = parse-header(
                                                $buf.subbuf(0, $header-end),
                                                :!include-request-line,
                                            );
                                            $buf .= subbuf($header-end + 4);

                                            # note "body emit {%trailers.perl}";
                                            $body-sink.emit(%trailers);
                                        }

                                        # Parse the next header
                                        $state = Done;
                                        $finished-body = True;
                                    }

                                    # We didn't find the end of the body, but we
                                    # aren't receiving anymore input either, so
                                    # it's time to quit anyway.
                                    elsif $no-more-input {
                                        $state = Done;
                                        $finished-body = True;
                                    }

                                    # Failed to find the last trailer, quit and
                                    # come back later
                                    else {
                                        $buf = "0".encode('ascii')
                                            ~ CR ~ LF ~ $buf;
                                        $state = Done;
                                    }
                                }
                            }
                        }
                    }

                    elsif %env<CONTENT_LENGTH> -> $content-length {
                        # note "content-length: $content-length";

                        # Do we expect more bytes?
                        my $need-bytes = $content-length - $emitted-bytes;
                        # note "need-bytes = $need-bytes";
                        # note "buf.bytes = {$buf.bytes}";
                        # note "GOING TO OUTPUT? {$need-bytes > 0 && $buf.bytes > 0}";
                        if $need-bytes > 0 && $buf.bytes > 0 {

                            # Emit as many bytes as we can, but not more than we expect.
                            my $output-bytes = $buf.bytes min $need-bytes;
                            # note "body-sink = ", $body-sink.WHICH;
                            # note "<{$buf.subbuf(0, $output-bytes).decode}>";
                            $body-sink.emit($buf.subbuf(0, $output-bytes));
                            $emitted-bytes += $output-bytes;

                            # Remove emitted bytes from buffer
                            $buf .= subbuf($output-bytes);
                            $need-bytes -= $output-bytes;
                        }

                        $finished-body = $need-bytes == 0;
                        # note "finished-body = $finished-body";
                    }

                    else {
                        $mode = Error;
                        my $x = X::HTTP::Request::Supply::BadRequest.new(
                            reason => 'client did not specify entity length',
                        );
                        $body-sink.quit($x);
                        die $x;
                    }

                    # Regardless of body type we parse, we need to close the
                    # parser or move to the next header when finished.

                    # If we see that No more input is coming and we are out of
                    # bytes to parse, we need to stop here.
                    # note "buf.bytes = {$buf.bytes}";
                    # note "no-more-input = {$no-more-input}";
                    $finished-body = True
                        if $buf.bytes == 0 && $no-more-input;

                    # Finish the body when we meet expectations.
                    if $finished-body {
                        # note "BODY DONE ", $body-sink.WHICH;
                        $body-sink.done;
                        $close = True if $buf.bytes == 0 && $no-more-input;
                        $mode = $close ?? Closed !! Header;
                        # note "SWITCHING TO $mode";
                        $scan-start = 0;
                        $parser-event.emit(True);
                    }
                }
                when Other {
                    $other-sink.emit($buf) if $buf.bytes > 0;
                    $buf = buf8.new;
                    if $no-more-input {
                        # note "OTHER DONE";
                        done;
                    }
                }
                default { die "internal error" }
            }
        }

        whenever $conn -> $chunk {
            LAST {
                # note "NO MORE INPUT";
                $no-more-input++;
                $parser-event.emit(True);
            }
            QUIT { .rethrow }

            $buf ~= $chunk;

            $parser-event.emit(True);
        }
    }
}
