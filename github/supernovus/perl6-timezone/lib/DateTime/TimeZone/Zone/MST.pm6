use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::MST does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-7:00"), :rules(""), :until(Inf)}]<>;
