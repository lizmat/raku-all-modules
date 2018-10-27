use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Tahiti does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-9:58:16"), :rules(""), :until(-1830384000)}, {:baseoffset("-10:00"), :rules(""), :until(Inf)}]<>;
