use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Niamey does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("0:08:28"), :rules(""), :until(-1830384000)}, {:baseoffset("-1:00"), :rules(""), :until(-1131235200)}, {:baseoffset("0:00"), :rules(""), :until(-315619200)}, {:baseoffset("1:00"), :rules(""), :until(Inf)}]<>;
