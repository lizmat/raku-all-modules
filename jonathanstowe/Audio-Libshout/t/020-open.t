#!perl6
use v6;
use Test;
use CheckSocket;

use Audio::Libshout;

my $host = %*ENV<SHOUT_TEST_HOST> // 'localhost';
my $port = %*ENV<SHOUT_TEST_PORT> // 8000;
my $user = %*ENV<SHOUT_TEST_USER> // 'source';
my $pass = %*ENV<SHOUT_TEST_PASS> // 'hackme';
my $mount = %*ENV<SHOUT_TEST_MOUNT> // '/shout_test';

my $test-data = $*CWD.child('t/data');

plan 20;

if not check-socket($port, $host) {
    diag "not performing live tests as no icecast server";
    skip-rest "no icecast server";
    exit;
}

my $obj;

lives-ok { $obj = Audio::Libshout.new }, "create an Audio::Libshout object";

lives-ok {
$obj.host = $host;
$obj.port = $port;
$obj.user = $user;
$obj.mount= $mount;
}, "set some mandatory parameters";

throws-like { $obj.open }, X::ShoutError, "open without password should fail";

$obj.password = 'S0me8oGusP455w0RD!%';

throws-like { $obj.open }, rx/"The server refused login, probably because authentication failed"/, "open with wrong password should fail";

$obj.password = $pass;

lives-ok { $obj.open }, "open with good password";
lives-ok { $obj.open }, "open again to check it's safe";
lives-ok { $obj.close }, "close it";
lives-ok { $obj.close }, "close it again to check";
lives-ok { $obj.open }, "open again again to check it's safe";
lives-ok { $obj.close }, "close it";

my @tests = { file => 'cw_glitch_noise15.mp3', format => Audio::Libshout::Format::MP3 },
            { file => 'cw_glitch_noise15.ogg', format => Audio::Libshout::Format::Ogg };

for @tests -> $test {
    my $obj;
    lives-ok { $obj = Audio::Libshout.new(user => $user, password => $pass, host => $host, port => $port, mount => $mount) }, "new to test sending " ~ $test<file>;

    lives-ok { $obj.format = $test<format> }, "set format to " ~ $test<format>;

    my $file = $test-data.child($test<file>).open(:bin);

    my Bool $last = False;

    my $channel;

    lives-ok { $channel = $obj.send-channel }, "get send-channel";

    lives-ok {
        while not $last {
            my $tmp_buf = $file.read(1024);
            $last = $tmp_buf.elems < 1024;
            $channel.send($tmp_buf);
        }
        $channel.close;
    }, "send data to the channel";

    lives-ok { $obj.close }, "close the stream";
}


done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
