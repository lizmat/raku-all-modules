use v6;
use Test;

plan 5;

use Data::ICal;

my $cal = q:to/EOCAL/;
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//hacksw/handcal//NONSGML v1.0//EN
BEGIN:VEVENT
UID:uid1@example.com
DTSTAMP:19970714T170000Z
ORGANIZER;CN=John Doe:MAILTO:john.doe@example.com
DTSTART:19970714T170000Z
DTEND:19970715T035959Z
SUMMARY:Bastille Day Party
END:VEVENT
END:VCALENDAR
EOCAL

my $ical = Data::ICal.new($cal);

ok $ical, 'can parse object';
ok $ical.events.elems, 'parsed events';
is $ical.events[0].uid, 'uid1@example.com', 'got properties';
ok $ical.events[0].dtstart ~~ DateTime, 'dtstart is a datetime';

is ~$ical, $cal, 'can round-trip';
