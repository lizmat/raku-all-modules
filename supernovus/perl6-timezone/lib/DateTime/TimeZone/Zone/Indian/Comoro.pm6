use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Indian::Comoro does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("2:53:04"), :rules(""), :until(-1861920000)}, {:baseoffset("3:00"), :rules(""), :until(Inf)}]<>;
