use v6;

unit class HTTP::Server::Smack;

use URI::Encode;
use DateTime::Format::RFC2822;
use HTTP::Headers;
use HTTP::Status;

has Str $.host;
has Int $.port;

has Bool $.debug = False;

has $!listener;

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

        my Promise $header-done-promise .= new;
        my $header-done = $header-done-promise.vow;

        my Promise $body-done-promise .= new;
        my $body-done = $body-done-promise.vow;

        my Promise $ready-promise .= new;
        my $ready = $ready-promise.vow;

        my %env =
            SERVER_PORT             => $!port,
            SERVER_NAME             => $!host,
            SCRIPT_NAME             => '',
            REMOTE_ADDR             => $conn.local_address,
            'p6sgi.version'         => Version.new('0.5.Draft'),
            'p6sgi.errors'          => Supply.new.tap: -> $s { $*ERR.say($s) },
            'p6sgi.url-scheme'      => 'http',
            'p6sgi.run-once'        => False,
            'p6sgi.multithread'     => False,
            'p6sgi.multiprocess'    => False,
            'p6sgi.encoding'        => 'UTF-8',
            'p6sgi.ready'           => $ready-promise,
            'p6sgix.header.done'    => $header-done-promise,
            'p6sgix.body.done'      => $body-done-promise,
            ;

        #$*SCHEDULER.cue: {
            self.handle-connection(&app, :%env, :$conn, :$ready, :$header-done, :$body-done);
        #};
    }

    LEAVE {
        $!listener.close;
        $!listener = IO::Socket::INET;
    }
}

constant CR = 0x0d;
constant LF = 0x0a;

method !temp-file {
    ($*TMPDIR ~ '/' ~ $*USER ~ '.' ~ ([~] ('A' .. 'Z').roll(8)) ~ '.' ~ $*PID).IO
}

method handle-connection(&app, :%env, :$conn, :$header-done, :$body-done, :$ready) {
    my $res = [ 400, [ 'Content-Type' => 'text/plain' ], [ 'Bad Request' ] ];

    note "[debug] Received connection..." if $!debug;

    my $header-end;
    my $checked-through = 3;
    my $whole-buf = Buf.new;

    while my $buf = $conn.recv(:bin) {
        $whole-buf = $whole-buf ~ $buf;

        CRLF: for $checked-through .. $whole-buf.end {
            next CRLF unless $whole-buf[$_-3] == CR;
            next CRLF unless $whole-buf[$_-2] == LF;
            next CRLF unless $whole-buf[$_-1] == CR;
            next CRLF unless $whole-buf[$_-0] == LF;

            $header-end = $_;
            last CRLF;
        }

        if $header-end {
            last;
        }
        else {
            $checked-through = $whole-buf.end - 2;
        }
    }

    # Header never ended!
    unless $header-end {
        note '[error] Header section does not end correctly';
        self.handle-response($res, :$conn);
        return;
    }

    my $header = $buf.subbuf(0, $header-end).decode('ISO-8859-1');
    $whole-buf = $buf.subbuf($header-end + 1);

    my @unfolded-headers = $header.split("\x0d\x0a");
    my $request-line = @unfolded-headers.shift;

    my @headers;
    for @unfolded-headers {
        when /^ \s/ {
            if @headers {
                @headers[*-1] ~= .subst(/^ \s+ /, ' ');
            }

            # Bad Request, malformed headers
            else {
                note '[error] Malformed headers in request';
                self.handle-response($res, :$conn);
                return;
            }
        }

        default {
            @headers.push: $_;
        }
    }

    my $headers = HTTP::Headers.new;
    for @headers {
        my ($name, $value) = .split(/\s*:\s*/, 2);
        $headers.header($name, :quiet) = $value;
    }

    my $charset = $headers.Content-Type.charset // 'ISO-8859-1';
    my $length  = $headers.Content-Length.Int;

    # Continue consuming the body as soon as the app taps it
    %env<p6sgi.input> = Supply.on-demand(-> $in {
        my $remaining = $length - $whole-buf.bytes;
        $in.emit($whole-buf) if $whole-buf.bytes > 0;
        while my $buf = $conn.recv($remaining, :bin) {
            $remaining -= $buf.bytes;
            $in.emit($buf);
            last unless $remaining > 0;
        }
        $in.close;
    });

    my ($method, $uri, $proto) = $request-line.split(" ", 3);

    %env<REQUEST_METHOD>  = $method;
    %env<REQUEST_URI>     = $uri;
    %env<SERVER_PROTOCOL> = $proto;

    my ($path, $query-string) = $uri.split('?', 2);
    %env<PATH_INFO>       = uri_decode($path);
    %env<QUERY_STRING>    = $query-string;

    %env<CONTENT_LENGTH>  = $length;
    %env<CONTENT_TYPE>    = ~$headers.Content-Type;

    for $headers.list -> $header {
        my $env-name = "HTTP_" ~ $header.name.uc.trans("-" => "_");
        %env{$header} = $header.value;
    }

    $res = app(%env);

    # We stop here until the response is done before handling another request
    await self.handle-response($res, :$conn, :$body-done, :$header-done, :$ready);
}

method send-header($status, @headers, $conn) returns Str:D {
    my $status-msg = get_http_status_msg($status);

    # Header SHOULD be ASCII or ISO-8859-1, in theory, right?
    $conn.write("HTTP/1.0 $status $status-msg\x0d\x0a".encode('ISO-8859-1'));
    $conn.write("{.key}: {.value}\x0d\x0a".encode('ISO-8859-1')) for @headers;
    $conn.write("\x0d\x0a".encode('ISO-8859-1'));

    # Detect encoding
    my $ct = @headers.first(*.key.lc eq 'content-type');
    my $charset = $ct.value.comb(/<-[;]>/)».trim.first(*.starts-with("charset="));
    $charset.=substr(8) if $charset;
    $charset //= 'UTF-8';
}

method handle-response(Promise() $promise, :$conn, :$body-done, :$header-done, :$ready) {
    $promise.then({
        my (Int() $status, @headers, Supply() $body) := $promise.result;
        self.handle-inner($status, @headers, $body, $conn, :$body-done, :$header-done, :$ready);

        # consume and discard the bytes in the input stream, just in case the app
        # didn't read from it.
        %env<p6sgi.input>.tap: -> $ { };
    });
}

method handle-inner(Int $status, @headers, Supply $body, $conn, :$header-done, :$body-done, :$ready) {
    my $charset = self.send-header($status, @headers, $conn);
    $header-done andthen $header-done.keep;

    $body.tap(
        -> $v {
            my Blob $buf = do given ($v) {
                when Cool { $v.Str.encode($charset) }
                when Blob { $v }
                default {
                    warn "Application emitted unknown message.";
                    Nil;
                }
            }
            $conn.write($buf) if $buf;
        },
        done => { $conn.close; $body-done.keep(Any) },
        quit => {
            my $x = $_;
            $conn.close;
            CATCH {
                # this is stupid, IO::Socket needs better exceptions
                when "Not connected!" {
                    # ignore it
                }
            }
            $body-done andthen $body-done.break($x);
        },
    );
    $ready andthen $ready.keep;

    # stop here until done so the connection doesn't close
    $body.wait;
}
