use v6;

unit class HTTP::Supply::Response;

use HTTP::Supply;
use HTTP::Supply::Body;
use HTTP::Supply::Tools;

=begin pod

=NAME HTTP::Supply::Response - A modern HTTP/1.x response parser

=begin SYNOPSIS

    use HTTP::Supply::Response;

    my @pipeline = <
        /stuff
        /things
        /more-stuff
    >;

    sub fetch-next($conn) {
        my $uri = @pipeline.pop;
        with $uri {
            $conn.print("GET $uri HTTP/1.1\r\n");
            True;
        }
        else {
            $conn.close;
            False;
        }
    }

    react {
        whenever IO::Socket::Async.connect('localhost', 8080) -> $conn {
            fetch-next($conn);

            whenever HTTP::Supply::Response.parse-http($conn) -> $res {
                if $res[0] == 200 {
                    $res[2].reduce({ $^a ~ $^b }).decode('utf8').say;
                    done unless fetch-next($conn);
                }
                else {
                    die "Bad things happened: $res[0] {$res[1].grep(*.key eq '::server-reason-phrase'}";
                }
            }
        }
    }

=end SYNOPSIS

=begin DESCRIPTION

B<EXPERIMENTAL:> The API for this module is experimental and may change.

This class provides C<method parse-http> that parses incoming data from a
L<Supply> that is expected to emit raw binary data. It returns a Supply that
emits a response for each HTTP/1.x response frame parsed from the incoming data.
Each frame is returned as it arrives asynchronously.


This Supply emits an extended L<P6WAPI> response for use by the caller. If a
problem is detected in the stream, it will quit with an exception.

=end DESCRIPTION

=head1 METHODS

=ehad2 method parse-http

    method parse-http(HTTP::Supply::Response: Supply:D() $conn, Bool :$debug = False) returns Supply:D

THe given L<Supply>, C<$conn>, must emit a stream of bytes. Any other data will
result in undefined behavior. The parser assumes that only binary bytes will be
sent and makes no particular effort to verify that assumption.

The returns Supply will emit a response whenever a response frame can be parsed
from the input supply. The response will be emitted as soon as the header has
been read. The response includes a supply containing the body, which will be
emitted as more binary bytes as it arrives.

The response is emitted as an extended L<P6WAPI> response. It will be a
L<Positional> object with three elements:

=over

=item The first element will be the numeric status code from the status line.

=item The second element will be an L<Array> of L<Pair>s for the headers.

=item The thirs will be a sane Supply that will emit the bytes in the message body.

=back

The headers are provided in the order they are received with any repeats
included as-is. The header names will be set in each key using folded case
(which means lower case as the headers will be decoded using ISO-8859-1).

The header will also include two special fields:

=over

=item The C<::server-protocol> key will be set to the server protocol set in the
status line of the response. This will be either "HTTP/1.0" or "HTTP/1.1".

=item The C<::server-reason-phrase> key will be set to the reason phrase set by
the server in the status line of the response after the numeric code. This will
usually be something like "OK" when the status code is 200, "Not Found" when the
status code is 404, etc.

=back

The parser aims at being very liberal in what it accepts. It is possible for the
headers to contain non-sensical values. So long as the format is syntactically
readable and the frames appear to make sense, the parser will continue emitting
responses as they arrive. Ensuring proper HTTP semantics and connection handling
is left up to the caller.

=head1 DIAGNOSTICS

In certain cases, the parser may caues the Supply to quit with an error.

=head2 X::HTTP::Supply::UnsupportedProtocol

This exception will be thrown if the message reports a server protocol that looks like HTTP, but is not HTTP/1.0 or HTTP/1.1.

=head2 X::HTTP::Supply::BadMessage

If there is any syntax error, this message may be thrown. This may also be thrown on certain obvious semantic errors. Even these, however, are primarily oriented toward sanity checking the syntax of each response frame.

=end pod

method !make-header(@header) {
    my %header;
    for @header {
        if %header{ .key } :exists {
            %header{ .key } ~= ',' ~ .value;
        }
        else {
            %header{ .key } = .value;
        }
    }
    %header;
}

method parse-http(Supply:D() $conn, Bool :$debug = False --> Supply:D) {
    sub debug(*@msg) {
        note "# Response [$*PID] [{now.Rat.fmt("%.5f")}] (#$*THREAD.id()) ", |@msg if $debug
    }

    supply {
        my enum <StatusLine Header Body Close>;
        my $expect;
        my @res;
        my buf8 $acc;
        my Supplier $body-sink;
        my Promise $left-over;

        my sub new-response() {
            $expect = StatusLine;
            $acc = buf8.new;
            $acc ~= .result with $left-over;
            $left-over = Nil;
            $body-sink = Nil;
            @res := [ Nil, [], Nil ];
        }

        new-response();

        whenever $conn -> $chunk {
            LAST {
                debug("server closed the connection");

                if $expect ~~ Body {
                    $body-sink.done;
                }

                done;
            }

            # When expected a header add the chunk to the accumulation buffer.
            debug("RECV ", $chunk.perl);
            $acc ~= $chunk if $expect != Body;

            # Otherwise, the chunk will be handled directly below.
            CHUNK_PROCESS: loop {
                given $expect {

                    # Ready to receive the status line
                    when StatusLine {
                        # Decode the response line
                        my $line = crlf-line($acc);

                        # We don't have a complete line yet
                        last CHUNK_PROCESS without $line;
                        debug("STATLINE [$line]");

                        # Break the line up into parts
                        my ($http-version, $status-code, $status-message) = $line.split(' ', 3);

                        # Make sure the status code is numeric and sane-ish
                        if $status-code !~~ /^ <[1..5]> <[0..9]> <[0..9]> $/ {
                            die X::HTTP::Supply::BadMessage.new(
                                reason => 'status code is not numeric or not in the 100-599 range',
                            );
                        }

                        # We got what looks like a status-line, let's check it
                        # just a bit.
                        if ($http-version//'') eq none('HTTP/1.0', 'HTTP/1.1') {
                            # Looks like HTTP/*?
                            if $http-version.defined && $http-version ~~ /^ 'HTTP/' <[0..9]>+ / {
                                die X::HTTP::Supply::UnsupportedProtocol.new.throw;
                            }

                            # It is other.
                            else {
                                die X::HTTP::Supply::BadMessage.new(
                                    reason => 'status line contains garbage',
                                );
                            }
                        }

                        # Save the status line
                        @res[0] = $status-code.Int;
                        @res[1].push: '::server-protocol' => $http-version;
                        @res[1].push: '::server-reason-phrase' => $status-message;

                        $expect = Header;
                    }

                    # Ready to receive a header line
                    when Header {
                        # Decode the next line from the header
                        my $line = crlf-line($acc);

                        # We don't have a complete line yet
                        last CHUNK_PROCESS without $line;

                        # Empty line signals the end of the header
                        my %header := self!make-header(@res[1]);
                        if $line eq '' {
                            debug("HEADER END");

                            # Setup the body decoder itself
                            debug("STATUS ", @res[0]);
                            debug("HEAD ", @res[1].perl);
                            my $body-decoder-class = do
                                if %header<transfer-encoding>.defined
                                && %header<transfer-encoding> eq 'chunked' {
                                    HTTP::Supply::Body::ChunkedEncoding
                                }
                                elsif %header<content-length>.defined {
                                    HTTP::Supply::Body::ContentLength
                                }
                                else {
                                    HTTP::Supply::Body::UntilDone
                                }

                            debug("DECODER CLASS ", $body-decoder-class.^name);

                            # Setup the stream we will send to the P6WAPI response
                            my $body-stream = Supplier::Preserving.new;
                            @res[2] = $body-stream.Supply;

                            # If we expect a body to decode, setup the decoder
                            if $body-decoder-class ~~ HTTP::Supply::Body {
                                debug("DECODE BODY");

                                # Setup the stream we will send to the body decoderk
                                $body-sink = Supplier::Preserving.new;

                                # Setup the promise the body decoder can use to
                                # drop the left-overs
                                $left-over = Promise.new;

                                # Construst the decoder and tap the body-sink
                                my $body-decoder = $body-decoder-class.new(
                                    :$body-stream, :$left-over, :%header,
                                );
                                $body-decoder.decode($body-sink.Supply);

                                # Get the existing chunks and put them into the
                                # body sink
                                debug("BODY ", $acc);
                                $body-sink.emit: $acc;

                                # Emit the resposne, its processing can begin
                                # while we continue to receive the body.
                                debug("EMIT ", @res.perl);
                                emit @res;

                                # Is the body decoder done already?

                                # The request finished and the pipeline is ready
                                # with another response, so begin again.
                                if $left-over.status == Kept {
                                    new-response();
                                    next CHUNK_PROCESS;
                                }

                                # The response is still going. We need more
                                # chunks.
                                else {
                                    $expect = Body;
                                    last CHUNK_PROCESS;
                                }
                            }

                            # No body expected. Emit and move on.
                            else {
                                # Emit the completed response
                                $body-stream.done;
                                emit @res;

                                # Setup to read the next response.
                                new-response();
                            }
                        }

                        # Lines starting with whitespace are folded. Append the
                        # value to the previous header.
                        elsif $line.starts-with(' '|"\t") {
                            debug("CONT HEADER ", $line);

                            # Folding encountered too early
                            die X::HTTP::Supply::BadMessage.new(
                                reason => 'header folding encountered before any header was sent',
                            ) if @res[1].elems == 0;

                            @res[1][*-1].value ~= $line.trim-leading;
                        }

                        # We have received a new header. Save it.
                        else {
                            debug("START HEADER ", $line);

                            # Break the header line by the :
                            my ($name, $value) = $line.split(": ");

                            # Setup the name for going into the response
                            $name .= fc;

                            # Save the value into the response
                            @res[1].push: $name => $value;
                        }
                    }

                    # Continue to decode the body.
                    when Body {

                        # Send the chunk to the body decoder to continue
                        # decoding.
                        debug("BODY ", $chunk);
                        $body-sink.emit: $chunk;

                        # The response finished and the pipeline is ready with
                        # another response, so begin again.
                        if $left-over.status == Kept {
                            new-response();
                            next CHUNK_PROCESS;
                        }

                        # The response is still going. We need more chunks.
                        else {
                            last CHUNK_PROCESS;
                        }
                    }
                }
            }
        }
    }
}
