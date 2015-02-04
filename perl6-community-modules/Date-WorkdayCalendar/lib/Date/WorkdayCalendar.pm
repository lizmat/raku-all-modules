use v6;

class WorkdayCalendar {
    has Str  $.file     is rw;
    has Date @.holidays is rw;
    has Str  @.workdays is rw = <Mon Tue Wed Thu Fri>;
    
    method clear { 
        @.workdays = <Mon Tue Wed Thu Fri>;
        @.holidays = (); 
    }

    multi method new(Str :$filename!) {
        my $c = WorkdayCalendar.new;
        $c.read($filename);
        return $c;
    }

    multi method new(Str $filename) {
        return WorkdayCalendar.new(filename=>$filename);
    }

    method perl {
        return "WorkdayCalendar.new(" ~ @.workdays.perl ~ ", " ~ @.holidays.perl ~ ", " ~ $.file.perl ~ ")";         
    }

    method read(Str $calendar_filename) {
        my $CAL = open $calendar_filename or die "Can't open $calendar_filename : $!";
        $.file = $calendar_filename;
        self.clear;
        for $CAL.lines -> $line {
            next if $line ~~ /^'#'/; #--- Comments are skipped
            my ($type, $data) = split /':'/, $line;
            given $type {
                when 'H' {
                    my ($year, $month, $day) = split /'/'|'-'/, $data; #--- Only Holidays '
                    try {
                        push @.holidays, Date.new("$year-$month-$day");;
                        CATCH {
                            note "ERROR: Specifying holiday date. Date $year-$month-$day skipped";
                            next;
                        }
                    }    
                }
                when 'W' {
                    try {
                        my @workweek_spec = split /','/, $data; 
                        my $workweek_spec_failed = False;
                        for @workweek_spec -> $weekday {
                            if ($weekday ne any(<Mon Tue Wed Thu Fri Sat Sun>)) {
                                warn "Workday '$weekday' not recognized";
                                $workweek_spec_failed = True;
                                last;
                            }
                        }
                        if ($workweek_spec_failed) {
                            note "ERROR: Workweek specification not valid. Assuming Mon,Tue,Wed,Thu,Fri";
                            @.workdays = <Mon Tue Wed Thu Fri>;
                            next;
                        } else {
                            @.workdays = @workweek_spec;    
                        }
                    }
                }                 
            }
        }
        @.holidays .= sort;
        close $CAL;
    }

    method is-workday(Date $day){
        return !(self.is-weekend($day) || self.is-holiday($day));
    }

    method is-weekend(Date $day) {
        my $weekday_name = <Mon Tue Wed Thu Fri Sat Sun>[$day.day-of-week - 1]; 
        return ($weekday_name ne any(@.workdays));
    }

    method is-holiday(Date $day) {
        my @daycounts;
        push @daycounts, $_.get-daycount for @.holidays;
        return ?($day.get-daycount == any(@daycounts));
    }

    method workdays-away(Date $start, Int $days) {
        return $start if $days == 0;
        my Date $current_day = $start;
        for (1 .. $days.abs) {
            repeat {
                $current_day = ($days > 0) ?? $current_day.Date::succ 
                                           !! $current_day.Date::pred;
            } until self.is-workday($current_day);
        }   
        return $current_day;                              
    }

    method workdays-to(Date $start is copy, Date $target is copy) {
        return 0 if $start.get-daycount == $target.get-daycount;
        my $sign = ($start.get-daycount < $target.get-daycount) ?? +1
                                                                !! -1;
        my Date $current_day = $start;
        my Int $count = 0;
        repeat {
            $current_day = ($sign == +1) ?? $current_day.Date::succ
                                         !! $current_day.Date::pred;
            $count++ if self.is-workday($current_day);
        } until ($current_day.get-daycount == $target.get-daycount);
        return ($count * $sign);
    }
    
    method networkdays(Date $start is copy, Date $target is copy) {
        if $start.get-daycount == $target.get-daycount {
             return (self.is-workday($start)) ?? 1
                                              !! 0;
        }
        my $sign = +1;
        if $start.get-daycount > $target.get-daycount {
            $sign = -1;
            my Date $aux_day = $start;
            $start = $target;
            $target = $aux_day;
        }
        my Date $current_day = $start;
        my Int $count = 0;
        while ($current_day.get-daycount <= $target.get-daycount) {
            $count++ if self.is-workday($current_day);
            $current_day = $current_day.Date::succ;    
        } 
        return $count * $sign;
    }
    
    method range(Date $begin, Date $end) {      
        my Date @slice;
        my Int $from = ($begin.get-daycount, $end.get-daycount).min;
        my Int $to   = ($begin.get-daycount, $end.get-daycount).max;
        for (@.holidays) -> $date { #--- The holidays are already sorted
            push @slice, $date if ($from <= $date.get-daycount <= $to);
        }
        my $result_calendar = self.clone; #-- Requires a customized version of clone
        $result_calendar.holidays = @slice;
        return $result_calendar;
    }
    
    method clone {
        my WorkdayCalendar $new = WorkdayCalendar.new;
        given self {
            $new.workdays = .workdays;
            $new.holidays = .holidays;
            $new.file     = .file;
        }
        return $new;
    }
}  

#------------------------------------------------------------------------------#

class Workdate is Date {
    has WorkdayCalendar $.calendar is rw;
        
    # We try to provide the same constructors as the Date class 
    multi method new(:$year!, :$month, :$day, :$calendar = WorkdayCalendar.new) {
        #my $D = callwith(year=>$year, month=>$month, day=>$day); 
        my $D = self.Date::new(year=>$year, month=>$month, day=>$day);
        $D.calendar = $calendar; 
        return $D; 
    }
    multi method new($year, $month, $day, $calendar = WorkdayCalendar.new) {
        #my $D = callwith(year=>$year, month=>$month, day=>$day);
        my $D = self.Date::new(year=>$year, month=>$month, day=>$day);
        $D.calendar = $calendar; 
        return $D; 
    }
    multi method new(Str $date, $calendar = WorkdayCalendar.new) {
        #my $D = callwith($date); 
        my $D = self.Date::new($date);
        $D.calendar = $calendar; 
        return $D; 
    }
    multi method new(DateTime $dt, $calendar = WorkdayCalendar.new) {
        #my $D = callwith($dt);
        my $D = self.Date::new($dt);
        $D.calendar = $calendar; 
        return $D; 
    }
    multi method new(Date $d, $calendar = WorkdayCalendar.new) {
        #my $D = callwith(year=>$d.year, month=>$d.month, day=>$d.day); 
        my $D = self.Date::new(year=>$d.year, month=>$d.month, day=>$d.day);
        $D.calendar = $calendar; 
        return $D; 
    }
    method succ { return $.calendar.workdays-away(self, +1) }
    method pred { return $.calendar.workdays-away(self, -1) }     

    method is-workday { return $.calendar.is-workday(self) }
    method is-weekend { return $.calendar.is-weekend(self) }
    method is-holiday { return $.calendar.is-holiday(self) }
    
    method workdays-away(Int $days) {
        return $.calendar.workdays-away(self, $days);
    }
    method workdays-to(Date $target) {
        return $.calendar.workdays-to(self, $target)
    }
    method networkdays(Date $target) {
        return $.calendar.networkdays(self, $target)
    }
    method perl { 
        say "Workday.new($.year, $.month, $.day, " ~ $.calendar.perl ~ ")"; 
    }     
}

#------------------------------------------------------------------------------#

multi infix:<eq>(WorkdayCalendar:D $wc1, WorkdayCalendar:D $wc2) is export {
    #--- No support for typed arrays yet AFAIK. Have to compare them in a "stringy" way
    my Str (@wc1_string_holidays, @wc2_string_holidays);
    for $wc1.holidays { push @wc1_string_holidays, "{$_.year}-{$_.month}-{$_.day}" };
    for $wc2.holidays { push @wc2_string_holidays, "{$_.year}-{$_.month}-{$_.day}" };
    my Bool $same_workdays = ($wc1.workdays ~~ $wc2.workdays);
    my Bool $same_holidays = (@wc1_string_holidays ~~ @wc2_string_holidays);
    return ?( $same_workdays && $same_holidays );
}

multi infix:<ne>(WorkdayCalendar:D $wc1, WorkdayCalendar:D $wc2) is export {
    return !($wc1 eq $wc2);
}

multi infix:<->(Workdate:D $start, Workdate:D $target) is export { 
    if ($start.calendar ne $target.calendar) {
        die "Both Workdates must have equivalent calendars to substract them";
    }
    return -1 * $start.workdays-to($target);
}


=begin pod

=head1 Introduction

The B<WorkdayCalendar> and B<Workday> objects allows to perform date calculations on a calendar 
that considers workdays (also called "business days").

Built on top of the C<Date> datatype, it uses a calendar file to specify how 
many days a workweek has and what are the days considered holidays.

By default, the I<workweek> is composed by B<Mon, Tue, Wed, Thu, Fri>. And 
B<Sat> and B<Sun> form the I<weekend>. 

Though most countries has the workweek of B<Mon> to B<Fri>, some have very 
different ones.

More information about workweeks can be found at
L<http://en.wikipedia.org/wiki/Workweek>

=head1 Calendar File format

 # An example calendar file
 W:Mon,Tue,Wed,Thu,Fri
 H:2011/01/01
 H:2011-04-05

This calendar specifies that B<Mon> to B<Fri> are to be considered workdays. And 
that 2011/01/01 and 2011/04/05 are national holidays. You can use C</> or C<-> as 
separators in a date. The format of the date B<must be> in the order Year, Month, Day

If the C<W:> specification is incorrect, the default workweek 
B<Mon, Tue, Wed, Thu, Fri> is used. If a holiday (rows starting with C<H:>) is not 
well defined, is just ignored.

Calendar files accepts comments, with lines starting with C<#>

=head1 C<WorkdayCalendar> class

=head2 C<method new>

 my $wdc1 = WorkdayCalendar.new;
 my $wdc2 = WorkdayCalendar.new('calendar.cal');
 

Creates a new calendar. Optionally, accepts a filename of a file with the calendar format 
specified above. If a filename is not specified, the calendar will have no holidays
and a default workweek of B<Mon, Tue, Wed, Thu, Fri>.

=head2 C<method clear>

Empties the information for holidays and workdays, and resets the
workweek to the default B<Mon, Tue, Wed, Thu, Fri>.

=head2 C<method read(Str $calendar_filename)>

Reads the data of holidays and workdays from a calendar file.

=head2 C<method is-workday(Date $day)>

Returns C<True> if the day is part of the workweek and not a holiday.

=head2 C<method is-weekend(Date $day)>

Returns C<True> if the day is not part of the workweek.

=head2 C<method is-holiday(Date $day)>

Returns C<True> if the day has been defined as holiday in the calendar file

=head2 C<method workdays-away(Date $start, Int $days)>

Returns a C<Date> that corresponds to the working day at which C<$days> working days have passed. 
With this method you can ask questions like:
"what is the next working day for some date?" or 
"what is the previous working day of some date?" or 
"what date is 2 working days from a date?"

Examples:

Considering the workdays = B<Mon Tue Wed Thu Fri>... 

 $start       : July 29, 2011 (it is a Friday)
 $days        : +1    
 Return Value : Aug 1, 2011 (it is a Monday)

 $start       : July 30, 2011 (it is a Saturday)
 $days        : +1    
 Return Value : Aug 1, 2011 (it is a Monday)


This also works for a negative amount of days.

=head2 C<method workdays-to(Date $start, Date $target)>

Returns the 'distance', in workdays, of C<$start> and C<$target> dates.

=head2 C<method networkdays(Date $start, Date $target)>

Works like the C<workdays-to> method, but emulates the NETWORKDAYS function in
Microsoft Excel.

 Examples
    Start     Target    workdays-to     networkdays
 2011-07-07  2011-07-14     5              6
 2011-07-07  2011-07-07     0              1
 2011-07-07  2011-07-08     1              2
 2011-07-07  2011-07-01    -4             -5
 2011-01-01  2011-01-01     0              0
 2011-01-01  2011-01-02     0              0
 2011-01-01  2011-01-03     1              1

=head2 C<method range(Date $start, Date $end)>

Returns a part of a calendar as a new WorkdayCalendar object, between the C<$start> 
and C<$end> dates, inclusive.
For example, if you have a calendar that contains holiday information for 3 years, 
you can use C<range> to obtain a new calendar that covers a period of 6 months of 
these 3 years. Useful with the C<eq> operator for WorkdayCalendar objects.

=head2 C<method perl>

Returns a string representing the contents of the WorkdayCalendar attributes.

=head1 C<Workdate> class

Implemented as a subclass of C<Date>. it replaces C<Date>'s C<.succ> and C<.pred> 
methods to consider workdays in the account, and provides the functionality to perform 
basic workdate calculations.

As parameter, you can specify a previously created 
WorkdayCalendar object, or none at all. If a WorkdayCalendar is not specified, 
it uses a default workweek of B<Mon,Tue,Wed,Thu,Fri> and no holidays.

Example:
 
 # July 1st of 2011 is a Friday
 my $wdate = Workdate.new(year=>2011, month=>07, day=>01); #--- Uses a default calendar with 
                                                           #--- default workweek and no holidays
 my $next_day = $wdate.succ; # $next_day is Monday, July 4, 2011 

Another example:

 my $CAL = WorkdayCalendar.new('example.cal'); # Some calendar file with 2011-Feb-2 as holiday
 my $date = Workdate.new(year=>2011, month=>02, day=>01, calendar=>$CAL);
 # February 1 of 2011 is a Tuesday
 my $next_day = $date.succ; # $next_day is Thursday, February 3, 2011 

=head2 C<method new>

 my $wd1 = Workdate.new(year=>2000, month=>12, day=>01, calendar=>$aWorkdayCalendar);
 my $wd2 = Workdate.new(2000, 12, 01, $aWorkdayCalendar);
 my $wd3 = Workdate.new($aDateString, $aWorkdayCalendar);
 my $wd4 = Workdate.new($aDateTimeObject, $aWorkdayCalendar);
 my $wd4 = Workdate.new($aDateObject, $aWorkdayCalendar);


We try to provide the same constructors as the base Date class, plus another to 
create Workdates from regular Dates. So, we can create a Workdate in 
4 different ways, from named and positional parameters, and using a C<Date> or a C<DateTime> 
object for specifying the date. In all cases, the calendar is optional, and if is not specified
a default calendar will be applied to the new Workdate.

=head2 C<method succ>

Returns the next workdate. 

=head2 C<method pred>

Returns the previous workdate. 

=head2 C<method is-workday>

Returns true if the workdate is not a holiday and is not part of the weekend

=head2 C<method is-weekend>

Returns true if the workdate is not part of the workweek

=head2 C<method is-holiday>

Returns true if the workdate is reported as a holiday

=head2 C<method workdays-away(Int $days)>

Returns what is the workdate that is C<$days> workdays from the workdate

=head2 C<method workdays-to(Date $target)>

Return the amount of workdays until C<$target>

=head2 C<method perl>

Returns a string representing the contents of the Workdate attributes.

=head1 Operators

=head2 Comparison: C<$WorkdayCalendar_1 B<eq> $WorkdayCalendar_2>

Compares 2 calendars and see if they are equivalent. For that, they must have the 
same holidays and the same workweek. As if they used the same calendar file. You can
use the C<range> method for WorkdayCalendar objects to compare smaller periods of time
instead of a whole WorkdayCalendar.

=head2 Comparison: C<$WorkdayCalendar_1 B<ne> $WorkdayCalendar_2>

Returns the opposite of C<eq>

=head2 Arithmetic: C<Workdate $wd1 B<-> Workdate $wd2>

Returns the difference, in workdays, between $wd1 and $wd2


=end pod
