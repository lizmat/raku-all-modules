use v6;

use Test;
use DateTime::Format;
use DateTime::Format::LikeGo;

plan 3;

is(
    DateTime::Format::LikeGo::go-to-strftime('% Mon Monday Jan January 02 _2 01 06 2006 15 03 _3 04 PM pm 05'),
    '%% %a %A %b %B %d %e %m %y %Y %H %I %l %M %p %P %S',
    'go-to-strftime with all specifiers',
);

my $now = DateTime.now();
is(
    go-date-format('% Mon Monday Jan January 02 _2 01 06 2006 15 03 _3 04 PM pm 05', $now),
    strftime('%% %a %A %b %B %d %e %m %y %Y %H %I %l %M %p %P %S', $now),
    'go-time-format with all specifiers',
);

my $other = DateTime.new('2000-07-07T21:44:55Z');
is(
    go-date-format('Jan _2 15:04:05 2006', $other),
    'Jul  7 21:44:55 2000',
    'another date format',
);
