use v6;
use Test;

use lib 'lib';

plan 2;

use DateTime::Format::RFC2822;

my $rfc = DateTime::Format::RFC2822.new();

# Try currently implemented strftime() formats
my $g1 = DateTime.new(
  :year(1582), :month(10), :day(4),
  :hour(13),   :minute(2), :second(3.654321), 
  :timezone(-28800), :formatter($rfc)
);

my $need1 = "Mon, 04 Oct 1582 13:02:03 -0800";

is ~$g1, $need1, 'RFC 2822 format with specific timezone'; # test 1

my $need2 = "Mon, 04 Oct 1582 21:02:03 +0000";

my $g2 = $g1.utc;
is ~$g2, $need2, 'RFC 2822 format with UTC'; #test 2

