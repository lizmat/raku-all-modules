use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Guyana does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-3:52:40"), :rules(""), :until(-1735689600)}, {:baseoffset("-3:45"), :rules(""), :until(-113702400)}, {:baseoffset("-3:45"), :rules(""), :until(175996800)}, {:baseoffset("-3:00"), :rules(""), :until(662688000)}, {:baseoffset("-4:00"), :rules(""), :until(Inf)}]<>;
