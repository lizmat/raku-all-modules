#!perl6

use v6;
use lib 'lib';
use Test;

use LibraryCheck;

todo("this is not at all cross platform");
ok(library-exists('libcrypt'), "ok for a known existing library");
ok(!library-exists('libXzippyYayaya'), "not ok for a bogus one");

done();
