use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Douala does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("0:38:48"), :rules(""), :until(-1830384000)}, {:baseoffset("1:00"), :rules(""), :until(Inf)}]<>;
