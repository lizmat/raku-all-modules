use v6;

use Test;
use Smack::Test;
use Smack::Client::Request::Common;

use Smack::Builder;
use Smack::Middleware::Static;
use Smack::MIME;

my $root = $*CWD;

Smack::MIME.add-type(".foo" => "text/x-fooo");

my &app = builder {
    enable Smack::Middleware::Static,
        condition => { .<PATH_INFO> ~~ s!^ '/share/' !! },
        root => 'share'.IO;
    enable Smack::Middleware::Static,
        condition => { .<PATH_INFO> ~~ s!^ '/more-share/' !! },
        root => 'share'.IO;
    enable Smack::Middleware::Static,
        condition => { .<PATH_INFO> ~~ s!^ '/share-pass/' !! },
        root => 'share'.IO, :pass-through;
    enable Smack::Middleware::Static,
        path => rx:i{ '.' [t | PL | txt] $ };
    enable Smack::Middleware::Static,
        path => rx:i{ '.foo' $ },
        content-type => { Smack::MIME.mime-type($^filename).substr(0, *-1) };

    -> %env { start { 200, [ Content-Type => 'text/plain', Content-Length => 5 ], 'hello' } }
}

test-p6wapi &app, -> $c {
    subtest {
        my $path = "t/test.txt".IO;
        my $res = await $c.request(GET "/$path");
        is $res.Content-Type.primary, 'text/plain', 'ok case';
        like $res.content, rx{foo};
        is $path.s, $res.content.chars;
        my $content = $path.slurp;
        is $content, $res.content;
    }, 'static files from . when ends with .txt';

    subtest {
        my $res = await $c.request(GET '/..%2f..%2f..%2fetc%2fpasswd.t');
        is $res.code, 403;
    }, 'forbidden when you use naughty ..';

    subtest {
        my $res = await $c.request(GET '/..%2fMakefile.PL');
        is $res.code, 403;
    }, 'forbidden when you use naughty ..';

    subtest {
        my $res = await $c.request(GET '/foo/not_found.t');
        is $res.code, 404, 'not found';
        is $res.content, 'Not Found';
    }, 'static files can be not found';

    subtest {
        my $res = await $c.request(GET '/share/face.jpg');
        is $res.Content-Type, 'image/jpeg';
    }, 'static fetch of jpg has jpeg content type';

    subtest {
        my $res = await $c.request(GET '/more-share/face.jpg');
        is $res.Content-Type, 'image/jpeg';
    }, 'static fetch, same file, multiple paths';

    subtest {
        my $res = await $c.request(GET '/share-pass/faceX.jpg');
        is $res.code, 200, 'pass through';
        is $res.content, 'hello';
    }, 'static fetch works via pass-through as well';

    subtest {
        my $res = await $c.request(GET '/t/middleware/static.txt');
        is $res.Content-Type.primary, 'text/plain';
        is $res.Content-Type.charset, 'utf-8';
    }, 'content-type charset gets set';

    subtest {
        my $res = await $c.request(GET '/t/middleware/static.foo');
        is $res.Content-Type.primary, 'text/x-foo';
    }, 'funky content-type handling works';
};

done-testing;
