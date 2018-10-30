use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Cayman does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-5:25:32"), :rules(""), :until(-2524521600)}, {:baseoffset("-5:07:11"), :rules(""), :until(-1830384000)}, {:baseoffset("-5:00"), :rules(""), :until(Inf)}]<>;
