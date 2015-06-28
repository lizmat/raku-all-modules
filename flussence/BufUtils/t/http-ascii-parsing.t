#!/usr/bin/env perl6
use BufUtils;
use Test;
plan 3;

#| Just for convenience's sake
sub ASCII(Str $_) returns Blob is pure { .encode('ASCII') }

my Str $post-data = 'var1=val1&var2=foobar';
#| A fake HTTP request for test input
my Str $data = qq:to{EOF}.subst("\n", "\r\n", :g) ~ $post-data;
    POST /foobar HTTP/1.1
    Host: example.com
    Content-Encoding: x-www-formencoded
    Content-Length: {$post-data.chars}

    EOF
my Blob $raw-data = ASCII($data);

constant \CRLF = "\r\n";
constant \ASCII-CRLF = ASCII(CRLF);

subtest { plan 1;
    is (ASCII-CRLF x 2).elems, 4,
        "{CRLF.perl} repeated twice is 4 bytes";
}, 'infix:<x>';


subtest { plan 5;

    my $eol1 = $data.index(CRLF);
    is index($raw-data, ASCII-CRLF), $eol1,
        "First end of line at offset $eol1";

    my $eol2 = $data.index(CRLF, $eol1);
    is index($raw-data, ASCII-CRLF, $eol1), $eol2,
        "Second end of line at offset $eol2";

    my $eoh = $data.index(CRLF x 2);
    is index($raw-data, ASCII-CRLF x 2), $eoh,
        "End of headers at offset $eoh";

    my $content = $data.split("\r\n\r\n", 2)[1];
    is $raw-data.subbuf($eoh + (ASCII-CRLF x 2)).decode('ASCII'), $content,
        "Content length is {$content.chars}";

    subtest { plan 6;
        nok index($raw-data, ASCII("\n\n"));
        nok index($raw-data, (ASCII-CRLF x $raw-data.elems));
        is index($raw-data, $raw-data), 0;
        is index($raw-data, $raw-data ~ ASCII('x')), Int;
        is index($raw-data, $raw-data.subbuf(1)), 1;
        is index($raw-data.subbuf(1), $raw-data), Int;
    }, 'fail paths and edge cases';
}, 'index()';


subtest { plan 2;
    is starts-with($raw-data, ASCII('GET /' | 'POST /')),
        Bool::True,
        q{Let's try mixing in some crazy junction stuff};

    my $host-header    = ASCII-CRLF ~ ASCII('Host: ');
    my $expected-hosts = ASCII(any(«foo. bar. ''» X~ 'example.com'));
    my $start = index($raw-data, $host-header);
    my $end   = index($raw-data, ASCII-CRLF, $start + ASCII-CRLF);

    is ends-with($raw-data.subbuf($start, $end - $start), $expected-hosts),
        Bool::True,
        q{And throw some ad-hoc binary parsing in on top of that};
}, 'starts-with(), ends-with()';
