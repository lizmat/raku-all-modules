use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Indian::Reunion does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("3:41:52"), :rules(""), :until(-1861920000)}, {:baseoffset("4:00"), :rules(""), :until(Inf)}]<>;
