use v6;

unit class Smack::Client::Message;

use HTTP::Headers;

has Str $.protocol is rw = 'HTTP/1.1';

has HTTP::Headers $.headers is rw handles <
    Content-Type Content-Length header
> .= new(:quiet);

has Supply $.body is rw;
has Bool $!tweaked-body = False;
has Str $.enc is rw = 'iso-8859-1';

method body(Smack::Client::Message:D: --> Supply) is rw {
    return-rw Proxy.new(
        FETCH => sub ($)       { $!body },
        STORE => sub ($, $new) { $!tweaked-body--; $!body = $new },
    );
}

method encoding(Smack::Client::Message:D: --> Str:D) {
    $.headers.Content-Type.charset // $.enc // 'iso-8859-1';
}

has Str $!_content;

#| Grab the content all-or-nothing style.
method content(Smack::Client::Message:D: --> Str:D) {
    $!_content //= (await $.body.map(-> $chunk {
        given $chunk {
            when Blob { .decode($.encoding) }
            default   { ~$chunk }
        }
    }).reduce(&infix:<~>)) // '';
}

#| Provide the body as a stream of bytes.
method stream(Smack::Client::Message:D: --> Supply:D) {
    # If the body has already been slurped up into content
    if $!_content {
        supply {
            emit $.content.encode($.encoding);
        }
    }

    # Otherwise, we assume $.body is ready to be slurped up BUT might contain
    # non-bytes, so let's make a body that only emits bytes.
    else {
        $.body.map(-> $chunk {
            given $chunk {
                when Blob { $chunk }
                default { (~$chunk).encode($.encoding) }
            }
        });
    }
}

method !only-emit-blobs() {
    return if $!tweaked-body;

    $.body .= map({
        when Blob { $_ }
        default { .gist.encode($.encoding) }
    });

    $!tweaked-body++;
}

my sub make-chunked-body(Supply:D $body --> Supply:D) {
    supply {
        whenever $body -> $chunk is copy {
            emit $chunk.bytes.fmt("%x\r\n").encode('ascii');
            emit $chunk;
        }
    }
}

method send(Smack::Client::Message:D: $handle --> Nil) {
    my Supply $body-supply = supply { };
    with $.body {
        self!only-emit-blobs;
        $body-supply = do if $.headers.Transfer-Encoding eq 'chunked' {
            make-chunked-body($.body);
        }
        elsif !$.headers.Content-Length {
            my Int $content-length = 0;
            my $whole-body = await $.body.do({
                $content-length += .bytes
            }).reduce(&infix:<~>);
            $.headers.Content-Length = $content-length;
            supply { emit $whole-body }
        }
        else {
            $body-supply = $.body;
        }
    }

    $handle.write: $.headers.as-string(:eol("\r\n")).encode("iso-8859-1");
    $handle.write: "\r\n".encode("iso-8859-1");

    react {
        whenever $body-supply -> $chunk {
            $handle.write: $chunk;
        }
    }

    Nil;
}

multi method gist(Smack::Client::Message:D: --> Str:D) {
    return [~]
        $.headers.as-string(:eol("\r\n")),
        "\r\n",
        (do { "..." } with $.body),
        ;
}
