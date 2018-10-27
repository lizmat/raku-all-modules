use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Ndjamena does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("1:00:12"), :rules(""), :until(-1830384000)}, {:baseoffset("1:00"), :rules(""), :until(308707200)}, {:baseoffset("2:00"), :rules(""), :until(321321600)}, {:baseoffset("1:00"), :rules(""), :until(Inf)}]<>;
