use v6;
use lib 'lib';
use WWW::Google::Time;

@*ARGS.elems == 1 or die "Usage: $*PROGRAM-NAME. location\n";
my %time = google-time-in @*ARGS[0];
say "Time in %time<where> is %time<str>";
# Prints: Time in Toronto, ON is 9:25 AM EST, Monday, December 7, 2015

# Full version:
say qq:to/END/
    Location:         %time<where>
    Time:             %time<time>
    Time zone:        %time<tz>
    Day of the week:  %time<week-day>
    Month:            %time<month>
    Day of the month: %time<month-day>
    Year:             %time<year>
    Full time string: %time<str>
END

# Prints:
#    Location:         Toronto, ON
#    Time:             9:31 AM
#    Time zone:        EST
#    Day of the week:  Monday
#    Month:            December
#    Day of the month: 7
#    Year:             2015
#    Full time string: 9:31 AM EST, Monday, December 7, 2015
