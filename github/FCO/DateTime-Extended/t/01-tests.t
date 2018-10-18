use Test;
use DateTime::Extended;
plan 44;

my $now = DateTime.new: :2017year:1month:12day :18hour:0minute:0second;
$now does DateTime::Extended;
is $now.next-day-of-week(5),		DateTime.new: :2017year:1month:13day	:18hour:0minute:0second;
is $now.next-day-of-week(monday),	DateTime.new: :2017year:1month:16day	:18hour:0minute:0second;
is $now.next-day-of-week(3),		DateTime.new: :2017year:1month:18day	:18hour:0minute:0second;

is $now.last-day-of-week(3),		DateTime.new: :2017year:1month:11day	:18hour:0minute:0second;
is $now.last-day-of-week(monday),	DateTime.new: :2017year:1month:9day		:18hour:0minute:0second;
is $now.last-day-of-week(5),		DateTime.new: :2017year:1month:6day		:18hour:0minute:0second;

is $now.first-day-of-month,			DateTime.new: :2017year:1month:1day		:18hour:0minute:0second;
is $now.last-day-of-month,			DateTime.new: :2017year:1month:31day	:18hour:0minute:0second;

is $now.years-until(DateTime.new: :2017year), 0;
is $now.years-until(DateTime.new: :2020year), 3;
is $now.years-until(DateTime.new: :2000year), -17;

is $now.months-until(DateTime.new: :2017year:5month:21day), 4;
is $now.months-until(DateTime.new: :2020year:5month:21day), 40;
is $now.months-until(DateTime.new: :2000year:5month:21day), -200;

is $now.next-riopm-social, $now;
is $now.later(:1day).next-riopm-social,										DateTime.new: :2017year:2month:10day    :18hour:0minute:0second;
is $now.later(:1day).next-riopm-social.later(:1second).next-riopm-social,	DateTime.new: :2017year:3month:13day    :18hour:0minute:0second;
is $now.later(:1month).next-riopm-social,									DateTime.new: :2017year:3month:13day    :18hour:0minute:0second;

isa-ok datetime-extended, DateTime;
does-ok datetime-extended, DateTime::Extended;
nok datetime-extended.defined;

is datetime-extended.next-riopm-social, datetime-extended.now.next-riopm-social;

my $today = Date.new: :2017year:1month:12day;
$today does DateTime::Extended;
is $today.next-day-of-week(5),		Date.new: :2017year:1month:13day;
is $today.next-day-of-week(monday),	Date.new: :2017year:1month:16day;
is $today.next-day-of-week(3),		Date.new: :2017year:1month:18day;

is $today.last-day-of-week(3),		Date.new: :2017year:1month:11day;
is $today.last-day-of-week(monday),	Date.new: :2017year:1month:9day;
is $today.last-day-of-week(5),		Date.new: :2017year:1month:6day;

is $today.first-day-of-month,		Date.new: :2017year:1month:1day;
is $today.last-day-of-month,		Date.new: :2017year:1month:31day;

is $today.years-until(Date.new: :2017year), 0;
is $today.years-until(Date.new: :2020year), 3;
is $today.years-until(Date.new: :2000year), -17;

is $today.months-until(Date.new: :2017year:5month:21day), 4;
is $today.months-until(Date.new: :2020year:5month:21day), 40;
is $today.months-until(Date.new: :2000year:5month:21day), -200;

is $today.next-riopm-social, $today;
is $today.later(:1day).next-riopm-social,									Date.new: :2017year:2month:10day;
is $today.later(:1day).next-riopm-social.later(:1day).next-riopm-social,	Date.new: :2017year:3month:13day;
is $today.later(:1month).next-riopm-social,									Date.new: :2017year:3month:13day;

isa-ok date-extended, Date;
does-ok date-extended, DateTime::Extended;
nok date-extended.defined;

is date-extended.next-riopm-social, date-extended.today.next-riopm-social;
