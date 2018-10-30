use HTTP::Server::Ogre::HTTP2::Frame;
use HTTP::HPACK;

class HTTP::Server::Ogre::HTTP2::ResponseSerializer {

    sub emit-data($flags, $stream-identifier, $data) {
        emit HTTP::Server::Ogre::HTTP2::Frame::Data.new(
            :$flags, :$stream-identifier, :$data
        );
    }

    method serialize-response(List $result, $stream-id) {
        supply {
            my $encoder       = HTTP::HPACK::Encoder.new;
            my $status-header = HTTP::HPACK::Header.new(
                name  => ':status',
                value => $result[0].Str,
            );

            # headers
            my $content-length;
            my @headers = $result[1].map({
                $content-length = .value.Int if .key.fc eq 'Content-Length'.fc;
                HTTP::HPACK::Header.new(
                    name  => .key.lc,
                    value => .value.Str.lc
                )
            });
            @headers.unshift: $status-header;

            # body
            my $body = $result[2];

            my Bool $has-content;
            my Supply $body-supply;
            if $body ~~ List {
                $has-content = so $body.elems > 1 || $body.elems == 1 && $body[0];
                # Todo this could done without a supply
                $body-supply = Supply.from-list($body.flat);
            } elsif $body ~~ Supply {
                $has-content = True;
                $body-supply = $body;
            } else {
                # TODO
                die 'p6w protocol error';
            }

            emit HTTP::Server::Ogre::HTTP2::Frame::Headers.new(
                flags             => $has-content ?? 4 !! 5,
                stream-identifier => $stream-id,
                headers           => $encoder.encode-headers(@headers)
            );


            if $has-content {
                my $chunk-cnt = 0;
                whenever $body-supply -> $chunk {
                    $chunk-cnt += $chunk.elems;

                    my Blob $data;
                    if $chunk ~~ IO::Path {
                        $data = $chunk.slurp(:bin);
                    } elsif $chunk ~~ Buf {
                        $data = $chunk;
                    } else {
                        $data = $chunk.Str.encode;
                    }

                    if defined $content-length {
                        die 'Want to send more then specified in Content-Length' if $content-length < $chunk-cnt;
                        my $flag = $content-length == $chunk-cnt ?? 1 !! 0;
                        emit-data($flag, $stream-id, $data);
                        LAST {
                            if $content-length > $chunk-cnt {
                                warn 'Want to send less then specified in Content-Length';
                                emit-data(1, $stream-id, Blob.new);
                            }
                        }
                    } else {
                        emit-data(0, $stream-id, $data);
                        LAST {
                            emit-data(1, $stream-id, Blob.new);
                        }
                    }
                }
            }
        }
    }
}
