use v6;

unit class HTTP::Server::Smack;

use URI::Encode;
use DateTime::Format::RFC2822;
use HTTP::Headers;
use HTTP::Status;

use HTTP::Server::Smack::HTTP1x;
use HTTP::Server::Smack::HTTP2;
use HTTP::Server::Smack::Util;
use HTTP::Server::Smack::WebSocket;

has Str $.host;
has Int $.port;

has Bool $.debug = False;

has $!listener;
has @.protocol-handlers =
    HTTP::Server::Smack::HTTP1x.new,
    HTTP::Server::Smack::HTTP2.new,
    ;

method run(&app) {
    self.setup-listener;
    self.accept-loop(&app);
}

method setup-listener {
    $!listener = IO::Socket::INET.new(
        localhost => $!host,
        localport => $!port,
        listen    => True,
    );
}

method accept-loop(&app) {
    while my $conn = $!listener.accept {
        my $errors = Supply.new;
        $errors.tap: -> $s { $*ERR.say($s) };

        my %root-env =
            SERVER_PORT          => $!port,
            SERVER_HOST          => $!host,
            SCRIPT_NAME          => '',
            REMOTE_ADDR          => $conn.local_address,
            'p6sgi.version'      => Version.new('0.5.Draft'),
            'p6sgi.errors'       => $errors,
            'p6sgi.run-once'     => False,
            'p6sgi.multithread'  => False,
            'p6sgi.multiprocess' => False,
            'p6sgi.encoding'     => 'UTF-8',
            ;

        my Buf $buf .= new;
        my Bool $ran = @.protocol-handlers.first({
            .run(:$conn, :env(%root-env), :&app, :$buf)
        });
    }

    LEAVE {
        $!listener.close;
        $!listener = IO::Socket::INET;
    }
}

# method !temp-file {
#     ($*TMPDIR ~ '/' ~ $*USER ~ '.' ~ ([~] ('A' .. 'Z').roll(8)) ~ '.' ~ $*PID).IO
# }
