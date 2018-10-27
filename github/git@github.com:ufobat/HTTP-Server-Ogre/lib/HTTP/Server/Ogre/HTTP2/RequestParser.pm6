use v6.c;
use HTTP::Server::Ogre::HTTP2::Frame;

# HTTP/2 stream
enum State <header-init header-c data>;

class Stream {
    has Int      $.stream-id;
    has State    $.state is rw;
    has          %.env;
    has Bool     $.stream-end is rw;
    has Supplier $.body;
    has Buf      $.headers is rw;
}

class HTTP::Server::Ogre::HTTP2::RequestParser {
    use HTTP::HPACK;

    has $pseudo-headers = <:method :scheme :authority :path :status>;
    has $decoder        = HTTP::HPACK::Decoder.new;

    method parse-requests(Supply:D $in, $connection-state) {
        supply {
            my $curr-sid = 0;
            my %streams;
            my ($breakable, $break) = (True, $curr-sid);

            whenever $in {
                when Any {
                    # Logically, Headers and Continuation are a single frame
                    if !$breakable {
                        if $_ !~~ HTTP::Server::Ogre::HTTP2::Frame::Continuation
                        || $break != .stream-identifier {
                            die X::HTTP::Server::Ogre::HTTP2::Error.new(code => PROTOCOL_ERROR);
                        }
                    }
                    proceed;
                }
                when HTTP::Server::Ogre::HTTP2::Frame::Data {
                    my $stream = %streams{.stream-identifier};
                    self!check-data($stream, .stream-identifier, $curr-sid);
                    $stream.body.emit: .data;
                    $stream.body.done if .end-stream;
                }
                when HTTP::Server::Ogre::HTTP2::Frame::Headers {
                    unless %streams{.stream-identifier}:exists {
                        $curr-sid = .stream-identifier;
                        my $body  = Supplier::Preserving.new;
                        %streams{$curr-sid} = Stream.new(
                            stream-id  => $curr-sid,
                            state      => header-init,
                            env        => ('p6w.input' => $body.Supply),
                            stream-end => .end-stream,
                            body       => $body,
                            headers    => Buf.new,
                        );
                    }

                    if .end-headers {
                        my %env = %streams{.stream-identifier}.env;
                        self!set-headers(%env, .headers);
                        %env<ogre.stream-id> = .stream-identifier;
                        emit %env;
                        if .end-stream {
                            # Message is complete without body
                            %streams{.stream-identifier}.body.done;
                        } else {
                            %streams{.stream-identifier}.state = data;
                        }
                    } else {
                        # No meaning in lock if we're locked already
                        ($breakable, $break) = (False, .stream-identifier) if $breakable;
                        %streams{.stream-identifier}.headers ~= .headers;
                        %streams{.stream-identifier}.body.done if .end-stream;
                        %streams{.stream-identifier}.state = header-c;
                    }
                }
                when HTTP::Server::Ogre::HTTP2::Frame::Continuation {
                    if .stream-identifier > $curr-sid
                    || %streams{.stream-identifier}.state !~~ header-c {
                        die X::HTTP::Server::Ogre::HTTP2::Error.new(code => PROTOCOL_ERROR)
                    }
                    my %env = %streams{.stream-identifier}.env;

                    if .end-headers {
                        ($breakable, $break) = (True, 0);
                        my $headers = %streams{.stream-identifier}.headers ~ .headers;
                        my %env = %streams{.stream-identifier}.env;
                        self!set-headers(%env, $headers);
                        %env<ogre.stream-id> = .stream-identifier;
                        emit %env;

                        if %streams{.stream-identifier}.stream-end {
                            %streams{.stream-identifier}.body.done;
                        } else {
                            %streams{.stream-identifier}.state = data;
                        }
                    } else {
                        %streams{.stream-identifier}.headers ~= .headers;
                    }
                }
                when HTTP::Server::Ogre::HTTP2::Frame::Priority     { }
                when HTTP::Server::Ogre::HTTP2::Frame::RstStream    { }
                when HTTP::Server::Ogre::HTTP2::Frame::Settings     { $connection-state.settings.emit: $_; }
                when HTTP::Server::Ogre::HTTP2::Frame::Ping         { $connection-state.ping.emit: $_; }
                when HTTP::Server::Ogre::HTTP2::Frame::GoAway       { }
                when HTTP::Server::Ogre::HTTP2::Frame::WindowUpdate { }
            }
        }
    }

    method !set-headers(%env, $headers) {
        my @headers = $!decoder.decode-headers($headers);
        for @headers -> $header {
            given $header.name {
                when ':status' { %env<REQUEST_METHOD> = $header.value }
                when ':path'   { %env<REQUEST_URI>    = $header.value }
                when ':scheme' { }
                default {
                    my $name = 'HTTP_' ~ $_.subst('-', '_').uc;
                    %env{$name} =
                        %env{$name}:exists
                        ?? %env{$name} ~ ',' ~ $header.value
                        !! $header.value;
                }
            }
        }

        ## those are must not have a HTTP_ prefix
        if %env<HTTP_CONTENT_TYPE> :delete :v -> $content-type {
            %env<CONTENT_TYPE> = $content-type;
        }

        if %env<HTTP_CONTENT_LENGTH> :delete :v -> $content-length {
            %env<CONTENT_LENGTH> = $content-length;
        }

    }

    method !check-data($stream, $sid, $csid) {
        if  $sid > $csid
        ||  $stream.state !~~ data
        || !$stream.message.method
        || !$stream.message.target {
            die X::HTTP::Server::Ogre::HTTP2::Error.new(code => PROTOCOL_ERROR)
        }
    }


}
