my class X::DateTime::CannotParse is Exception {
    has $.invalid-str;
    method message() { "Unable to parse {$!invalid-str}" }
}

class DateTime::Parse is DateTime {
    grammar DateTime::Parse::Grammar {
        token TOP {
            <dt=rfc1123-date> | <dt=rfc850-date> | <dt=rfc850-var-date> | <dt=asctime-date>
        }

        token rfc1123-date {
            <.wkday> ',' <.SP> <date=.date1> <.SP> <time> <.SP> 'GMT'
        }

        token rfc850-date {
            <.weekday> ',' <.SP> <date=.date2> <.SP> <time> <.SP> 'GMT'
        }

        token rfc850-var-date {
            <.wkday> ','? <.SP> <date=.date4> <.SP> <time> <.SP> 'GMT'
        }

        token asctime-date {
            <.wkday> <.SP> <date=.date3> <.SP> <time> <.SP> <year=.D4-year>
        }

        token date1 { # e.g., 02 Jun 1982
            <day=.D2> <.SP> <month> <.SP> <year=.D4-year>
        }

        token date2 { # e.g., 02-Jun-82
            <day=.D2> '-' <month> '-' <year=.D2>
        }

        token date3 { # e.g., Jun  2
            <month> <.SP> (<day=.D2> | <.SP> <day=.D1>)
        }

        token date4 { # e.g., 02-Jun-1982 
            <day=.D2> '-' <month> '-' <year=.D4-year>
        }

        token time {
            <hour=.D2> ':' <minute=.D2> ':' <second=.D2>
        }

        token wkday {
            'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri' | 'Sat' | 'Sun'
        }

        token weekday {
            'Monday' | 'Tuesday' | 'Wednesday' | 'Thursday' | 'Friday' | 'Saturday' | 'Sunday'
        }

        token month {
            'Jan' | 'Feb' | 'Mar' | 'Apr' | 'May' | 'Jun' | 'Jul' | 'Aug' | 'Sep' | 'Oct' | 'Nov' | 'Dec'
        }

        token D4-year {
            \d ** 4
        }

        token D2-year {
            \d ** 2
        }

        token SP {
            \s
        }

        token D1 {
            \d
        }

        token D2 {
            \d ** 2
        }
    }

    class DateTime::Parse::Actions {
        method TOP($/) {
            make $<dt>.made
        }

        method rfc1123-date($/) {
            make DateTime.new(|$<date>.made, |$<time>.made)
        }

        method rfc850-date($/) {
            make DateTime.new(|$<date>.made, |$<time>.made)
        }

        method rfc850-var-date($/) {
            make DateTime.new(|$<date>.made, |$<time>.made)
        }

        method asctime-date($/) {
            make DateTime.new(:year($<year>.made), |$<date>.made, |$<time>.made)
        }

        method !genericDate($/) {
            make { year => $<year>.made, month => $<month>.made, day => $<day>.made }
        }

        method date1($/) { # e.g., 02 Jun 1982
            self!genericDate($/);
        }

        method date2($/) { # e.g., 02-Jun-82
            self!genericDate($/);
        }

        method date3($/) { # e.g., Jun  2
            self!genericDate($/);
        }

        method date4($/) { # e.g., 02-Jun-1982
            self!genericDate($/);
        }

        method time($/) {
            make { hour => +$<hour>, minute => +$<minute>, second => +$<second> }
        }

        my %wkday = Mon => 0, Tue => 1, Wed => 2, Thu => 3, Fri => 4, Sat => 5, Sun => 6;
        method wkday($/) {
            make %wkday{~$/}
        }

        my %weekday = Monday => 0, Tuesday => 1, Wednesday => 2, Thursday => 3,
                      Friday => 4, Saturday => 5, Sunday => 6;
        method weekday($/) {
            make %weekday{~$/}
        }

        my %month = Jan => 1, Feb => 2, Mar => 3, Apr =>  4, May =>  5, Jun =>  6,
                    Jul => 7, Aug => 8, Sep => 9, Oct => 10, Nov => 11, Dec => 12;
        method month($/) {
            make %month{~$/}
        }

        method D4-year($/) {
            make +$/
        }

        method D2-year($/) {
            my $yy = +$/;
            make $yy < 34 ?? 2000 + $yy !! 1900 + $yy
        }

        method D2($/) {
            make +$/
        }
    }

    method new(Str $format, :$timezone is copy = 0, :$rule = 'TOP') {
        DateTime::Parse::Grammar.parse($format, :$rule, :actions(DateTime::Parse::Actions))
            or X::DateTime::CannotParse.new( invalid-str => $format ).throw;
        $/.made
    }
}

=begin pod

=head1 NAME

DateTime::Parse - DateTime parser

=head1 SYNOPSIS

    use DateTime::Parse;
    my $date = DateTime::Parse.new('Sun, 06 Nov 1994 08:49:37 GMT');
    say $date.Date > Date.new('12-12-2014');

=head1 DESCRIPTION

=head2 Available formats:

=item rfc1123
=item rfc850
=item asctime 

=head1 METHODS

=head2 method new

    method new(Str $format, :$timezone is copy = 0, :$rule = 'TOP')

A constructor, where:

=item $format is the text we want to parse
=item $timezone is the timezone we want to get the date in (nyi)
=item $rule specifies which rule to use, in case we know what format we want to parse (see L<#Available_Formats>)

=head1 AUTHOR

Filip Sergot (sergot)
Website: filip.sergot.pl
Contact: filip (at) sergot.pl

=end pod
