use v6;

use Test;
use JSON::Fast;

use HTTP::MultiPartParser;

my $base = "t/data/";

for 1..12 {
    my $number = sprintf("%03d", $_);

    my $test = from-json("$base/{$number}-test.json".IO.slurp);
    my $exp  = from-json("$base/{$number}-exp.json".IO.slurp);
    my $path = "$base/{$number}-content.dat".IO;

    subtest {
        my %part;
        my Blob $body = Blob.new;
        my $headers;
        my @got;
        my $finished=0;

        my $parser = HTTP::MultiPartParser.new(
            boundary  => $test<boundary>.encode('ascii'),
            on_header => sub ($h) {
                $headers = $h;
            },
            on_error => sub ($err) {
                die $err;
            },
            on_body => sub ($chunk, $final) {
                $body ~= $chunk;
                if $final {
                    $finished++;
                    my $part = {
                        body   => $body.decode('ascii'),
                        header => $headers,
                    };
                    @got.push($part);

                    $headers = Nil;
                    $body = Blob.new;
                }
            },
        );

        my $fh = open($path, :bin);
        loop {
            my $buf = $fh.read(1024, :bin);
            if $buf.bytes == 0 {
                last;
            }
            $parser.parse($buf);
        }
        $parser.finish;
        is @got.elems, $exp.elems;
        is(@got, $exp, "{$number}-content.dat");
        for 0..@got.elems -> $i {
            is-deeply @got[$i], $exp[$i], "elem: $i";
        }

        # note "got: {@got.elems}, expected:{$exp.elems} $finished";
    }, $path;
}


done-testing;
