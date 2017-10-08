use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Atlantic::South_Georgia does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-2:26:08"), :rules(""), :until(-2524521600)}, {:baseoffset("-2:00"), :rules(""), :until(Inf)}]<>;
