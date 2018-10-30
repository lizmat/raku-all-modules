use v6;
use Test;

use HTTP::MultiPartParser;

sub parse($content) {
    my $error = Any;
    my $res = [];
    my Blob $body = Buf.new;
    my $parser = HTTP::MultiPartParser.new(
        boundary  => 'xxx'.encode('utf-8'),
        on_header => sub ($h) {
            $res.push($h, Nil);
        },
        on_body   => sub ($chunk, $final) {
            $body ~= $chunk;
            if $final {
                $res[*-1] = $body;

                $body = Buf.new;
            }
        },
        on_error  => sub ($err) { $error ~= "$err"  },
    );

    $parser.parse($content.encode('ascii'));
    $parser.finish;

    return $res, $error;
}

constant CRLF = "\x0D\x0A";
constant SP   = "\x20";
constant HT   = "\x09";

my @tests = (
    [ '',
      [ ], 'End of stream encountered while parsing preamble' ],
    [ '--xxx',
      [ ], 'End of stream encountered while parsing boundary' ],
    [ '--xxx--',
      [ ], 'End of stream encountered while parsing closing boundary' ],
    [ '--xxx----',
      [ ], 'Closing boundary does not terminate with CRLF' ],
    [ '--xxx__',
      [ ], 'Boundary does not terminate with CRLF or hyphens' ],
    [ "--xxx{CRLF}Foo",
      [ ], 'End of stream encountered while parsing part header' ],
    [ "--xxx{CRLF}{CRLF}{CRLF}",
      [ [[], Nil] ], 'End of stream encountered while parsing part body' ],
    [ "--xxx{CRLF}{CRLF}{CRLF}{CRLF}--xxx--{CRLF}xx",
      [ [[], Buf.new] ], 'Nonempty epilogue' ],
    [ "--xxx{CRLF}{SP}Foo{CRLF}{CRLF}",
      [ ], 'Continuation line seen before first header' ],
    [ "--xxx{CRLF}{HT}Foo{CRLF}{CRLF}",
      [ ], 'Continuation line seen before first header' ],
    [ "--xxx{CRLF}Foo{CRLF}{CRLF}",
      [ ], 'Malformed header line' ],
);

for @tests -> $test {
    my ($content, $exp_parts, $exp_error) = @$test;

    my ($got_parts, $got_error) = parse($content);

    my $name = $content.subst(/(<-[\x21..\x7E]>)/, -> $c { sprintf '\x%.2X', ord $c[0]}, :g);

    subtest {
        is-deeply($got_parts, $exp_parts, "parts ($name)");
        ok($got_error eqv $exp_error, "error ($name)")
            or say "got:{$got_error.perl} != expected:{$exp_error.perl}";
    }, $name;
}

done-testing;

