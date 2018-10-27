use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Marquesas does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-9:18:00"), :rules(""), :until(-1830384000)}, {:baseoffset("-9:30"), :rules(""), :until(Inf)}]<>;
