use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Blantyre does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("2:20:00"), :rules(""), :until(-2114380800)}, {:baseoffset("2:00"), :rules(""), :until(Inf)}]<>;
