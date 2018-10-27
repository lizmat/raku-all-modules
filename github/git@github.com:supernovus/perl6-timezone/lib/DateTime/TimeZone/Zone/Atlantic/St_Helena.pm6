use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Atlantic::St_Helena does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-0:22:48"), :rules(""), :until(-2524521600)}, {:baseoffset("-0:22:48"), :rules(""), :until(-599616000)}, {:baseoffset("0:00"), :rules(""), :until(Inf)}]<>;
