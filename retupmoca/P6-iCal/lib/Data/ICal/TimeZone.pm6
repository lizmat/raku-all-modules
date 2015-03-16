class Data::ICal::TimeZone;

has $.tzid;
has $.std-offset;
has $.std-rrule;
has $.dst-offset;
has $.dst-rrule;

method offset-for-datetime($dt) {
    # lets start at the beginning of the year (standard time)
    my $offset = $.std-offset;

    my @parts;
    @parts = $.std-rrule.split(/\;/);
    my %std-rules;
    for @parts {
        my @p = .split(/\=/);
        %std-rules{@p[0]} = @p[1];
    }

    @parts = $.dst-rrule.split(/\;/);
    my %dst-rules;
    for @parts {
        my @p = .split(/\=/);
        %dst-rules{@p[0]} = @p[1];
    }

    # if we match the standard time rule, we're in the fall - so it cannot be DST.
    # so we have our offset
    my $day = getday($dt.year, $dt.month, %std-rules<BYDAY>);
    if $dt.month > %std-rules<BYMONTH> {
        # we're good, do nothing (end-of-year standard time)
    }
    elsif $dt.month == %std-rules<BYMONTH> && $dt.day >= $day {
        # we're good, do nothing (end-of-year standard time)
    }
    else {
        # otherwise, check to see if we match the DST rule
        my $day = getday($dt.year, $dt.month, %dst-rules<BYDAY>);
        if $dt.month > %dst-rules<BYMONTH> {
            # we need the DST offset
            $offset = $.dst-offset;
        }
        elsif $dt.month == %dst-rules<BYMONTH> && $dt.day >= $day {
            # we need the DST offset
            $offset = $.dst-offset;
        }
        else {
            # we're good, do nothing (beginning-of-year standard time)
        }
    }

    $offset;
}

sub getday($year is copy, $month is copy, $desc) {
    $desc ~~ /^(.*)(..)$/;
    my $weeknum = $0;
    my $day = $1;

    # assume $day is SU ...
    # TODO: actually parse the day of week

    my $date;
    if $weeknum < 0 {
        my $dt = DateTime.new(:year($year), :month($month + 1), :day(1)).earlier(:day(1));
        while $dt.day-of-week != 7 {
            $dt .= earlier(:day(1));
        }
        $dt .= later(:week($weeknum + 1));
        $date = $dt.day;
    }
    else {
        my $dt = DateTime.new(:year($year), :month($month + 1), :day(1));
        while $dt.day-of-week != 7 {
            $dt .= later(:day(1));
        }
        $dt .= later(:week($weeknum - 1));
        $date = $dt.day;
    }

    $date;
}
