use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Wake does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("11:06:28"), :rules(""), :until(-2177452800)}, {:baseoffset("12:00"), :rules(""), :until(Inf)}]<>;
