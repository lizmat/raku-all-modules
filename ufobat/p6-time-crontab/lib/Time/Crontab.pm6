use v6;

unit module Time::Crontab;
use Time::Crontab::Grammar;
use Time::Crontab::Actions;
use Time::Crontab::Set;

class Time::Crontab {
    has Int $.timezone;
    has Str $.crontab;
    has Time::Crontab::Set $!minute;
    has Time::Crontab::Set $!hour;
    has Time::Crontab::Set $!dom;
    has Time::Crontab::Set $!month;
    has Time::Crontab::Set $!dow;

    submethod BUILD(:$!crontab!, :$!timezone = 0)  {
        my $actions = Time::Crontab::Actions.new();
        my $bean = Time::Crontab::Grammar.parse($!crontab, :$actions).made;
        die "$!crontab is syntactically wrong" unless $bean;
        ($!minute, $!hour, $!dom, $!month, $!dow) = $bean;
    }

    multi method match(Int $posix) {
        return self.match(DateTime.new($posix, :$.timezone));
    }

    multi method match(DateTime $datetime, Bool :$truncate = False) {
        my $dt = $datetime.in-timezone($.timezone);
        unless $!minute.contains($datetime.minute) {
            #say "minutes missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
            return False;
        }
        unless $!hour.contains($datetime.hour) {
            #say "hours missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
            return False;
        }
        unless $!month.contains($datetime.month) {
            #say "month missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
            return False;
        }

        # if dow (or dom) has a 'any' == '*' react as if there if no dow (or dom) at all.
        if $!dow.all-enabled && $!dom.all-enabled {
            # just continue, no need to check anything
        }elsif $!dow.all-enabled && ! $!dom.all-enabled {
            # just check dom
            unless $!dom.contains($datetime.day-of-month) {
                #say "dom missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
                return False;
            }
        }elsif ! $!dow.all-enabled && $!dom.all-enabled {
            # just check dow
            unless $!dow.contains($datetime.day-of-week % 7) { # %7 to make sunday (7th day) to the 0th day ;)
                #say "dow missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
                return False;
            }
        }else {
            # check both
            unless $!dom.contains($datetime.day-of-month) ||  $!dow.contains($datetime.day-of-week % 7) {
                #say "dom/dow missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
                return False;
            }
        }

        if $truncate {
            # don't care for seconds or even smaller fractions of seconds
            return True;
        }else{
            if $datetime.truncated-to('minute') == $datetime {
                #say "$datetime matches the exact minute";
                return True;
            }
            return False;
        }
    }

    method next-datetime(DateTime $datetime) {
        given $datetime.in-timezone($.timezone) {
            my $minute = .minute;
            my $hour   = .hour;
            my $day    = .day-of-month;
            my $month  = .month;
            my $year   = .year;


            $minute = $!minute.next(.minute);
            if $minute <= .minute
            || !self.match(DateTime.new(:seconds(0), :$minute, :$hour, :$day, :$month, :$year, :$.timezone)) {
                $hour = $!hour.next(.hour);
                if $hour <= .hour
                || !self.match(DateTime.new(:seconds(0), :$minute, :$hour, :$day, :$month, :$year, :$.timezone)) {

                    # always keep $day and $day-of-week up to date!
                    my $day-of-week = .day-of-week;
                    repeat {
                        my $old-day = $day;
                        my $distance-next-dom = 0;
                        my $distance-next-dow = 0;
                        my $next-dom = $!dom.next($day, $distance-next-dom);
                        my $next-dow = $!dow.next($day-of-week, $distance-next-dow);

                        # if day-of-week is set to any  -> ignore it, just use the dom way
                        # if day-of-month is set to any -> ignore it, just use the dow way
                        # else whatever is sooner:
                        #   if the dow comes before dom   -> use the dow way.
                        #   if the dom comes before dow   -> use the dow way.
                        if $!dow.all-enabled && ! $!dom.all-enabled {
                            self!apply-the-dom-way(:$day, :$day-of-week, :$old-day, :$next-dom, :$distance-next-dom);
                        } elsif ! $!dow.all-enabled && $!dom.all-enabled {
                            self!apply-the-dow-way(:$day, :$day-of-week, :$old-day, :$distance-next-dow, :$month, :$year, :$next-dow);
                        } elsif $distance-next-dow < $distance-next-dom {
                            self!apply-the-dow-way(:$day, :$day-of-week, :$old-day, :$distance-next-dow, :$month, :$year, :$next-dow);
                        } else {
                            self!apply-the-dom-way(:$day, :$day-of-week, :$old-day, :$next-dom, :$distance-next-dom);
                        }

                        # whoa! our $day is smaller as it used before, eeeks! new-month-code!
                        if $day <= $old-day {
                                $month = $!month.next($month);
                                if $month <= .month {
                                    $year++;
                                }
                        }

                        # WAIT! WHAT?
                        # Maybe the $day doesnt fit in the new month! EEEKS!
                        # e.g. for $crontab = '0 10 31 * *'    - next to 2016-03-31T11:00:00Z is 2016-05-31T10:00:00Z => there is no 31th of April
                        # e.g. for $crontab = '* * * * *'      - next to 2016-04-30T23:59:00Z is 2016-05-01T00:00:00Z => there is still no 31th of April
                        # e.g. for $crontab = '0 10 10,31 * 2' - next to 2016-04-29T14:11:00Z is 2016-05-03T10:00:00Z => 1st would be 31th april, since its closer then the dow, but then eeeks!
                    } until $day <= Dateish.days-in-month($year, $month);
                }
            }
            return DateTime.new(:seconds(0), :$minute, :$hour, :$day, :$month, :$year, :$.timezone);
        }
    }

    method !apply-the-dom-way(
        Int :$day! is rw,
        Int :$day-of-week! is rw,
        Int :$old-day! is rw,
        Int :$next-dom!,
        Int :$distance-next-dom!
    ) {
        $old-day     = $day;
        $day         = $next-dom;
        $day-of-week = ($day-of-week + $distance-next-dom) % 7;
    }

    method !apply-the-dow-way(
        Int :$day! is rw,
        Int :$day-of-week! is rw,
        Int :$old-day! is rw,
        Int :$distance-next-dow!,
        Int :$month!,
        Int :$year!,
        Int :$next-dow!
    ) {
        my $max_days = Dateish.days-in-month($year, $month);
        $old-day     = $day;
        $day         = $day + $distance-next-dow;
        $day         = $day > $max_days ?? $day - $max_days !! $day;
        $day-of-week = $next-dow;
    }
}

