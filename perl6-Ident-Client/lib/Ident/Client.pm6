use v6;

class Ident::Client {
    has $!socket;
    has $.host;

    my class ResponseParser::Actions {
        method TOP($/) {
            make $<payload>.ast;
        }

        method payload($/) {
            make $<answer>.ast // $<error>.ast;
        }

        method answer($/) {
            make ~$<username>;
        }

        method error($/) {
            make False;
        }
    }

    my grammar ResponseParser::Grammar {
        token TOP {
            <request> <sep> <payload> \n
        }

        token payload {
            <error> | <answer>
        }

        token error {
            ERROR <sep> NO\-USER
        }

        token answer {
            USERID <sep>  <type> <sep> <username>
        }

        token type {
            <[A..Z]>+
        }

        token username {
            <[a..zA..Z0..9\_\-]>+
        }

        token request {
            <port>','<port>
        }

        token sep {
            \h*':'\h*
        }

        token port {
            \d+
        }
    }

    submethod BUILD(:$!host)  {}

    method connect() {
        $!socket = IO::Socket::INET.new(:host($!host), :port(113));
    }

    method close() {
        $!socket.close:
    }

    submethod parse_response(Str $response) {
        my $match = ResponseParser::Grammar.parse($response, :actions(ResponseParser::Actions.new())).ast;
        return $match;
    }

    method query(Int $src-port, Int $dest-port) {
        $!socket.print("$src-port,$dest-port\n");
        my $resp = $!socket.recv;
        return self.parse_response($resp);
    }
}
