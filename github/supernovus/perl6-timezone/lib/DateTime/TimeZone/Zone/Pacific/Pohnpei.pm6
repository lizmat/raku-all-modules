use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Pohnpei does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("10:32:52"), :rules(""), :until(-2177452800)}, {:baseoffset("11:00"), :rules(""), :until(Inf)}]<>;
