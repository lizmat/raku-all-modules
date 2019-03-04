#!perl6

use v6;

use Test;
use Smack::Request;

my $input = 'a+b=d&one+two+three+four=1234';

my $tmpfile = $*TMPDIR
    ~ '/' ~ $*USER ~ '.' ~ ([~] ('A'..'Z').roll(8)) ~ '.' ~ $*PID;
$tmpfile.IO.spurt($input);

END { unlink $tmpfile.IO }

my %env =
    REQUEST_METHOD         => 'GET',
    SCRIPT_NAME            => 'falcon.psgi',
    PATH_INFO              => '/one/two',
    REQUEST_URI            => '/app/one/two',
    QUERY_STRING           => 'a+b=c&(*+Pascal+*)=%2F*%20C%20*%2F;foo',
    SERVER_NAME            => 'www.example.com',
    SERVER_PORT            => '80',
    SERVER_PROTOCOL        => 'HTTP/1.1',
    CONTENT_LENGTH         => $input.encode.bytes,
    CONTENT_TYPE           => 'application/x-www-form-urlencoded; charset=UTF-8',
    HTTP_X_FOO             => 'Bar',
    HTTP_REFERER           => '/two/one',
    HTTP_HOST              => 'www.example.com',
    'p6w.version'         => [ 1, 1 ],
    'p6w.url_scheme'      => 'http',
    'p6w.input'           => $tmpfile.IO.open(:r, :bin).Supply,
    'p6wx.input.buffered' => True,
    'p6w.errors'          => $*ERR,
    'p6w.multithread'     => False,
    'p6w.multiprocess'    => False,
    'p6w.run_once'        => True,
    'p6w.non_blocking'    => False,
    'p6w.streaming'       => False,
;

my $req = Smack::Request.new(%env);

is $req.protocol, 'HTTP/1.1', 'protocol is good';
is $req.method, 'GET', 'method is good';
is $req.port, 80, 'port is good';
is $req.request-uri, '/app/one/two', 'request-uri is good';
is $req.path-info, '/one/two', 'path-info is good';
is $req.path, '/one/two', 'path is good';
is $req.query-string, 'a+b=c&(*+Pascal+*)=%2F*%20C%20*%2F;foo', 'query-string is good';
is $req.script-name, 'falcon.psgi', 'script-name is good';
is $req.scheme, 'http', 'scheme is good';
is $req.secure, False, 'secure is good';
isa-ok $req.body, Supply, 'body is good';
isa-ok $req.input, Supply, 'input is good';

is $req.query-parameters{'a b'}, 'c', 'qs a b is good';
is $req.query-parameters{'(* Pascal *)'}, '/* C */', 'qs (* Pascal *) is good';

cmp-ok $req.query-parameters<foo>, '~~', Str, 'foo is good';
cmp-ok $req.query-parameters<foo>, '~~', True, 'foo is good';

is $req.query-parameters.elems, 3, 'only 3 params in qs';

is $req.raw-content, $input.encode('UTF-8'), 'raw-content is good';
is $req.content, $input, 'content is good';

is $req.Content-Length, $input.encode.bytes, 'Header Content-Length is good';
is $req.Content-Type.primary, 'application/x-www-form-urlencoded', 'Header Content-Type is good';
is $req.Content-Type.charset, 'UTF-8', 'Header Content-Type charset is good';
is $req.header('X-Foo'), 'Bar', 'Header X-Foo is good';
is $req.headers.Referer, '/two/one', 'Header Referer is good';
is $req.headers.Host, 'www.example.com', 'Header Host is good';

is $req.body-parameters{'a b'}, 'd', 'body a+b is good';
is $req.body-parameters{'one two three four'}, '1234', 'body one two three four is good';
is $req.body-parameters.elems, 2, 'only 2 params in body';

is $req.parameters{'a b'}, 'd', 'parameters a b is good';
is $req.parameters{'(* Pascal *)'}, '/* C */', 'parameters (* Pascal *) is good';
cmp-ok $req.parameters<foo>, '~~', Str, 'parameters foo is good';
cmp-ok $req.parameters<foo>, '~~', True, 'parameters foo is good';
is $req.parameters{'one two three four'}, '1234', 'parameters one two three four is good';
is $req.parameters('a b'), [ 'c', 'd' ], 'parameters a b actually contains both values';
is $req.parameters.elems, 4, 'only 4 params in parameters';

is $req.param{'a b'}, 'd', 'param a b is good';
is $req.param{'(* Pascal *)'}, '/* C */', 'param (* Pascal *) is good';
cmp-ok $req.param<foo>, '~~', Str, 'param foo is good';
cmp-ok $req.param<foo>, '~~', True, 'param foo is good';
is $req.param{'one two three four'}, '1234', 'param one two three four is good';
is $req.param('a b'), [ 'c', 'd' ], 'param a b actually contains both values';
is $req.param.elems, 4, 'only 4 params in param';

done-testing;
