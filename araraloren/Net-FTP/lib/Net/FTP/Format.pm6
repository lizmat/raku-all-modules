
use Net::FTP::Config;

unit module Net::FTP::Format;

#   FOMAT
#   name    => file name
#   link    => symbol link name
#   id      => file identification
#   type    => file type
#   size    => file size
#   time    => file last modify time

sub format (Str $str) is export {
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
            %info<time> = +$0;
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
            %info<time> = gettimet(
                    +($<year> ?? $<year> !! getyear()),
                    getmonth(~$<month>),
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
            %info<time> = gettimet(
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
        %info<time> = gettimet(
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

sub getmonth(Str $str) {
    my $strlc = $str.lc;

    my $i = 0;

    for @month {
        if $strlc eq $_ {
            return $i;
        }
        $i++;
    }

    return -1;
}

sub getyear() {
    0;
}

sub gettimet(Int $year, Int $month, Int $day, Int $hour, Int $minute) {
    0;
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
