#!/usr/bin/env perl6
use v6;

use Smack::Client::Request::Common;
use Smack::Middleware::ContentMD5;
use Smack::Test;
use Test;
use HTTP::Status;

sub app(%env) {
    start {
        200, [ Content-Type => 'image/png' ],
            'share/camelia-logo.png'.IO.open(:bin).Supply
    }
}

my $md5-app = Smack::Middleware::ContentMD5.new(:&app);

test-p6wapi $md5-app, -> $c {
    my $res = await $c.request(GET '/');
    is $res.header('Content-MD5'), '873e1d5cd2ff971fffaef7fcc12222c1', 'MD5 is correct';
};

done-testing;
