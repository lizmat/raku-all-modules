use v6;

unit class HTTP::Supply::Request;

=begin pod

=NAME HTTP::Supply::Request - A modern HTTP/1.x request parser

=begin SYNOPSIS

    use HTTP::Supply::Request;

    react {
        whenever IO::Socket::Async.listen('localhost', 8080) -> $conn {
            my $envs = HTTP::Supply::Request.parse-http($conn);
            whenever $envs -> %env {
                my $res = await app(%env);
                handle-response($conn, $res);

                QUIT {
                    when X::HTTP::Supply::UnsupportedProtocol {
                        $conn.print("505 HTTP Version Not Supported HTTP/1.1\r\n");
                        $conn.print("Content-Length: 26\r\n");
                        $conn.print("Content-Type: text/plain\r\n\r\n");
                        $conn.print("HTTP Version Not Supported\r\n");

                        .note;
                        $conn.close;
                    }

                    when X::HTTP::Supply::BadMessage {
                        $conn.print("400 Bad Request HTTP/1.1\r\n");
                        $conn.print("Content-Length: " ~ .message.encode.bytes ~ \r\n");
                        $conn.print("Content-Type: text/plain\r\n\r\n");
                        $conn.print(.message);
                        $conn.print("\r\n");

                        .note;
                        $conn.close;
                    }

                    default {
                        $conn.print("500 Internal Server Error HTTP/1.1\r\n");
                        $conn.print("Content-Length: 22\r\n");
                        $conn.print("Content-Type: text/plain\r\n\r\n");
                        $conn.print("Internal Server Error\r\n");

                        .note;
                        $conn.close;
                    }
                }
            }
        }
    }

=end SYNOPSIS

=begin DESCRIPTION

B<EXPERIMENTAL:> The API for this module is experimental and may change.

This class parses incoming data from a connection and returns a L<Supply> that
emits request frames as they are parsed out of the HTTP/1.x connection.  The
connection is given as a Supply and it consumes binary input from it. It detects
the request frame or frames within the stream and passes them back to any taps
on the supply asynchronously as they arrive.

This Supply emits partial L<P6WAPI> compatible environments for use by the
caller. If a problem is detected in the stream, it will quit with an exception.

=end DESCRIPTION

=head1 METHODS

=head2 method parse-http

    method parse-http(HTTP::Supply::Request: Supply:D() $conn, Bool :$debug = False) returns Supply:D

The given L<Supply>, C<$conn>, must emit a stream of bytes. Any other data will
result in undefined behavior. The parser assumes that only binary bytes will be
sent and makes no particular effort to verify that assumption.

The returned supply will react whenever data is emitted on the input supply. The
incoming bytes are collated into HTTP frames, which are parsed to determine the
contents of the headers. Headers are encoded into strings via ISO-8859-1 (as per
L<RFC7230 §3.2.4|https://tools.ietf.org/html/rfc7230#section-3.2.4>).

Once the headers for a given frame have been read, a partial L<P6WAPI> compatible
environment is generated from the headers and emitted to the returned Supply.
The environment will be filled as follows:

=over

=item If a C<Content-Length> header is present, it will be set in
C<CONTENT_LENGTH>.

=item If a C<Content-Type> header is present, it will be set in C<CONTENT_TYPE>.

=item Other headers will be set in C<HTTP_*> where the header name is converted
to uppercase and dashes are replaced with underscores.

=item The C<REQUEST_METHOD> will be set to the method given in the request line.

=item The C<SERVER_PROTOCOL> will be set to the protocol given in the request
line. (As of this writing, this will always be either HTTP/1.0 or HTTP/1.1 as
these are the only protocol versions this module currently supports.)

=item The C<REQUEST_URI> will be set to the URI given in the request line.

=item The C<p6w.input> variable will be set to a sane L<Supply> that emits
chunks of the body as bytes as they arrive. No attempt is made to decode these
bytes.

=back

No other keys will be set. A complete P6WAPI environment must contain many other
keys.

=head1 DIAGNOSTICS

The following exceptions are thrown by this class while processing input, which
will trigger the quit handlers on the Supply.

=head2 X::HTTP::Supply::UnsupportedProtocol

This exception will be thrown if the stream does not seem to be HTTP or if the
requested HTTP version is not 1.0 or 1.1.

=head2 X::HTTP::Supply::BadMessage

This exception will be thrown if the HTTP request is incorrectly framed. This
may happen when the request does not specify its content length using a
C<Content-Length> header or chunked C<Transfer-Encoding>.

=head1 CAVEATS

This code aims at providing a minimal implementation that is just enough to
decode the HTTP frames and provide the information about the raw requests to the
tapping code. It is not safe to assume that anything provided has been validated
or processed.

HTTP is complicated and hard. This implementation is not yet complete and not
battle tested yet. Please report bugs to github and patches are welcome. Even
once this code matures, it will never receive the TLC that a full-blown general
web server is going to get as regards hardening and maturity on the Internet. As
such, the author always recommends using this code behind an existing,
well-known, and well-maintained web server in production. This is only ever
intended as a "bare metal" application server interface.

This interface is built with the intention of making it easier to build HTTP/1.0
and HTTP/1.1 parsers for use with L<P6WAPI>. As of this writing, that
specification is only a proposed draft, so the output of this module is
experimental and will change as that specification changes.

Finally, this module only takes responsibility for parsing the incoming HTTP
frames. It does not manage the connection and it provides no tools for sending
responses back to the user agent.

=head1 AUTHOR

Sterling Hanenkamp C<< <hanenkamp@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2016 Sterling Hanenkamp.

This software is licensed under the same terms as Perl 6.

=end pod

use HTTP::Supply;
use HTTP::Supply::Body;
use HTTP::Supply::Tools;

# I rewrote parse-request-stream and heavily modeled after
# Cro::HTTP::RequestParser which does this exact thing very nicely.

method parse-http(Supply:D() $conn, Bool :$debug = False --> Supply:D) {
    sub debug(*@msg) {
        note "# Request [$*PID] [{now.Rat.fmt("%.5f")}] (#$*THREAD.id()) ", |@msg if $debug
    }

    supply {
        my enum <RequestLine Header Body Close>;
        my $expect;
        my %header;
        my %env;
        my buf8 $acc;
        my Supplier $body-sink;
        my $previous-header;
        my Promise $left-over;

        my sub new-request() {
            $expect = RequestLine;
            $acc = buf8.new;
            $acc ~= .result with $left-over;
            $left-over = Nil;
            $body-sink = Nil;
            %header := %();
            %env := %();
            $previous-header = Pair;
        }

        new-request();

        whenever $conn -> $chunk {
            LAST {
                debug("client closed the connection");

                if $expect ~~ Body {
                    $body-sink.done;
                }

                LEAVE done;
            }

            # When expecting a header, add the chunk to the accumulation buffer.
            debug("RECV ", $chunk.perl);
            $acc ~= $chunk if $expect != Body;

            # Otherwise, the chunk will be handled directly below.

            CHUNK_PROCESS: loop {
                given $expect {

                    # Ready to receive a request line
                    when RequestLine {
                        # Decode the request line
                        my $line = crlf-line($acc);

                        # We don't have a complete line yet
                        last CHUNK_PROCESS without $line;
                        debug("REQLINE [$line]");

                        # Break the line up into parts
                        my ($method, $uri, $http-version, @error) = $line.split(' ', 3);

                        # We got more than three strings, which is not okay.
                        if @error {
                            die X::HTTP::Supply::BadMessage.new(
                                reason => 'request line contains too many fields',
                            );
                        }

                        # We got just three parts, but the last is not an HTTP
                        # version we support.
                        if ($http-version//'') eq none('HTTP/1.0', 'HTTP/1.1') {

                            # Looks like an HTTP we don't support
                            if $http-version.defined && $http-version ~~ /^ 'HTTP/' <[0..9]>+ / {
                                die X::HTTP::Supply::UnsupportedProtocol.new;
                            }

                            # It is other.
                            else {
                                die X::HTTP::Supply::BadMessage.new(
                                    reason => 'request line contains garbage',
                                );
                            }
                        }

                        # Save the request line
                        %env<REQUEST_METHOD>  = $method;
                        %env<REQUEST_URI>     = $uri;
                        %env<SERVER_PROTOCOL> = $http-version;

                        # We have the request line, move on to headers
                        $expect = Header;
                    }

                    # Ready to receive a header line
                    when Header {
                        # Decode the next line from the header
                        my $line = crlf-line($acc);

                        # We don't have a complete line yet
                        last CHUNK_PROCESS without $line;

                        # Empty line signals the end of the header
                        if $line eq '' {
                            debug("HEADER END");

                            # Setup the body decoder itself
                            # TODO Someday this could be pluggable.
                            debug("HEADER ", %header.perl);
                            my $body-decoder-class = do
                                if %header<transfer-encoding>.defined
                                && %header<transfer-encoding> eq 'chunked' {
                                    HTTP::Supply::Body::ChunkedEncoding
                                }
                                elsif %header<content-length>.defined {
                                    HTTP::Supply::Body::ContentLength
                                }
                                else {
                                    Nil
                                }

                            debug("DECODER CLASS ", $body-decoder-class.WHAT.^name);

                            # Setup the stream we will send to the P6WAPI env
                            my $body-stream = Supplier::Preserving.new;
                            %env<p6w.input> = $body-stream.Supply;

                            # If we expect a body to decode, setup the decoder
                            if $body-decoder-class ~~ HTTP::Supply::Body {
                                debug("DECODE BODY");

                                # Setup the stream we will send to the body decoder
                                $body-sink = Supplier::Preserving.new;

                                # Setup the promise the body decoder can use to drop
                                # the left-overs
                                $left-over = Promise.new;

                                # Construct the decoder and tap the body-sink
                                my $body-decoder = $body-decoder-class.new(
                                    :$body-stream,
                                    :$left-over,
                                    :%header,
                                );
                                $body-decoder.decode($body-sink.Supply);

                                # Convert headers into HTTP_HEADERS
                                %env{ make-p6wapi-name(.key) } = .value for %header;
                                debug("ENV ", %env.perl);

                                # Get the existing chunks and put them into the
                                # body sink
                                debug("BODY ", $acc);
                                $body-sink.emit: $acc;

                                # Emit the environment, its processing can begin
                                # while we continue to receive the body.
                                emit %env;

                                # Is the body decoder done already?

                                # The request finished and the pipeline is ready
                                # with another request, so begin again.
                                if $left-over.status == Kept {
                                    new-request();
                                    next CHUNK_PROCESS;
                                }

                                # The request is still going. We need more chunks.
                                else {
                                    $expect = Body;
                                    last CHUNK_PROCESS;
                                }
                            }

                            # No body expected. Emit and move on.
                            else {
                                # Convert headers into HTTP_HEADERS
                                %env{ make-p6wapi-name(.key) } = .value for %header;

                                # Emit the completed environment.
                                $body-stream.done;
                                emit %env;

                                # Setup to read the next request.
                                new-request();
                            }

                        }

                        # Lines starting with whitespace are folded. Append the
                        # value to the previous header.
                        elsif $line.starts-with(' '|"\t") {
                            debug("CONT HEADER ", $line);

                            die X::HTTP::Supply::BadMessage.new(
                                reason => 'header folding encountered before any header was sent',
                            ) without $previous-header;

                            $previous-header.value ~= $line.trim-leading;
                        }

                        # We have received a new header. Save it.
                        else {
                            debug("START HEADER ", $line);

                            # Break the header line by the :
                            my ($name, $value) = $line.split(": ");

                            # Save the value into the environment
                            if %header{ $name.fc } :exists {

                                # Some headers can be provided more than once.
                                %header{ $name.fc } ~= ',' ~ $value;
                            }
                            else {

                                # First occurrence of a header.
                                %header{ $name.fc } = $value;
                            }

                            # Remember the header line for folded lines.
                            $previous-header = %header{ $name.fc } :p;
                        }
                    }

                    # Continue to decode the body.
                    when Body {

                        # Send the chunk to the body decoder to continue
                        # decoding.
                        debug("BODY ", $chunk);
                        $body-sink.emit: $chunk;

                        # The request finished and the pipeline is ready
                        # with another request, so begin again.
                        if $left-over.status == Kept {
                            new-request();
                            next CHUNK_PROCESS;
                        }

                        # The request is still going. We need more chunks.
                        else {
                            last CHUNK_PROCESS;
                        }
                    }
                }
            }
        }
    }
}
