#!/usr/bin/env perl6

use v6.c;

use Test;
plan 8;

use URI::FetchFile;

my $executable;

my $type = URI::FetchFile::Provider::Wget;

is $type.executable-name, 'wget', "got executable name";

lives-ok { $executable = $type.executable }, "executable";

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
    skip-rest "wget provider isn't available";
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
