use v6;

use HTTP::Request::Supply;
use HTTP::Status;

class HTTP::Server::Ogre::Http1Protocol {

    constant CRLF = "\x0D\x0A";

    method read-from($conn) {
        return HTTP::Request::Supply.parse-http($conn.Supply(:bin));
    }

    method write-to($conn, $result) {
        my $http-status = $result[0];
        my @http-header = $result[1].flat;
        my $body-supply = $result[2];

        my $protocol = 'HTTP/1.1';
        my $http-msg = get_http_status_msg($http-status);

        $conn.print("$protocol $http-status $http-msg" ~ CRLF);
        for @http-header -> $header {
            $conn.print($header.key ~ ': ' ~ $header.value ~ CRLF);
        }
        $conn.print(CRLF);
        $body-supply.tap(
            -> $chunk {
                if $chunk ~~ Str {
                    $conn.print($chunk);
                } elsif $chunk ~~ Blob {
                    $conn.write($chunk);
                } else {
                    X::NYI.new(feature => 'handle chunk types differend to Blob and Str').thorw;
                }
            }
        );
        $body-supply.wait;
        $conn.close();
    }
};
