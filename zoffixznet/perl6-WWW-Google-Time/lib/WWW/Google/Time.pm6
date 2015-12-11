use HTTP::Tinyish;
use URI::Escape;
unit package WWW::Google::Time:ver<1.001001>;

sub google-time-in (Str:D $location) is export {
    my %res = HTTP::Tinyish.new( agent => "Mozilla/5.0" ).get:
        'http://google.com/search?num=100&hl=en&safe=off&btnG=Search'
        ~ '&meta=&q=' ~ uri-escape "time in $location";

    %res<status> == 200 or fail "Received HTTP status %res<status> from Google";
    %res<content> ~~ m{
        '<div class="_rkc _Peb">'
            $<time>=(.+?)
        '</div><div class="_HOb _Qeb"> '
            $<week-day>=(\w+)
        ', <span style="white-space:nowrap">'
            $<month>=(\w+) ' ' $<month-day>=(\d+) ', '
            $<year>=(\d+)
        '</span> (' $<tz>=(.+?) ') </div><span class="_HOb _Qeb">'
            \s+ 'Time in ' $<where>=(.+?) ' </span>'
    } or fail 'Did not find time for this location';

    my %time;
    %time<time  week-day  month  month-day  year  tz  where>
    =  $/<time  week-day  month  month-day  year  tz  where>».Str;
    %time<where> ~~ s:g/'<em>' | '</em>' | '<b>' | '</b>'//;
    %time<str> = "%time<time> %time<tz>, %time<week-day>, %time<month> "
                    ~ "%time<month-day>, %time<year>";
    return %time;
};
