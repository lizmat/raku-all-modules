#!perl6

use v6;
use Test;
use lib 'lib';

use LibraryCheck;

todo("this is not at all cross platform");
ok(library-exists('crypt'), "ok for a known existing library");
ok(!library-exists('XzippyYayaya'), "not ok for a bogus one");
todo("this is not at all cross platform");
lives-ok { library-exists('crypt', :exception) }, "ok for a known existing library with :exception";
throws-like {  library-exists('XzippyYayaya', :exception) }, X::NoLibrary, "bogus one throws X::NoLibrary with :exception";

done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
