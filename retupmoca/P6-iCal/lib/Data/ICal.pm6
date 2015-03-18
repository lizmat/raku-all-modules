class Data::ICal;

use Data::ICal::Grammar;
use Data::ICal::Event;
use Data::ICal::TimeZone;

has $.version;
has $.prodid;

has @.events;
has %.timezones;

method Str {
    my $ret;

    $ret ~= "BEGIN:VCALENDAR\n";
    $ret ~= "VERSION:2.0\n";
    $ret ~= "PRODID:" ~ $.prodid ~ "\n" if $.prodid;
    for %.timezones.kv -> $k, $v {
        $ret ~= ~$v;
    }
    for @.events {
        $ret ~= ~$_;
    }
    $ret ~= "END:VCALENDAR\n";

    $ret;
}

multi method new($text, :$raw) {
    if $raw {
        my $tree = Data::ICal::Grammar.parse($text, :rule('section'), :actions(Data::ICal::Actions)).made;
        return $tree;
    }
    else {
        my $s = self.bless();
        $s.parse($text);
        return $s;
    }
}

method parse($text) {
    my $tree = Data::ICal::Grammar.parse($text, :rule('section'), :actions(Data::ICal::Actions)).made;

    die "Need VCALENDAR item" unless $tree<name> eq 'VCALENDAR';

    for $tree<properties>.list {
        if $_<name> eq 'VERSION' {
            $!version = $_<value>;
        }
        elsif $_<name> eq 'PRODID' {
            $!prodid = $_<value>;
        }
    }

    die "Can only understand VCALENDAR version 2.0" unless $!version eq '2.0';

    for $tree<sections>.list {
        if $_<name> eq 'VEVENT' {
            my $uid;
            my $dtstamp;
            my $organizer;
            my $dtstart-raw;
            my $dtend-raw;
            my $summary;
            my $status;
            my $method;
            my $sequence;
            my $description;

            for $_<properties>.list {
                $uid = $_<value> if $_<name> eq 'UID';
                $dtstamp = $_<value> if $_<name> eq 'DTSTAMP';
                $summary = $_<value> if $_<name> eq 'SUMMARY';
                $status = $_<value> if $_<name> eq 'STATUS';
                $method = $_<value> if $_<name> eq 'METHOD';
                $sequence = $_<value> if $_<name> eq 'SEQUENCE';
                $description = $_<value> if $_<name> eq 'DESCRIPTION';

                if $_<name> eq 'ORGANIZER' {
                    $organizer = ( :email($_<value>), :name($_<meta><CN>) ).hash;
                    $organizer<email> ~~ s/^MAILTO\://;
                }
                if $_<name> eq 'DTSTART' {
                    $dtstart-raw = ( :value($_<value>), :tzid($_<meta><TZID>) ).hash;
                }
                if $_<name> eq 'DTEND' {
                    $dtend-raw = ( :value($_<value>), :tzid($_<meta><TZID>) ).hash;
                }
            }

            @!events.push: Data::ICal::Event.new(:$uid, :$dtstamp, :$organizer, :$dtstart-raw, :$dtend-raw, :$summary, :$status, :$method, :$sequence, :$description, :root(self));
        }
        elsif $_<name> eq 'VTIMEZONE' {
            my $tzid;
            my $std-offset;
            my $std-rrule;
            my $dst-offset;
            my $dst-rrule;

            for $_<properties>.list {
                $tzid = $_<value> if $_<name> eq 'TZID';
            }

            for $_<sections>.list {
                if $_<name> eq 'STANDARD' {
                    for $_<properties>.list {
                        $std-offset = $_<value> if $_<name> eq 'TZOFFSETTO';
                        $std-rrule = $_<value> if $_<name> eq 'RRULE';
                    }
                }
                elsif $_<name> eq 'DAYLIGHT' {
                    for $_<properties>.list {
                        $dst-offset = $_<value> if $_<name> eq 'TZOFFSETTO';
                        $dst-rrule = $_<value> if $_<name> eq 'RRULE';
                    }
                }
            }

            %!timezones{$tzid} = Data::ICal::TimeZone.new(:$tzid, :$std-offset, :$std-rrule, :$dst-offset, :$dst-rrule);
        }
    }
}
