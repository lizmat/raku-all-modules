#!perl6
use Test;
plan 1;

use lib 'lib';
use URL::Find;
my $test-string =
Q{"FILE://home/me/myfile.jpg",
"hTTPs://www.google.com/search?q=perl+6&oq=perl+6&aqs=chrome.0.69i59l3j69i60l3.742j0j1&sourceid=chrome&ie=UTF-8"
'Http://правительство.рф'
'ooooooooooooooo'
"HTTP://실례.테스트/ель"
'HtTp://παράδειγμα.δοκιμή/&'};
my @correct =
'hTTPs://www.google.com/search?q=perl+6&oq=perl+6&aqs=chrome.0.69i59l3j69i60l3.742j0j1&sourceid=chrome&ie=UTF-8',
'Http://правительство.рф',
'HTTP://실례.테스트/ель',
'HtTp://παράδειγμα.δοκιμή/';

is find-urls($test-string), @correct, "Test finding mixed case URL's";
done-testing;
