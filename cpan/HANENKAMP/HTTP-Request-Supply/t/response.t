use v6;

use Test;
use HTTP::Supply::Response;

use lib 't/lib';
use HTTP::Supply::Response::Test;

my @tests =
   %(
        source   => 'http-response-basic.txt',
        expected => ([
            200,
            [
                '::server-protocol'      => 'HTTP/1.1',
                '::server-reason-phrase' => 'OK',
                content-type             => 'text/plain',
                content-length           => '14',
            ],
            "Hello World!\r\n",
        ],),
    ),
   %(
        source   => 'http-response-no-length.txt',
        expected => ([
            200,
            [
                '::server-protocol'      => 'HTTP/1.1',
                '::server-reason-phrase' => 'OK',
                content-type             => 'text/plain',
            ],
            "Hello World!\r\n",
        ],),
    ),
    %(
        source   => 'http-response-pipeline.txt',
        expected => ([
            200,
            [
                '::server-protocol'      => 'HTTP/1.1',
                '::server-reason-phrase' => 'OK',
                content-type             => 'application/json; charset=utf8',
                content-length           => '21',
            ],
            qq[\{"hello":"world"}\r\n\r\n],
        ], [
            200,
            [
                '::server-protocol'      => 'HTTP/1.1',
                '::server-reason-phrase' => 'Pretty Good',
                content-type             => 'text/plain; charset=utf8',
                transfer-encoding        => 'chunked',
                trailer                  => 'Magic',
            ],
            "aababcabcd",
            [
                'magic' => 'off',
            ],
        ], [
            200,
            [
                '::server-protocol'      => 'HTTP/1.1',
                '::server-reason-phrase' => 'Freaking Amazing',
                content-type             => 'text/html; charset=latin-1',
                content-length           => '27',
            ],
            "<em>Neat-o Mosquito!</em>\r\n",
        ]),
    ),
;

my $tester = HTTP::Supply::Response::Test.new(:@tests);

$tester.run-tests(:reader<file>);
$tester.run-tests(:reader<socket>);

done-testing;
