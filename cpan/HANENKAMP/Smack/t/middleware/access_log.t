#!/usr/bin/env perl6
use v6;

use Smack::Client::Request::Common;
use Smack::Middleware::AccessLog;
use Smack::Test;
use Test;

# TODO Finish this test after bugs in Apache::LogFormat have been addressed.
skip "Apache::LogFormat has bugs.";
done-testing;
exit;

sub root-app(%env) {
    note "root-app()";
    start {
        200,
        [
            Content-Type => 'text/plain',
            Content-Length => 2,
        ],
        [ 'OK' ]
    }
}

subtest {
    my Supplier::Preserving $log .= new;
    my $test-app = Smack::Middleware::AccessLog.wrap-that(&root-app,
        # Bug in Apache::LogFormat::Compiler %P -> $$, but should $*PID
        #format => '%P %{Host}i %p %{X-Forwarded-For}i %{Content-Type}o %{%m %y}t %v',
        format => '%{Host}i %p %{X-Forwarded-For}i %{Content-Type}o %{%m %y}t %v',
        logger => -> $line { $log.emit: $line },
    );

    test-p6wapi $test-app, -> $c {
        my $req = GET 'http://example.com/';
        $req.header.field(
            Host            => 'example.com',
            X-Forwarded-For => '192.0.2.1',
        );

        my $res = await $c.request($req);
        ok $res.is-success, 'successful request';
        is $res.code, 200, 'status code is 200';
        is $res.content, 'OK', 'content is as expected';

        my $now = DateTime.now;
        #is $log, "$*PID example.com 80 192.0.2.1 text/plain [$now.month() $now.year()] example.com";
        react {
            whenever Supply.interval(10) {
                next unless $++;
                flunk "logger took too long";
                done;
            }
            whenever $log.Supply -> $item {
                is $item, "example.com 80 192.0.2.1 text/plain [$now.month() $now.year()] example.com";
                done;
            }
        }
    };
}, 'custom format';

done-testing;
