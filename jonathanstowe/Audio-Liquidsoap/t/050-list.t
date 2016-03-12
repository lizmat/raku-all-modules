#!perl6

use v6;

use Test;

use Audio::Liquidsoap;
use Test::Util::ServerPort;

my $port = get-unused-port();
use lib 't/lib';

use RunServer;

my $data-dir = $*PROGRAM.parent.child('data');
my $play-dir = $data-dir.child('play');

my $script = $data-dir.child('test-resources.liq');

if try RunServer.new(port => $port, script => $script.Str) -> $ls {
    my @to-delete;

    diag "Testing on port $port";
    $ls.run;


    diag "waiting until server settles ...";
    sleep 2;
    pass "Started the server";
    my $soap;
    lives-ok { $soap = Audio::Liquidsoap.new(port => $port) }, "get client";
    my @list;
    lives-ok { @list = $soap.list }, "get 'list'";
    ok @list.elems >= 3, "has at least the objects we defined";
    is $soap.get-vars.keys.elems, 3, "and we have three vars";
    is $soap.get-var("instring"), "default", "String var is correct";
    is $soap.get-var("inbool"), True, "Bool var is correct";
    is $soap.get-var("infloat"), 1, "Float var is correct";
    ok $soap.set-var("instring", "something"), "set var ok";
    is $soap.get-var("instring"), "something", "String var is changed";
    ok $soap.set-var("infloat", 3), "set float var";
    is $soap.get-var("infloat"), 3, "Float var is correct";
    ok $soap.set-var("inbool", False), "set bool var";
    is $soap.get-var("inbool"), False, "Bool var is correct";
    is $soap.queues.keys.elems, 1, "got 1 queue";
    is $soap.outputs.keys.elems, 1, "got 1 output";
    is $soap.playlists.keys.elems,1, "got 1 playlist";

    is $soap.playlists<default-playlist>.uri, 't/data/play', "playlist.uri got what we expected";

    my $new-dir = create-new-dir($play-dir);
    @to-delete.append: $new-dir;

    lives-ok { $soap.playlists<default-playlist>.uri = $new-dir.Str }, "set playlist";
    todo "this seems to just return the old playlist";
    is $soap.playlists<default-playlist>.uri, $new-dir.Str, "playlist.uri got the new one that we expected";
    lives-ok { $soap.playlists<default-playlist>.reload }, "reload the playlist";
    todo("this appears to be very timing dependent",2);
    ok (my @next = $soap.playlists<default-playlist>.next), "got some 'next' stuff";
    ok @next[0] ~~ /\[(ready|playing)\]/, "and the first one should have some status";
    #$ls.stdout.tap({ say $_ });
    is $soap.outputs<dummy-output>.status, 'on', "status is 'on'";
    ok $soap.outputs<dummy-output>.stop, "stop";
    # the server doesn't seem to change instantly
    sleep 1;
    is $soap.outputs<dummy-output>.status, 'off', "status is now 'off'";
    ok $soap.outputs<dummy-output>.start, "start";
    sleep 1;
    is $soap.outputs<dummy-output>.status, 'on', "status is 'on' again";
    ok $soap.outputs<dummy-output>.skip, "skip";
    ok do { $soap.outputs<dummy-output>.autostart = True }, "set autostart 'on'";
    ok $soap.outputs<dummy-output>.autostart, "and it says so too";
    nok do { $soap.outputs<dummy-output>.autostart = False }, "set autostart 'off'";
    nok $soap.outputs<dummy-output>.autostart, "and it says so too";
    ok do { $soap.outputs<dummy-output>.autostart = True }, "set autostart back on 'on' again";
    isa-ok $soap.outputs<dummy-output>.remaining, Duration, "and remaining is a Duration";
    isa-ok $soap.outputs<dummy-output>.metadata[0], Audio::Liquidsoap::Metadata, "metadata returns the right thing";

    # create a bunch of files to make requests
    $new-dir = create-new-dir($play-dir, 10);
    @to-delete.append: $new-dir;

    my @rids;
    for $new-dir.dir -> $file {
        lives-ok { @rids.append: $soap.queues<incoming>.push($file.Str) }, "push { $file.Str } to the request queue";
    }


    my @queue;
    lives-ok { @queue = $soap.queues<incoming>.queue }, "queue";
    # dubious if the system is fast enough";
    is @queue.elems, @rids.elems, "queue is what we expected";
    my @primary-queue;
    lives-ok { @primary-queue = $soap.queues<incoming>.primary-queue }, "primary-queue";
    my @secondary-queue;
    lives-ok { @secondary-queue = $soap.queues<incoming>.secondary-queue }, "secondary-queue";
    is @primary-queue.elems + @secondary-queue.elems, @queue.elems, "and the primary and secondary queues are right-ish";

    my ( $con-rid, $ign-rid ) = @secondary-queue.pick(2);
    ok $soap.queues<incoming>.consider($con-rid), "consider request id $con-rid";
    ok $soap.queues<incoming>.ignore($ign-rid), "ignore request id $ign-rid";

    my @alive;
    lives-ok { @alive = $soap.requests.alive }, "alive";

    my @all;
    lives-ok { @all   = $soap.requests.all  }, "all";

    my @on-air;
    lives-ok { @on-air = $soap.requests.on-air }, "on-air";

    # Not quite sure how to test that resolving gets populate (may require a "difficult" source)
    my @resolving;
    lives-ok { @resolving =  $soap.requests.resolving }, "resolving";

    if @all.elems > 0 {
        for $soap.requests.trace(@all.pick) -> $trace {
            isa-ok $trace, Audio::Liquidsoap::Request::TraceItem, "trace item is the right thing";
            isa-ok $trace.when, DateTime, "got a DateTime";
            ok $trace.what, "and got some text '{ $trace.what }'";
        }
    }
    else {
        skip "'all' is not populated - skipping", 3;
    }

    my $meta-rid;
    lives-ok { $meta-rid = $soap.requests.all.pick }, "re-get all to check";

    if $meta-rid.defined {
        my $request-meta;
        lives-ok { $request-meta = $soap.requests.metadata($meta-rid) }, "get metadata for request id $meta-rid";
        isa-ok $request-meta, Audio::Liquidsoap::Metadata, "right sort of thing";
        is $request-meta.rid, $meta-rid, "got the right record";
    }
    else {
        skip "still not got anything in 'all' skipping the metadata test", 3;
    }

    # Live source
    ok $soap.inputs<live-source> ~~ Audio::Liquidsoap::Input::Harbor, "the live-source has the Harbor role";
    is $soap.inputs<live-source>.status, "no source client connected", "got the expected status";;

    ok $soap.inputs<relay-source> ~~ Audio::Liquidsoap::Input::Http, "the relay source has the Http role";
    is $soap.inputs<relay-source>.status, 'stopped', "status is 'stopped'";
    is $soap.inputs<relay-source>.uri, 'http://stream.futuremusic.fm:8000/mp3', "got the right uri";
    ok $soap.inputs<relay-source>.start, "start it";
    ok $soap.inputs<relay-source>.status ne 'stopped', "not stopped anymore";
    ok $soap.inputs<relay-source>.stop, "stop it again";
    is $soap.inputs<relay-source>.status,'stopped', 'and the status is "stopped" again';
    ok do { $soap.inputs<relay-source>.uri = 'http://46.165.203.197:80/club_low.mp3'}, "set the uri";
    is $soap.inputs<relay-source>.uri, 'http://46.165.203.197:80/club_low.mp3', "and check it's the same";



    LEAVE {
        $ls.kill;
        await $ls.Promise;

        for @to-delete -> $d {
            if $d.d {
                for $d.dir -> $f {
                    $f.unlink;
                }
                $d.rmdir;
            }
            else {
                $d.unlink;
            }
        }
    }
}
else {
    plan 2;
    skip-rest "can't start test liquidsoap";

}

sub create-new-dir(IO::Path:D $pdir, Int $count = 1 ) {
    my $name = new-name();
    my $new-dir = $pdir.parent.child($name);
    $new-dir.mkdir;
    for ^$count {
        my $file = $pdir.dir.pick;
        my $new-name = new-name() ~ '.mp3';
        $file.copy($new-dir.child($new-name));
    }
    $new-dir;
}

sub new-name() {
    my $l = (7 .. 12).pick;
    ("a" .. "z").pick($l).join("");
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
