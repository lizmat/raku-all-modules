
use Net::FTP::Config;

unit module Net::FTP::Format;

our ($now, $currentyear) = BEGIN {
    my Int $day = 0;
    my Int $year = 0;
    my Int $base = 0;

    # add code
    my Int $now = +(time) - $base;

    $day = ($now / 86400).floor; # 86400 - one day
    $day-- if $now % 86400 < 0;
    $day -= 11017; # ?
    $year = 5 + ($day / 146097).floor;
    $day %= 146097;
    if $day < 0 {
        $day += 146097; --$year;
    }
    $year *= 4;
    if $day == 146096 {
        $year += 3;$day = 36524;
    }
    $year *= 25;
    $year += ($day / 1461).floor;
    $day %= 1461;
    $year *= 4;
    if $day == 1460 {
        $year += 3;$day = 365;
    } else {
        $year += ($day / 365).floor;$day %= 365;
    }
    $day *= 10;
    $year++ if (($day + 5) / 306).floor >= 10;
    ($now, $year);
}

#   FOMAT
#   name    => file name
#   link    => symbol link name
#   id      => file identification
#   type    => file type
#   size    => file size
#   time    => file last modify time [Date]

# LINK
# http://cr.yp.to/ftpparse/ftpparse.c

sub format (Str $str, :$debug = False) is export {
    note '+' ~ $str if $debug;
    ($str ~~ /^\+/) ?? formatEplf($str) !! formatBinls($str);
}

sub formatEplf(Str $str is copy) {
    my %info;

    if $str ~~ s/\,\s+(.*)$// {
        %info<name> = ~$0;
    }
    $str ~~ s/^\+//;

    my @col = $str.split(',');

    for @col {
        if /i(.*)/ {
            %info<id> = ~$0;
        } elsif /\// {
            %info<type> = FILE::DIR;
        } elsif /r/ {
            %info<type> = FILE::NORMAL;
        } elsif /s(\d+)/ {
            %info<size> = +$0;
        } elsif /m(\d+)/ {
            # change time type to DateTime
            %info<time> = makeDateTime(+$0);
        }
        # seems like fmode have not use
        #(elsif /up(\d+)/ {
        #	%info<mode> = ~$0;
        #})
    }

    %info;
}

sub formatBinls(Str $str is copy) {
    my %info;

    if $str ~~ /^
            ([\-|b|c|d|l|p|s])
            [
                [\-|<.alpha>]+ |
                \s+\[ [\-|<.alpha>]+ \]
            ]\s+/ {
        %info<type> = gettype(~$0);
        if $str ~~ /
                $<size> = (\d+)\s+
                $<month> = (<.alpha> ** 3)\s+
                $<day> = (\d+)\s+
                [
                    $<year> = (\d ** 4) |
                    $<hour> = (\d ** 2) \: $<minute> = (\d ** 2)
                ]\s+
                $<name> = (.*)$/ {
            %info<name> = ~$<name>;
            %info<size> = +$<size>;
            my $month = getmonth(~$<month>);
            %info<time> = makeDateTime(
                    +($<year> ?? $<year> !! getyear($month, +$<day>)),
                    $month,
                    +$<day>,
                    +($<year> ?? 0 !! $<hour>),
                    +($<year> ?? 0 !! $<minute>));

        }
    }
    if %info<name>:exists {
        if %info<name> ~~ /
                $<name> = (.*)\s+
                \-\>\s+
                $<link> = (.*)/ {
            %info<name> = $<name>;
            %info<link> = $<link>;
        }
    }
    if $str ~~ s:s/^
                $<name> = (.*)\.
                $<type> = ([DIR|.*])\;
                \S*\s+// {
        if $<type> eq "DIR" {
            %info<type> = FILE::DIR;
            %info<name> = ~$<name>;
        } else {
            %info<type> = FILE::NORMAL;
            %info<name> = ~$<name> ~ '.' ~ $<type>;
        }
        if $str ~~ /^
                \S+\s+
                $<day> = (\d+)\-
                $<month> = (\w ** 3)\-
                $<year> = (\d ** 4)\s+
                $<hour> = (\d+)\:
                $<minute> = (\d+)/ {
            #$0 day $1 month $2 year $3 hour $4 minute
            %info<time> = makeDateTime(
                    $<year>,
                    getmonth(~$<month>),
                    $<day>,
                    $<hour>,
                    $<minute>);
        }
    } elsif $str ~~ /^
                $<month> = (\d+)\-
                $<day> = (\d+)\-
                $<year> = (\d ** 4)\s+
                $<hour> = (\d+) \:
                $<minute> = (\d+)
                $<ampm> = ([AM|PM])\s+
                $<typeorsize> = ([\<DIR\> | \d+])\s+
                $<name> = (.*)/ {
        #$0 month $1 day $2 year $3 hour $4 minute $5 AM | PM
        %info<time> = makeDateTime(
                    $<year>,
                    $<month>,
                    $<day>,
                    ~$<ampm> eq "AM" ?? $<hour> !! $<hour> + 12,
                    $<minute>);
        %info<name> = ~$<name>;
        if ~$<typeorsize> eq '<DIR>' {
            %info<type> = FILE::DIR;
        } else {
            %info<size> = +$<typeorsize>;
            %info<type> = FILE::NORMAL;
        }
    }

    %info;
}

sub gettype($type) {
    given $type {
        when '-' {
            return FILE::NORMAL;
        }
        when 'd' {
            return FILE::DIR;
        }
        when 'l' {
            return FILE::LINK;
        }
        when 's' {
            return FILE::SOCKET;
        }
        when 'p' {
            return FILE::PIPE;
        }
        when 'c' {
            return FILE::CHAR;
        }
        when 'b' {
            return FILE::BLOCK;
        }
    }
}

constant @month = (
    "jan","feb","mar","apr",
    "may","jun","jul","aug",
    "sep","oct","nov","dec"
);

sub getmonth(Str $str) returns Int {
    my $strlc = $str.lc;

    loop (my Int $i = 0;$i < +@month;$i++) {
        return $i + 1 if $strlc eq @month[$i];
    }
    return -1;
}

sub getyear(Int $month, Int $day) {
    my Int $t;

    loop (my Int $year = $currentyear - 1;$year < $currentyear + 100;++$year) {
        $t = getseconds($year, $month, $day);
        if $now - $t < 350 * 86400 {
            return $year;
        }
    }
    return -1;
}

multi sub makeDateTime(Int $year, Int $month, Int $day, Int $hour, Int $minute) returns DateTime {
    return DateTime.new(
        year => $year,
        month => $month,
        day => $day,
        hour => $hour,
        minute => $minute
    );
}

multi sub makeDateTime(Int $timet) returns DateTime {
    return DateTime.new($timet);
}

# $month start 0;
sub getseconds(Int $y, Int $m, Int $d) is export {
    my ($year, $month, $day) = ($y, $m, $d);

    if $month >= 2 {
        $month += 10;
        $year -= 1;
    } else {
        $month -= 2;
    }

    return (($year / 4).floor  - ($year / 100).floor + ($year / 400).floor  +
        $year * 365 + (367 * $month / 12).floor + $day - 719499) * 86400;
}

# vim: ft=perl6
