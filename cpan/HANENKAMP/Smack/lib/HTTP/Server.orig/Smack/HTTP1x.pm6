use v6;

unit class HTTP::Server::Smack::HTTP1x does HTTP::Server::Smack::Protocol;

use HTTP::Server::Smack::HTTP2;

has $.method;
has $.uri;
has $.protocol;

my constant $CRLF = "\x0a\0d";

method run(:$conn!, :%env! is copy, :&app!, :$buf! is rw) {
    self.handle-request(:$conn, :%env, :&app, :$buf);

    # TODO Here we need to implement HTTP/1.1 connection persistence by running this more than once
    $conn.close;
}

method handle-request(:$conn!, :%env! is copy, :&app!, :$buf! is rw) {

    # internal environment
    my %int;

    my Promise $header-done-promise .= new;
    %int<header-done> = $header-done-promise.vow;

    my Promise $body-done-promise .= new;
    %int<body-done> = $body-done-promise.vow;

    my Promise $ready-promise .= new;
    %int<ready> = $ready-promise.vow;

    %env = |%env,
        'p6sgi.protocol'        => 'HTTP/1.0', # EXPERIMENTAL
        'p6sgi.url-scheme'      => 'http',
        'p6sgi.ready'           => $ready-promise,
        'p6sgix.header.done'    => $header-done-promise,
        'p6sgix.body.done'      => $body-done-promise,
        ;

    self.read-request(:$conn, :%env, :&app, :%int, :$buf);
}

method error-response($error, :$conn!, :%env!) {
    note "[error] $error";
    my $err = $error.encode('UTF-8');

    my @response = 400,
        [
            Content-Type   => 'text/plain; charset=utf-8',
            Content-Length => $err.bytes,
        ],
        [ $err ],
    ;

    my $res = Promise.new(result => @response);

    await self.handle-response(:$conn, :%env, :$res);
}

method read-request(:$conn!, :%env!, :&app!, :%int!, :buf($start-buf)! is rw) {
    my $header-end = parse-http-headers($conn, :$start-buf);
    my $header = $start-buf.subbuf(0, $header-end).decode('ISO-8859-1');
    unless $header ~~ rx(^^ \S+ " " \S+ " " \S+ "HTTP/1." <[ 0 1 ]> $CRLF) {
        return False;
    }

    my $buf = $start-buf.subbuf($header-end + 1);

    my @unfolded-headers = $header.split(CRLF);
    my $request-line = @unfolded-headers.shift;

    my @headers;
    for @unfolded-headers {
        when /^ \s/ {
            if @headers {
                @headers[*-1] ~= .subst(/^ \s+ /, ' ');
            }

            # Bad Request, malformed headers
            else {
                self.error-response('Malformed headers in request', :$conn, :%env);
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

    my ($method, $uri, $proto) = $request-line.split(" ", 3);

    # Continue consuming the body as soon as the app taps it
    if $headers.Transfer-Encoding && $headers.Transfer-Encoding ne 'identity' {
        # TODO Implement Transfer-Encoding: chunked
        ...
    }
    elsif $length {
        %env<p6sgi.input> = on -> $in {
            my $remaining = $length - $buf.bytes;
            $in.emit($buf) if $buf.bytes > 0;
            if $remaining > 0 {
                while my $buf = $conn.recv($remaining, :bin) {
                    $remaining -= $buf.bytes;
                    $in.emit($buf);
                    last unless $remaining > 0;
                }
            }
            $in.close;

            ()
        };
    }
    elsif $headers.Content-Type && $headers.Content-Type eq 'multipart/byteranges' {
        # TODO implement multipart/byteranges
        ...
    }
    else {
        # This is an error. Requests must always specify their length in
        # HTTP/1.0 and HTTP/1.1.
        self.error-response('Missing content length in request', :$conn, :%env);
        return;
    }

    %env<REQUEST_METHOD>  = $method;
    %env<REQUEST_URI>     = $uri;
    %env<SERVER_PROTOCOL> = "HTTP/1.0"; # Only HTTP/1.0 is supported for now

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

    # We stop here until the response is done beofre handling another request
    await self.handle-response(:$res, :$conn, :%env, :%int);
}

method send-header(:$status, :@headers, :$conn) returns Str:D {
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

method handle-response(Promise() :$res, :$conn, :%env, :%int) {
    $promise.then({
        my (Int() $status, List() $headers, Supply() $body) := $promise.result;
        self.handle-inner(:$status, :$headers, :$body, :$conn, :%int);

        # consume and discard the bytes in the iput stream, just in case the app
        # didn't read from it.
        %env<p6sgi.input>.tap: -> $ { } if %env<p6sgi.input> ~~ Supply:D;
    });
}

method handle-inner(Int :$status, :@headers, Supply :$body, :$conn, :%int) {
    my $charset = self.send-header($status, @headers, $conn);
    %int<header-done> andthen %int<header-done>.keep(True);

    $body.tap:
        -> $v {
            my Blob $buf = do given $v {
                when Cool { .Str.encode($charset) }
                when Blob { $_ }
                default {
                    warn "Application emitted unknown message.";
                    Nil;
                }
            };
            $conn.write($buf) if $buf;
        },
        done => {
            $conn.close;
            %int<body-done> andthen %int<body-done>.keep(True);
        },
        quit => {
            my $x = $_;
            $conn.close;
            CATCH {
                # this is stupid, IO::Socket needs better exceptions
                when "Not connected!" {
                    # ignore it
                }
            }
            %int<body-done> andthen %int<body-done>.break($x);
        },
    ;
    %int<ready> andthen %int<ready>.keep(True);

    # stop here until done so the connection doesn't close
    $body.wait;
}
