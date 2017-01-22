#!/usr/bin/env perl6

use v6.c;

use Test;

use URI::FetchFile;

my $file = 'test-output-' ~ $*PID.Str;

lives-ok {
    nok fetch-uri('http://rabidgravy.com/NoThErEAtAll', $file), "no file";
    nok $file.IO.e, "and the file doesn't exist";
    $file.IO.unlink;
}, "attempt a non-existent file";

lives-ok {
    ok fetch-uri('http://rabidgravy.com/index.html', $file), "file exists";
    ok $file.IO.e, "and the file does exist";
    $file.IO.unlink;
}, "attempt an existing file";

class TestProvider does URI::FetchFile::Provider {
    method is-available() returns Bool {
        False;
    }
    method fetch(:$uri, :$file) returns Bool {
        False;
    }
}

lives-ok { URI::FetchFile.set-providers(TestProvider) }, "set-providers";

throws-like { fetch-uri('http://rabidgravy.com/index.html', $file)}, X::NoProvider, "no usable providers";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
