use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Etc::GMT_minus_14 does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("14"), :rules(""), :until(Inf)}]<>;
