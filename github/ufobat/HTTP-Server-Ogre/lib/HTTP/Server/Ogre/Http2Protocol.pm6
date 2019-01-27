use v6.c;

use HTTP::Server::Ogre::HTTP2::FrameParser;
use HTTP::Server::Ogre::HTTP2::RequestParser;
use HTTP::Server::Ogre::HTTP2::ResponseSerializer;
use HTTP::Server::Ogre::HTTP2::FrameSerializer;
use HTTP::Server::Ogre::HTTP2::ConnectionState;

class HTTP::Server::Ogre::Http2Protocol {

    # stateless
    has HTTP::Server::Ogre::HTTP2::FrameParser        $frame-parser        .= new();
    has HTTP::Server::Ogre::HTTP2::RequestParser      $request-parser      .= new();
    has HTTP::Server::Ogre::HTTP2::ResponseSerializer $response-serializer .= new();
    has HTTP::Server::Ogre::HTTP2::FrameSerializer    $frame-serializer    .= new();

    # per connection
    has HTTP::Server::Ogre::HTTP2::ConnectionState    $.connection-state   .= new();

    method read-from($conn --> Supply) {
        my $frame-supply = $frame-parser.parse-frames($conn.Supply(:bin), $.connection-state);
        my $env-supply   = $request-parser.parse-requests($frame-supply, $.connection-state);
        return $env-supply;
    }
    method write-to($conn, $response, :$stream-id) {

        my $frame-supply = $response-serializer.serialize-response($response, $stream-id);
        my $blob-supply  = $frame-serializer.serialize-frames($frame-supply, $.connection-state);

        whenever $blob-supply -> $blob {
            $conn.write($blob);
        }
    }
}
