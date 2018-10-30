#!/usr/bin/env perl6

use v6.c;

use Test;
plan 8;

use URI::FetchFile;


my $type = URI::FetchFile::Provider::LWP::Simple;

is $type.class-name, 'LWP::Simple', "got class name";

my $class;
lives-ok { $class = $type.type }, "type";

if $type.is-available {
    lives-ok { 
        nok $type.fetch(uri => 'http://rabidgravy.com/NotThEre', file => 'test-output'), "get with a 404";
    }, "fetch on a non-existent file";
    nok 'test-output'.IO.e, "and the file didn't get created";
    lives-ok {
        ok $type.fetch(uri => 'http://rabidgravy.com/index.html', file => 'test-output'), "get with a real resource";
    }, "and get an existingy one";
    ok 'test-output'.IO.e, 'and the file does exist';
    'test-output'.IO.unlink;
}
else {
    skip-rest "LWP::Simple provider isn't available";
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
