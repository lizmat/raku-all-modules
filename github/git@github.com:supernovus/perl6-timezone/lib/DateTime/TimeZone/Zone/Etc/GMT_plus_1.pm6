use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Etc::GMT_plus_1 does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-1"), :rules(""), :until(Inf)}]<>;
