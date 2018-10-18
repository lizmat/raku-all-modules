#!perl6
use Test;
plan 1;

use lib 'lib';
use URL::Find;
my $test-string =
Q{http://www.com/commaæ,
https://www.google.com/search?q=perl+6&oq=perl+6&aqs=chrome.0.69i59l3j69i60l3.742j0j1&sourceid=chrome&ie=UTF-8&,%
http://правительство.рф
ooooooooooooooo
http://실례.테스트/ель
http://παράδειγμα.δοκιμή/&};
my @correct =
'http://www.com/commaæ',
'https://www.google.com/search?q=perl+6&oq=perl+6&aqs=chrome.0.69i59l3j69i60l3.742j0j1&sourceid=chrome&ie=UTF-8';

is find-urls($test-string, :ascii<1>), @correct, "Test finding only ASCII URL's";
done-testing;
