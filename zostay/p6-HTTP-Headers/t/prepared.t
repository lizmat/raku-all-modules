#!perl6

use v6;

use Test;
use HTTP::Headers;

# Headers may be set to date or instants and do TheRightThing™
my $date = DateTime.new(:2015year, :5month, :14day, :9hour, :48minute);
my $h = HTTP::Headers.new;
$h.Date = $date;
is($h.as-string, "Date: Thu, 14 May 2015 09:48:00 GMT\n");
$h.Date = Instant.new(1431596915);
is($h.as-string, "Date: Thu, 14 May 2015 09:48:00 GMT\n");
$h.Retry-After = Duration.new(120);
is($h.as-string, "Date: Thu, 14 May 2015 09:48:00 GMT\nRetry-After: 120\n");

done;
