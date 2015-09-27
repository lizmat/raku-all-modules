use v6;

use HTTP::MultiPartParser;
use Test;

sub parse($content) {
    my $error = Any;
    my $res = [];
    my Blob $body = Buf.new;
    my $header;
    my $parser = HTTP::MultiPartParser.new(
        boundary  => 'xxx'.encode('utf-8'),
        on_header => sub ($h) {
            $header = $h;
        },
        on_body   => sub ($chunk, $final) {
            $body ~= $chunk;
            if $final {
                $res.push($header, $body);

                $body = Buf.new;
                undefine $header;
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
    [ "--xxx{CRLF}Foo: Foo{CRLF}Bar: Bar{CRLF}{CRLF}{CRLF}--xxx--{CRLF}",
      [ [ ['Foo: Foo', 'Bar: Bar'], Buf.new] ], Any ],
    [ "--xxx{CRLF}Foo: Foo{CRLF}{SP}Bar{CRLF}{CRLF}{CRLF}--xxx--{CRLF}",
      [ [ ['Foo: Foo Bar'], Buf.new] ], Any ],
    [ "--xxx{CRLF}Foo: {CRLF}{HT}Bar{CRLF}{HT}{CRLF}{HT}Baz{CRLF}{CRLF}{CRLF}--xxx--{CRLF}",
      [ [ ['Foo: Bar Baz'], Buf.new] ], Any ],
    [ "--xxx{CRLF}Foo: {CRLF}{SP}Bar{CRLF}{SP}{CRLF}{SP}Baz{CRLF}{CRLF}{CRLF}--xxx--{CRLF}",
      [ [ ['Foo: Bar Baz'], Buf.new] ], Any ],
);

for @tests -> $test {
    my ($content, $exp_parts, $exp_error) = @$test;

    my ($got_parts, $got_error) = parse($content);

    my $name = $content.subst(/(<-[\x21..\x7E]>)/, -> $c { sprintf '\x%.2X', ord $c[0]}, :g);

    subtest {
        is-deeply($got_parts, $exp_parts, "parts ($name)");
        ok($got_error eqv $exp_error, "error ($name)");
    }, $name;
}

done-testing;

