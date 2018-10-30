use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Guadalcanal does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("10:39:48"), :rules(""), :until(-1830384000)}, {:baseoffset("11:00"), :rules(""), :until(Inf)}]<>;
